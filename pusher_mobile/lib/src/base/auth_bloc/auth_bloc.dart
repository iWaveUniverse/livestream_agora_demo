import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:agoralivepusher/src/routes/app_pages.dart';

part 'auth_event.dart';
part 'auth_state.dart';

enum AuthStateType { none, logged }

String? get loggedUid => Get.find<AuthBloc>().state.user?.uid;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  StreamSubscription? _subscription;

  AuthBloc() : super(AuthState()) {
    on<AuthLoad>(_load);
    on<LogoutEvent>(_logout);
    on<AuthUpdateUser>(_update);
  }

  _update(AuthUpdateUser event, Emitter<AuthState> emit) async {
    state.user = event.user;
    if (state.user == null) {
      add(const AuthLoad());
    }
  }

  _load(AuthLoad event, Emitter<AuthState> emit) async {
    User? user;
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      user = FirebaseAuth.instance.currentUser;
      emit(state.update(stateType: AuthStateType.logged));
    } catch (e) {
      emit(state.update(stateType: AuthStateType.none));
    }
    if (state.stateType == AuthStateType.logged) {
      state.user = user;
      _subscription?.cancel();
      _subscription =
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
        add(AuthUpdateUser(user: user));
      });
      // appDebugPrint('[auth]: ${user?.toString()}');
      // if (user?.phoneNumber == null) {
      //   throw Exception('[auth]:phoneNumber can\'t null');
      // }
    }

    await Future.delayed(event.delay);
    _redirect();
  }

  _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    _subscription?.cancel();
    emit(state.update(stateType: AuthStateType.none));
    _redirect();
  }

  _redirect() {
    if (state.stateType == AuthStateType.logged) {
      Get.offAllNamed(Routes.home);
    }
  }
}
