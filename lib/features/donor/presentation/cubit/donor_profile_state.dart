import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:ataa/features/donor/domain/entities/donor_entity.dart';

abstract class DonorProfileState {}

class DonorProfileInitial extends DonorProfileState {}

class DonorProfileLoading extends DonorProfileState {}

class DonorProfileLoaded extends DonorProfileState {
  final DonorEntity donor;
  final List<DonationHistoryEntity> history;

  DonorProfileLoaded({required this.donor, required this.history});
}

class DonorProfileError extends DonorProfileState {
  final String message;
  DonorProfileError(this.message);
}

class DonorNameUpdated extends DonorProfileState {}

class DonorSignedOut extends DonorProfileState {}
