import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/offer_model.dart';

class OfferProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'offers';
  String? _error;

  String? get error => _error;

  Stream<List<OfferModel>> getOffers({bool activeOnly = true}) {
    Query query = _firestore.collection(_collection);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OfferModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<String> _uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<List<String>> _uploadFiles(List<String> filePaths, String folder) async {
    final urls = <String>[];
    for (var path in filePaths) {
      final file = File(path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$folder/${timestamp}_${path.split('/').last}';
      final url = await _uploadFile(file, fileName);
      urls.add(url);
    }
    return urls;
  }

  Future<void> createOffer(OfferModel offer) async {
    try {
      // Upload provider logo if it's a file path
      String? logoUrl;
      if (offer.serviceProviderLogo != null &&
          offer.serviceProviderLogo!.startsWith('/')) {
        logoUrl = await _uploadFile(
            File(offer.serviceProviderLogo!),
            'provider_logos/${DateTime.now().millisecondsSinceEpoch}_${offer.serviceProviderLogo!.split('/').last}'
        );
      }

      // Upload offer images if they're file paths
      final imageUrls = await _uploadFiles(
          offer.images,
          'offer_images/${DateTime.now().millisecondsSinceEpoch}'
      );

      // Create offer with uploaded URLs
      final offerData = offer.toFirestore();
      if (logoUrl != null) {
        offerData['serviceProviderLogo'] = logoUrl;
      }
      offerData['images'] = imageUrls;

      await _firestore.collection(_collection).add(offerData);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateOffer(OfferModel offer) async {
    try {
      if (offer.id == null) throw 'Offer ID is required for update';

      final updateData = offer.toFirestore();

      // Check if provider logo needs to be uploaded
      if (offer.serviceProviderLogo != null &&
          offer.serviceProviderLogo!.startsWith('/')) {
        final logoUrl = await _uploadFile(
            File(offer.serviceProviderLogo!),
            'provider_logos/${DateTime.now().millisecondsSinceEpoch}_${offer.serviceProviderLogo!.split('/').last}'
        );
        updateData['serviceProviderLogo'] = logoUrl;
      }

      // Check which images need to be uploaded
      final newImageUrls = <String>[];
      for (var imagePath in offer.images) {
        if (imagePath.startsWith('/')) {
          // This is a new image that needs to be uploaded
          final url = await _uploadFile(
              File(imagePath),
              'offer_images/${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}'
          );
          newImageUrls.add(url);
        } else {
          // This is an existing image URL
          newImageUrls.add(imagePath);
        }
      }
      updateData['images'] = newImageUrls;

      await _firestore
          .collection(_collection)
          .doc(offer.id)
          .update(updateData);

      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> toggleOfferStatus(String offerId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(offerId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}