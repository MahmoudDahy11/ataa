import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:ataa/features/donor/domain/usecases/save_payment_method.dart';
import 'package:ataa/features/donor/presentation/cubit/payment_method_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/donor_repository.dart';

class PaymentMethodCubit extends Cubit<PaymentMethodState> {
  final SavePaymentMethod _savePaymentMethod;
  final DonorRepo _repo;
  final FirebaseAuth _auth;

  // ValueNotifiers for local UI state
  final ValueNotifier<PaymentType?> selectedTypeNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isButtonEnabledNotifier = ValueNotifier(false);
  final vodafoneController = TextEditingController();

  PaymentMethodCubit({
    required SavePaymentMethod savePaymentMethod,
    required DonorRepo repo,
    required FirebaseAuth auth,
  }) : _savePaymentMethod = savePaymentMethod,
       _repo = repo,
       _auth = auth,
       super(PaymentMethodInitial()) {
    vodafoneController.addListener(_validate);
    selectedTypeNotifier.addListener(_validate);
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final result = await _repo.getCachedPaymentMethod();
    result.fold((_) {}, (method) {
      if (method != null) {
        selectedTypeNotifier.value = method.type;
        if (method.vodafoneNumber != null) {
          vodafoneController.text = method.vodafoneNumber!;
        }
        emit(PaymentMethodPreloaded(method));
      }
    });
  }

  void selectType(PaymentType? type) {
    selectedTypeNotifier.value = type;
  }

  void _validate() {
    final type = selectedTypeNotifier.value;
    if (type == null) {
      isButtonEnabledNotifier.value = true; // skip is always allowed
      return;
    }
    if (type == PaymentType.vodafoneCash) {
      isButtonEnabledNotifier.value =
          vodafoneController.text.trim().length == 11;
    } else {
      isButtonEnabledNotifier.value = true;
    }
  }

  Future<void> saveMethod() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final type = selectedTypeNotifier.value;
    if (type == null) {
      emit(PaymentMethodSuccess()); // skipped
      return;
    }

    emit(PaymentMethodLoading());

    final method = PaymentMethodEntity(
      type: type,
      vodafoneNumber: type == PaymentType.vodafoneCash
          ? vodafoneController.text.trim()
          : null,
    );

    final result = await _savePaymentMethod(uid: uid, paymentMethod: method);
    result.fold(
      (failure) => emit(PaymentMethodError(failure.errMessage)),
      (_) => emit(PaymentMethodSuccess()),
    );
  }

  @override
  Future<void> close() {
    vodafoneController.dispose();
    selectedTypeNotifier.dispose();
    isButtonEnabledNotifier.dispose();
    return super.close();
  }
}
