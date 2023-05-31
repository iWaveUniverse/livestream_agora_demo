part of 'home_bloc.dart';

  class HomeState {
  bool loading;

  HomeState({
    this.loading = false,
  });

  HomeState update({
    bool? loading,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
    );
  }
}
