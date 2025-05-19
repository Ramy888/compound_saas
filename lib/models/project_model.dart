import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String? projectId;
  final String? projectName;
  final String? projectNameAr;
  final String? projectCover;
  final String? projectLogo;
  final String? projectType;
  final String? projectTypeAr;
  final List<String>? projectPhotosList;
  final String? projectAddress;
  final String? projectAddressAr;
  final String? projectLocation;
  final String? projectLocationAr;
  final String? projectLatestStatus;
  final String? projectLatestStatusAr;
  final String? projectUnitsTypes;
  final String? projectUnitsTypesAr;
  final String? projectSpaces;
  final String? projectSpacesAr;
  final String? projectDesc;
  final String? projectDescAr;
  final String? projectVideo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final bool isActive;
  final DateTime? removedAt;
  final String? removedBy;
  final String? removalReason;

  ProjectModel({
    this.projectId,
    this.projectName,
    this.projectNameAr,
    this.projectCover,
    this.projectLogo,
    this.projectType,
    this.projectTypeAr,
    this.projectPhotosList,
    this.projectAddress,
    this.projectAddressAr,
    this.projectLocation,
    this.projectLocationAr,
    this.projectLatestStatus,
    this.projectLatestStatusAr,
    this.projectUnitsTypes,
    this.projectUnitsTypesAr,
    this.projectSpaces,
    this.projectSpacesAr,
    this.projectDesc,
    this.projectDescAr,
    this.projectVideo,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    required this.isActive,
    this.removedAt,
    this.removedBy,
    this.removalReason,
  });

  factory ProjectModel.empty() {
    return ProjectModel(
      projectId: '',
      projectName: '',
      projectNameAr: '',
      projectCover: '',
      projectLogo: '',
      projectType: '',
      projectTypeAr: '',
      projectPhotosList: [],
      projectAddress: '',
      projectAddressAr: '',
      projectLocation: '',
      projectLocationAr: '',
      projectLatestStatus: '',
      projectLatestStatusAr: '',
      projectUnitsTypes: '',
      projectUnitsTypesAr: '',
      projectSpaces: '',
      projectSpacesAr: '',
      projectDesc: '',
      projectDescAr: '',
      projectVideo: '',
      createdAt: DateTime.now(),
      createdBy: '',
      isActive: true,
    );
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      projectId: doc.id,
      projectName: data['projName'],
      projectNameAr: data['projName_ar'],
      projectCover: data['projectCoverPhoto'],
      projectLogo: data['projectLogo'],
      projectType: data['projType'],
      projectTypeAr: data['projType_ar'],
      projectPhotosList: List<String>.from(data['photoLinks'] ?? []),
      projectAddress: data['projAddress'],
      projectAddressAr: data['projAddress_ar'],
      projectLocation: data['projPlace'],
      projectLocationAr: data['projPlace_ar'],
      projectLatestStatus: data['projStatus'],
      projectLatestStatusAr: data['projStatus_ar'],
      projectUnitsTypes: data['projUnitsType'],
      projectUnitsTypesAr: data['projUnitsType_ar'],
      projectSpaces: data['projUnitsSpace'],
      projectSpacesAr: data['projUnitsSpace_ar'],
      projectDesc: data['projDesc'],
      projectDescAr: data['projDesc_ar'],
      projectVideo: data['projectVideo'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'],
      isActive: data['isActive'] ?? true,
      removedAt: data['removedAt'] != null
          ? (data['removedAt'] as Timestamp).toDate()
          : null,
      removedBy: data['removedBy'],
      removalReason: data['removalReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projName': projectName,
      'projName_ar': projectNameAr,
      'projectCoverPhoto': projectCover,
      'projectLogo': projectLogo,
      'projType': projectType,
      'projType_ar': projectTypeAr,
      'photoLinks': projectPhotosList,
      'projAddress': projectAddress,
      'projAddress_ar': projectAddressAr,
      'projPlace': projectLocation,
      'projPlace_ar': projectLocationAr,
      'projStatus': projectLatestStatus,
      'projStatus_ar': projectLatestStatusAr,
      'projUnitsType': projectUnitsTypes,
      'projUnitsType_ar': projectUnitsTypesAr,
      'projUnitsSpace': projectSpaces,
      'projUnitsSpace_ar': projectSpacesAr,
      'projDesc': projectDesc,
      'projDesc_ar': projectDescAr,
      'projectVideo': projectVideo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'createdBy': createdBy,
      'isActive': isActive,
      'removedAt': removedAt != null ? Timestamp.fromDate(removedAt!) : null,
      'removedBy': removedBy,
      'removalReason': removalReason,
    };
  }

  ProjectModel copyWith({
    String? projectId,
    String? projectName,
    String? projectNameAr,
    String? projectCover,
    String? projectLogo,
    String? projectType,
    String? projectTypeAr,
    List<String>? projectPhotosList,
    String? projectAddress,
    String? projectAddressAr,
    String? projectLocation,
    String? projectLocationAr,
    String? projectLatestStatus,
    String? projectLatestStatusAr,
    String? projectUnitsTypes,
    String? projectUnitsTypesAr,
    String? projectSpaces,
    String? projectSpacesAr,
    String? projectDesc,
    String? projectDescAr,
    String? projectVideo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isActive,
    DateTime? removedAt,
    String? removedBy,
    String? removalReason,
  }) {
    return ProjectModel(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      projectNameAr: projectNameAr ?? this.projectNameAr,
      projectCover: projectCover ?? this.projectCover,
      projectLogo: projectLogo ?? this.projectLogo,
      projectType: projectType ?? this.projectType,
      projectTypeAr: projectTypeAr ?? this.projectTypeAr,
      projectPhotosList: projectPhotosList ?? this.projectPhotosList,
      projectAddress: projectAddress ?? this.projectAddress,
      projectAddressAr: projectAddressAr ?? this.projectAddressAr,
      projectLocation: projectLocation ?? this.projectLocation,
      projectLocationAr: projectLocationAr ?? this.projectLocationAr,
      projectLatestStatus: projectLatestStatus ?? this.projectLatestStatus,
      projectLatestStatusAr: projectLatestStatusAr ?? this.projectLatestStatusAr,
      projectUnitsTypes: projectUnitsTypes ?? this.projectUnitsTypes,
      projectUnitsTypesAr: projectUnitsTypesAr ?? this.projectUnitsTypesAr,
      projectSpaces: projectSpaces ?? this.projectSpaces,
      projectSpacesAr: projectSpacesAr ?? this.projectSpacesAr,
      projectDesc: projectDesc ?? this.projectDesc,
      projectDescAr: projectDescAr ?? this.projectDescAr,
      projectVideo: projectVideo ?? this.projectVideo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      removedAt: removedAt ?? this.removedAt,
      removedBy: removedBy ?? this.removedBy,
      removalReason: removalReason ?? this.removalReason,
    );
  }
}