abstract class DonorSetupState {}

class DonorSetupInitial extends DonorSetupState {}

class DonorSetupLoading extends DonorSetupState {}

class DonorSetupSuccess extends DonorSetupState {}

class DonorSetupError extends DonorSetupState {
  final String message;
  DonorSetupError(this.message);
}
