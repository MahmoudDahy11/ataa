import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/form_widgets.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/selection_widgets.dart';
import 'package:flutter/material.dart';

class PersonalInfoSection extends StatelessWidget {
  final RegistrationDraft draft;
  final Function(RegistrationDraft) onChanged;

  const PersonalInfoSection({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'المعلومات الشخصية'),
        FormLabeledField(
          label: 'الاسم بالكامل',
          child: CustomTextField(
            hintText: 'أدخل الاسم بالكامل',
            initialValue: draft.fullName,
            onChanged: (v) => onChanged(draft.copyWith(fullName: v)),
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              if (value.trim().split(' ').length < 3) {
                return 'الرجاء إدخال الاسم ثلاثي على الأقل';
              }
              return null;
            },
          ),
        ),
        FormLabeledField(
          label: 'العنوان بالتفصيل',
          child: CustomTextField(
            hintText: 'أدخل العنوان بالتفصيل',
            initialValue: draft.address,
            onChanged: (v) => onChanged(draft.copyWith(address: v)),
            prefixIcon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'هذا الحقل مطلوب';
              }
              if (value.trim().length < 10) return 'يرجى إدخال عنوان مفصل';
              return null;
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FormLabeledField(
                label: 'المحافظة',
                child: CustomTextField(
                  hintText: 'المحافظة',
                  initialValue: draft.governorate,
                  onChanged: (v) => onChanged(draft.copyWith(governorate: v)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FormLabeledField(
                label: 'المدينة',
                child: CustomTextField(
                  hintText: 'المدينة',
                  initialValue: draft.city,
                  onChanged: (v) => onChanged(draft.copyWith(city: v)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FinancialInfoSection extends StatelessWidget {
  final RegistrationDraft draft;
  final Function(RegistrationDraft) onChanged;

  const FinancialInfoSection({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'الحالة المادية والاجتماعية'),
        FormLabeledField(
          label: 'عدد أفراد الأسرة',
          child: CustomTextField(
            hintText: '0',
            initialValue: draft.familySize.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                onChanged(draft.copyWith(familySize: int.tryParse(v) ?? 1)),
            prefixIcon: Icons.family_restroom_outlined,
          ),
        ),
        SelectionGrid<String>(
          title: 'الحالة الصحية',
          value: draft.healthCondition,
          options: const [
            SelectionOption(
              value: HealthConditionOption.healthy,
              title: 'سليم',
              subtitle: 'لا توجد حالة صحية مؤثرة',
              icon: Icons.favorite_rounded,
            ),
            SelectionOption(
              value: HealthConditionOption.chronic,
              title: 'مرض مزمن',
              subtitle: 'احتياج صحي مستمر أو علاج دوري',
              icon: Icons.medical_services_outlined,
            ),
          ],
          onChanged: (v) => onChanged(draft.copyWith(healthCondition: v)),
        ),
        const SizedBox(height: 16),
        SelectionGrid<String>(
          title: 'مصدر الدخل',
          value: draft.incomeStatus,
          options: const [
            SelectionOption(
              value: IncomeStatusOption.none,
              title: 'بدون دخل',
              subtitle: 'لا يوجد مصدر دخل ثابت حالياً',
              icon: Icons.money_off_rounded,
            ),
            SelectionOption(
              value: IncomeStatusOption.low,
              title: 'دخل غير ثابت',
              subtitle: 'أعمال حرة أو يومية غير منتظمة',
              icon: Icons.trending_down_rounded,
            ),
          ],
          onChanged: (v) => onChanged(draft.copyWith(incomeStatus: v)),
        ),
        const SizedBox(height: 16),
        FormLabeledField(
          label: 'رقم فودافون كاش للاستلام',
          helper: 'يمكنك تغيير الرقم الذي ستصلك عليه الحوالات',
          child: CustomTextField(
            hintText: 'مثال: 01XXXXXXXXX',
            initialValue: draft.payoutAccount.isNotEmpty
                ? draft.payoutAccount
                : draft.phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) => onChanged(
              draft.copyWith(payoutAccount: v, useSamePhoneForPayout: false),
            ),
            prefixIcon: Icons.account_balance_wallet_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value.trim())) {
                return 'يجب أن يكون الرقم 11 رقمًا ويبدأ بـ 01';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
