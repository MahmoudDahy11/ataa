import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/document_upload_widget.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/registration_card_section.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegistrationStep extends StatelessWidget {
  final BeneficiaryState state;
  final ValueChanged<RegistrationDraft> onDraftChanged;

  const RegistrationStep({
    super.key,
    required this.state,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    final draft = state.registrationDraft;
    switch (state.currentStep) {
      case 0:
        return _buildStep0(context, draft);
      case 1:
        return _buildStep1(draft);
      case 2:
        return _buildStep2(draft);
      case 3:
        return _buildStep3(draft);
      default:
        return _buildStep4(state, context);
    }
  }

  Widget _buildStep0(BuildContext context, RegistrationDraft draft) {
    return CardSection(
      children: [
        LabeledField(
          label: 'الاسم بالكامل',
          helper: 'كما هو مكتوب في بطاقة الرقم القومي',
          child: CustomTextField(
            hintText: 'مثال: محمود أحمد علي',
            prefixIcon: Icons.person_outline_rounded,
            initialValue: draft.fullName,
            onChanged: (value) => onDraftChanged(draft.copyWith(fullName: value)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
              if (value.trim().split(' ').length < 3) return 'الرجاء إدخال الاسم ثلاثي على الأقل';
              return null;
            },
          ),
        ),
        LabeledField(
          label: 'الرقم القومي',
          helper: _nationalIdHelper(draft.nationalId),
          isValid: RegExp(r'^\d{14}$').hasMatch(draft.nationalId),
          child: TextFormField(
            initialValue: draft.nationalId,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            maxLength: 14,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
            ],
            onChanged: (value) => onDraftChanged(draft.copyWith(nationalId: value)),
            decoration: inputDecoration(
              hintText: '14 رقم',
              icon: Icons.credit_card_rounded,
              counterText: '',
            ),
          ),
        ),
        DatePickerTile(
          date: draft.dateOfBirth,
          onTap: () => _pickDate(context, draft),
        ),
        LabeledField(
          label: 'رقم الهاتف',
          helper: 'رقم التواصل الأساسي المؤكد',
          isValid: draft.phone.isNotEmpty,
          child: CustomTextField(
            hintText: '11 رقم',
            prefixIcon: Icons.verified_user_outlined,
            initialValue: draft.phone,
            readOnly: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(RegistrationDraft draft) {
    final cityOptions = BeneficiaryOptions.citiesByGovernorate[draft.governorate] ?? const <String>[];
    return CardSection(
      children: [
        LabeledField(
          label: 'العنوان التفصيلي',
          helper: 'نحتاجه للوصول للحالة عند المراجعة',
          child: CustomTextField(
            hintText: 'الشارع، رقم المنزل، علامة مميزة',
            prefixIcon: Icons.home_outlined,
            initialValue: draft.address,
            onChanged: (value) => onDraftChanged(draft.copyWith(address: value)),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
              if (value.trim().length < 10) return 'يرجى إدخال عنوان مفصل';
              return null;
            },
          ),
        ),
        LabeledField(
          label: 'المحافظة',
          helper: 'اختيارات محددة لتقليل الأخطاء',
          isValid: draft.governorate.isNotEmpty,
          child: DropdownButtonFormField<String>(
            initialValue: draft.governorate.isEmpty ? null : draft.governorate,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: inputDecoration(
              hintText: 'اختار المحافظة',
              icon: Icons.map_outlined,
            ),
            items: BeneficiaryOptions.governorates
                .map((value) => DropdownMenuItem(value: value, child: Text(_governorateLabel(value))))
                .toList(),
            onChanged: (value) {
              final nextGovernorate = value ?? '';
              final nextCityOptions = BeneficiaryOptions.citiesByGovernorate[nextGovernorate] ?? const [];
              final nextCity = nextCityOptions.contains(draft.city) ? draft.city : '';
              onDraftChanged(draft.copyWith(governorate: nextGovernorate, city: nextCity));
            },
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: LabeledField(
            key: ValueKey(draft.governorate),
            label: 'المدينة',
            helper: draft.governorate.isEmpty ? 'اختار المحافظة أولًا' : 'المدن تظهر حسب المحافظة',
            isValid: draft.city.isNotEmpty,
            child: DropdownButtonFormField<String>(
              initialValue: draft.city.isEmpty ? null : draft.city,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              decoration: inputDecoration(
                hintText: 'اختار المدينة',
                icon: Icons.location_city_outlined,
              ),
              items: cityOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
              onChanged: cityOptions.isEmpty ? null : (value) => onDraftChanged(draft.copyWith(city: value ?? '')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(RegistrationDraft draft) {
    return CardSection(
      children: [
        const Text('عدد أفراد الأسرة', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'اختر العدد الأقرب للوضع الحالي',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        FamilySizeSelector(
          value: draft.familySize,
          onChanged: (value) => onDraftChanged(draft.copyWith(familySize: value)),
        ),
        const SizedBox(height: 24),
        SelectionGridWidget(
          title: 'حالة الدخل',
          value: draft.incomeStatus,
          options: const [
            SelectionOptionModel(
              value: IncomeStatusOption.none,
              title: 'لا يوجد دخل',
              subtitle: 'لا يوجد مصدر ثابت حاليًا',
              icon: Icons.money_off_csred_rounded,
            ),
            SelectionOptionModel(
              value: IncomeStatusOption.low,
              title: 'دخل منخفض',
              subtitle: 'الدخل لا يغطي الاحتياجات',
              icon: Icons.trending_down_rounded,
            ),
            SelectionOptionModel(
              value: IncomeStatusOption.middle,
              title: 'دخل متوسط',
              subtitle: 'يوجد دخل لكنه غير كافٍ',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
          onChanged: (value) => onDraftChanged(draft.copyWith(incomeStatus: value)),
        ),
        const Divider(height: 32),
        const Text('تحويل المستحقات (فودافون كاش)', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'هل تريد استخدام رقم الهاتف المسجل به لاستلام المساعدات؟',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ChoiceChipWidget(
                label: 'نعم، نفس الرقم',
                selected: draft.useSamePhoneForPayout,
                onTap: () => onDraftChanged(draft.copyWith(useSamePhoneForPayout: true, payoutAccount: '')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChipWidget(
                label: 'لا، رقم آخر',
                selected: !draft.useSamePhoneForPayout,
                onTap: () => onDraftChanged(draft.copyWith(useSamePhoneForPayout: false)),
              ),
            ),
          ],
        ),
        if (!draft.useSamePhoneForPayout) ...[
          const SizedBox(height: 20),
          LabeledField(
            label: 'رقم فودافون كاش البديل',
            helper: 'يجب أن يكون الرقم مسجلاً به خدمة فودافون كاش',
            isValid: RegExp(r'^01[0125][0-9]{8}$').hasMatch(draft.payoutAccount),
            child: CustomTextField(
              hintText: 'مثال: 01XXXXXXXXX',
              prefixIcon: Icons.account_balance_wallet_outlined,
              initialValue: draft.payoutAccount,
              keyboardType: TextInputType.phone,
              onChanged: (value) => onDraftChanged(draft.copyWith(payoutAccount: value)),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null; // Only validated when not empty
                if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value.trim())) {
                  return 'يجب أن يكون الرقم 11 رقمًا ويبدأ بـ 01';
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3(RegistrationDraft draft) {
    return CardSection(
      children: [
        SelectionGridWidget(
          title: 'الحالة الصحية',
          value: draft.healthCondition,
          options: const [
            SelectionOptionModel(
              value: HealthConditionOption.healthy,
              title: 'سليم',
              subtitle: 'لا توجد حالة صحية مؤثرة',
              icon: Icons.favorite_rounded,
            ),
            SelectionOptionModel(
              value: HealthConditionOption.chronic,
              title: 'مرض مزمن',
              subtitle: 'احتياج صحي مستمر أو علاج دوري',
              icon: Icons.medical_services_outlined,
            ),
            SelectionOptionModel(
              value: HealthConditionOption.disability,
              title: 'إعاقة',
              subtitle: 'احتياج دعم أو رعاية خاصة',
              icon: Icons.accessible_forward_rounded,
            ),
          ],
          onChanged: (value) => onDraftChanged(draft.copyWith(healthCondition: value)),
        ),
      ],
    );
  }

  Widget _buildStep4(BeneficiaryState state, BuildContext context) {
    const type = RequiredDocumentType.idCard;
    final uploadedDocument = state.uploadedDocumentsByType[type];
    return BlocProvider<UploadCubit>(
      create: (_) => sl<UploadCubit>(),
      child: DocumentUploadWidget(
        documentType: type,
        label: 'ارفع بطاقة الرقم القومي',
        helperText: 'تساعدنا الصورة في التحقق من الحالة بسرعة وأمان',
        uploadedFileName: uploadedDocument?.fileName,
        isUploaded: uploadedDocument != null,
        onUploaded: context.read<BeneficiaryCubit>().saveUploadedDocument,
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, RegistrationDraft draft) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: now,
      initialDate: draft.dateOfBirth ?? DateTime(now.year - 25),
      helpText: 'اختار تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (selected != null && context.mounted) {
      onDraftChanged(draft.copyWith(dateOfBirth: selected));
    }
  }

  String _nationalIdHelper(String nationalId) {
    if (nationalId.isEmpty) {
      return 'سنستخدمه للتحقق فقط، ولن يظهر للمتبرعين';
    }
    if (nationalId.length < 14) {
      return 'متبقي ${14 - nationalId.length} رقم';
    }
    if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) {
      return 'الرقم القومي يجب أن يكون 14 رقمًا';
    }
    return 'الرقم مكتمل';
  }

  String _governorateLabel(String value) {
    const labels = <String, String>{
      'Cairo': 'القاهرة',
      'Giza': 'الجيزة',
      'Alexandria': 'الإسكندرية',
      'Dakahlia': 'الدقهلية',
      'Red Sea': 'البحر الأحمر',
      'Beheira': 'البحيرة',
      'Fayoum': 'الفيوم',
      'Gharbia': 'الغربية',
      'Ismailia': 'الإسماعيلية',
      'Menofia': 'المنوفية',
      'Minya': 'المنيا',
      'Qalyubia': 'القليوبية',
      'New Valley': 'الوادي الجديد',
      'Suez': 'السويس',
      'Aswan': 'أسوان',
      'Assiut': 'أسيوط',
      'Beni Suef': 'بني سويف',
      'Port Said': 'بورسعيد',
      'Damietta': 'دمياط',
      'Sharqia': 'الشرقية',
      'South Sinai': 'جنوب سيناء',
      'Kafr El Sheikh': 'كفر الشيخ',
      'Matrouh': 'مطروح',
      'Luxor': 'الأقصر',
      'Qena': 'قنا',
      'North Sinai': 'شمال سيناء',
      'Sohag': 'سوهاج',
    };
    return labels[value] ?? value;
  }
}
