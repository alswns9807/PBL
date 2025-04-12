import 'package:book_mate/src/common/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  FirebaseFirestore db;
  UserRepository(this.db);

  Future<UserModel?> findUserOne(String uid) async {
    try {
      var doc = await db.collection('users').where('uid', isEqualTo: uid).get();
      if (doc.docs.isEmpty) {
        return null;
      } else {
        return UserModel.fromJson(doc.docs.first.data());
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> joinUser(UserModel userModel) async {
    try {
      db.collection('users').add(userModel.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<UserModel>> allUserInfos(List<String> uids) async {
    var doc = await db.collection('users').where('uid', whereIn: uids).get();
    if (doc.docs.isEmpty) {
      return [];
    } else {
      return doc.docs
          .map<UserModel>((data) => UserModel.fromJson(data.data()))
          .toList();
    }
  }

  Future<bool> followEvent(
      bool isFollow, String targetUid, String requestUid) async {
    try {
      final batch = db.batch();

      var targetUserDoc =
      await db.collection('users').where('uid', isEqualTo: targetUid).get();
      var targetUserInfo = UserModel.fromJson(targetUserDoc.docs.first.data());
      var followers = targetUserInfo.followers ?? [];
      if (isFollow) {
        followers.add(requestUid);
      } else {
        followers.remove(requestUid);
      }
      var targetRef = db.collection('users').doc(targetUserDoc.docs.first.id);
      batch.update(targetRef,
          {'followers': followers, 'followersCount': followers.length});

      var requestUserDoc = await db
          .collection('users')
          .where('uid', isEqualTo: requestUid)
          .get();
      var requestUserInfo =
      UserModel.fromJson(requestUserDoc.docs.first.data());
      var followings = requestUserInfo.followings ?? [];
      if (isFollow) {
        followings.add(targetUid);
      } else {
        followings.remove(targetUid);
      }
      var requestRef = db.collection('users').doc(requestUserDoc.docs.first.id);
      batch.update(requestRef,
          {'followings': followings, 'followingsCount': followings.length});

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateReviewCounts(String uid, int reviewCounts) async {
    var targetUserDoc =
    await db.collection('users').where('uid', isEqualTo: uid).get();
    await db
        .collection('users')
        .doc(targetUserDoc.docs.first.id)
        .update({'reviewCounts': reviewCounts});
  }

  Future<List<UserModel>> loadTopReviewerData() async {
    var doc = await db
        .collection('users')
        .orderBy('followersCount', descending: true)
        .limit(10)
        .get();
    if (doc.docs.isNotEmpty) {
      return doc.docs
          .map<UserModel>((data) => UserModel.fromJson(data.data()))
          .toList();
    }
    return [];
  }
}