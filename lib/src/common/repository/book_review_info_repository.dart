import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/book_review_info.dart';

class BookReviewInfoRepository {
  FirebaseFirestore db;
  BookReviewInfoRepository(this.db);

  Future<void> createBookReviewInfo(BookReviewInfo bookReviewInfo) async {
    await db.collection('book_review_info').add(bookReviewInfo.toJson());
  }

  Future<BookReviewInfo?> loadBookReviewInfo(String bookId) async {
    var doc = await db
        .collection('book_review_info')
        .where('bookId', isEqualTo: bookId)
        .get();
    if (doc.docs.isEmpty) {
      return null;
    } else {
      return BookReviewInfo.fromJson(doc.docs.first.data());
    }
  }

  Future<void> updateBookReviewInfo(BookReviewInfo bookReviewInfo) async {
    var data = await db
        .collection('book_review_info')
        .where('bookId', isEqualTo: bookReviewInfo.bookId)
        .get();
    await db
        .collection('book_review_info')
        .doc(data.docs.first.id)
        .update(bookReviewInfo.toJson());
  }

  Future<List<BookReviewInfo>?> loadBookReviewRecentlyData() async {
    var doc = await db
        .collection('book_review_info')
        .orderBy('updatedAt', descending: true)
        .limit(10)
        .get();
    if (doc.docs.isEmpty) {
      return null;
    }
    return doc.docs
        .map<BookReviewInfo>((data) => BookReviewInfo.fromJson(data.data()))
        .toList();
  }
}