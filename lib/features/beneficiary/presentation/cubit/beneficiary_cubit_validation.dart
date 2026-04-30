part of 'beneficiary_cubit.dart';

extension BeneficiaryCubitValidation on BeneficiaryCubit {
  String? _validateAllRegistration() {
    for (var step = 0; step < 5; step++) {
      final error = _validateStep(step);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  String? _validateStep(int step) {
    final draft = state.registrationDraft;
    switch (step) {
      case 0:
        if (draft.fullName.trim().isEmpty) {
          return 'اكتب الاسم بالكامل كما هو في البطاقة';
        }
        if (!RegExp(r'^\d{14}$').hasMatch(draft.nationalId)) {
          return 'الرقم القومي يجب أن يكون 14 رقمًا';
        }
        if (draft.dateOfBirth == null) {
          return 'اختار تاريخ الميلاد';
        }
        return draft.phone.trim().isEmpty ? 'رقم الهاتف المؤكد مطلوب' : null;
      case 1:
        if (draft.address.trim().isEmpty) {
          return 'اكتب العنوان بشكل واضح';
        }
        return draft.governorate.isEmpty || draft.city.isEmpty
            ? 'اختار المحافظة والمدينة'
            : null;
      case 2:
        if (draft.familySize < 1 || draft.familySize > 20) {
          return 'عدد أفراد الأسرة يجب أن يكون بين 1 و20';
        }
        if (!IncomeStatusOption.all.contains(draft.incomeStatus)) {
          return 'اختار حالة الدخل';
        }
        if (!draft.useSamePhoneForPayout &&
            !RegExp(r'^01[0125][0-9]{8}$').hasMatch(draft.payoutAccount)) {
          return 'رقم فودافون كاش البديل يجب أن يكون 11 رقمًا ويبدأ بـ 01';
        }
        return null;
      case 3:
        return HealthConditionOption.all.contains(draft.healthCondition)
            ? null
            : 'اختار الحالة الصحية';
      case 4:
        return RequiredDocumentType.all.every(isDocumentUploaded)
            ? null
            : 'ارفع صورة بطاقة الرقم القومي للمتابعة';
      default:
        return null;
    }
  }

  Map<String, DocumentEntity> _documentsByType(List<DocumentEntity> documents) {
    return {for (final document in documents) document.type: document};
  }

  int _activeCasesCount(List<CaseEntity> cases) {
    return cases.where((item) {
      return item.status == CaseLifecycle.draft ||
          item.status == CaseLifecycle.pendingReview ||
          item.status == CaseLifecycle.collecting;
    }).length;
  }

  int _completedCasesCount(List<CaseEntity> cases) {
    return cases.where((item) {
      return item.status == CaseLifecycle.completed ||
          item.status == CaseLifecycle.paid;
    }).length;
  }
}
