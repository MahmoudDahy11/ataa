class CaseEntity {
  final String id;
  final String beneficiaryId;
  final String title;
  final String category;
  final double targetAmount;
  final double collectedAmount;
  final String description;
  final List<String> mediaKeys;
  final String status;
  final bool isDeleted;
  final int schemaVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CaseEntity({
    required this.id,
    required this.beneficiaryId,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.collectedAmount,
    required this.description,
    required this.mediaKeys,
    required this.status,
    required this.isDeleted,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
  });
}
