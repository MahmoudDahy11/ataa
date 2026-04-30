import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';

abstract class PaymentMethodState {}

class PaymentMethodInitial extends PaymentMethodState {}

class PaymentMethodLoading extends PaymentMethodState {}

class PaymentMethodSuccess extends PaymentMethodState {}

class PaymentMethodError extends PaymentMethodState {
  final String message;
  PaymentMethodError(this.message);
}

class PaymentMethodPreloaded extends PaymentMethodState {
  final PaymentMethodEntity? existing;
  PaymentMethodPreloaded(this.existing);
}
