import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSerivce {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // fetch data from complaints documents
  Stream<List<Map<String, dynamic>>> getComplaints() {
    return _firestore.collection('complaints').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'location': doc['location'],
          'email': doc['email'],
          'image': doc['image'],
          'timestamp': doc['timestamp'],
          'contact': doc['contact'],
          'ward': doc['ward'],
          'collectorEmail': doc['collectorEmail'],
          'status': doc['status'],
        };
      }).toList();
    });
  }

  // Update status field in complaints document
  Future<void> updateComplaintStatus(
      String docId, String newStatus, collectorEmail) async {
    try {
      await _firestore.collection('complaints').doc(docId).update({
        'status': newStatus,
        'collectorEmail': collectorEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error updating complaint status: $e");
    }
  }

  Future<void> updateUserImage(String docId, String userImage) async {
    try {
      await _firestore.collection('users').doc(docId).update({
        'image': userImage,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Error updating user image: $e");
    }
  }
}
