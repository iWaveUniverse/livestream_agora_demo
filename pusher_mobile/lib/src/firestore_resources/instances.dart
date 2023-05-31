import 'package:cloud_firestore/cloud_firestore.dart'; 

import 'constants.dart';
import 'helper.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

CollectionReference get colConfigs => _firestore.collection(kdb_configs); 
 