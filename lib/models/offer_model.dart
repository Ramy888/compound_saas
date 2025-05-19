import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String? id;
  final String title;
  final String details;
  final String serviceProviderName;
  final String? serviceProviderLogo;
  final List<String> images;
  final double? discountPercentage;
  final double? fixedPrice;
  final double? originalPrice;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? validUntil;
  final Map<String, dynamic>? metadata;

  OfferModel({
    this.id,
    required this.title,
    required this.details,
    required this.serviceProviderName,
    this.serviceProviderLogo,
    required this.images,
    this.discountPercentage,
    this.fixedPrice,
    this.originalPrice,
    this.isActive = true,
    required this.createdBy,
    required this.createdAt,
    this.validUntil,
    this.metadata,
  }) {
    // Validate that either discountPercentage or fixedPrice is provided
    assert(
    (discountPercentage != null) != (fixedPrice != null),
    'Exactly one of discountPercentage or fixedPrice must be provided',
    );
  }

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id: doc.id,
      title: data['title'] ?? '',
      details: data['details'] ?? '',
      serviceProviderName: data['serviceProviderName'] ?? '',
      serviceProviderLogo: data['serviceProviderLogo'],
      images: List<String>.from(data['images'] ?? []),
      discountPercentage: data['discountPercentage']?.toDouble(),
      fixedPrice: data['fixedPrice']?.toDouble(),
      originalPrice: data['originalPrice']?.toDouble(),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      validUntil: data['validUntil'] != null
          ? (data['validUntil'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'details': details,
      'serviceProviderName': serviceProviderName,
      'serviceProviderLogo': serviceProviderLogo,
      'images': images,
      'discountPercentage': discountPercentage,
      'fixedPrice': fixedPrice,
      'originalPrice': originalPrice,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'metadata': metadata,
    };
  }

  String get displayPrice {
    if (discountPercentage != null) {
      return '$discountPercentage% OFF';
    } else if (fixedPrice != null) {
      return '\$${fixedPrice!.toStringAsFixed(2)}';
    }
    return '';
  }

  String get savings {
    if (originalPrice != null) {
      if (discountPercentage != null) {
        final savings = originalPrice! * (discountPercentage! / 100);
        return '\$${savings.toStringAsFixed(2)}';
      } else if (fixedPrice != null) {
        final savings = originalPrice! - fixedPrice!;
        return '\$${savings.toStringAsFixed(2)}';
      }
    }
    return '';
  }
}