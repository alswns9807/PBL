import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/review.dart';

class ReviewRepository {
  FirebaseFirestore db;
  ReviewRepository(this.db);

  Future<void> createReview(Review review) async {
    await db.collection('review').add(review.toJson());
  }

  Future<Review?> loadReviewInfo(String bookId, String uid) async {
    var doc = await db
        .collection('review')
        .where('bookId', isEqualTo: bookId)
        .where('reviewerUid', isEqualTo: uid)
        .get();
    if (doc.docs.isEmpty) {
      return null;
    } else {
      return Review.fromJson(doc.docs.first.data());
    }
  }

  Future<void> updateReview(Review review) async {
    var data = await db
        .collection('review')
        .where('bookId', isEqualTo: review.bookId)
        .where('reviewerUid', isEqualTo: review.reviewerUid)
        .get();

    await db
        .collection('review')
        .doc(data.docs.first.id)
        .update(review.toJson());
  }

  Future<List<Review>> loadMyAllReviews(String uid) async {
    try {
      var doc = await db
          .collection('review')
          .where('reviewerUid', isEqualTo: uid)
          .get();
      return doc.docs
          .map<Review>((data) => Review.fromJson(data.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
