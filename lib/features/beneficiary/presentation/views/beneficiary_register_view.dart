import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/document_upload_widget.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/step_indicator.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BeneficiaryRegisterView extends StatelessWidget {
  const BeneficiaryRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>(),
      child: const _BeneficiaryRegisterBody(),
    );
  }
}

class _BeneficiaryRegisterBody extends StatelessWidget {
  const _BeneficiaryRegisterBody();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            showSnakBar(context, state.errorMessage!, isError: true);
          } else if (state.successMessage != null) {
            showSnakBar(context, state.successMessage!);
            if (state.profile != null) {
              context.go('/beneficiary/dashboard');
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<BeneficiaryCubit>();
          final canContinue =
              cubit.canContinueRegistration() &&
              !state.isSubmittingRegistration;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('تسجيل مستفيد')),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  StepIndicator(currentStep: state.currentStep, totalSteps: 5),
                  const SizedBox(height: 18),
                  _StepHeader(step: state.currentStep),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    child: _RegistrationStep(
                      key: ValueKey(state.currentStep),
                      state: state,
                      onDraftChanged: cubit.saveRegistrationStep,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.96),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (state.currentStep > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              cubit.goToStep(state.currentStep - 1),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('رجوع'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    if (state.currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomGradientButton(
                        text: state.currentStep == 4 ? 'إرسال الطلب' : 'التالي',
                        isLoading: state.isSubmittingRegistration,
                        onPressed: canContinue
                            ? cubit.continueRegistration
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int step;

  const _StepHeader({required this.step});

  @override
  Widget build(BuildContext context) {
    final data = _StepCopy.items[step];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  data.helper,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${step + 1}/5',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationStep extends StatelessWidget {
  final BeneficiaryState state;
  final ValueChanged<RegistrationDraft> onDraftChanged;

  const _RegistrationStep({
    super.key,
    required this.state,
    required this.onDraftChanged,
  });

  @override
  Widget build(BuildContext context) {
    final draft = state.registrationDraft;
    switch (state.currentStep) {
      case 0:
        return _CardSection(
          children: [
            _LabeledField(
              label: 'الاسم بالكامل',
              helper: 'كما هو مكتوب في بطاقة الرقم القومي',
              child: CustomTextField(
                hintText: 'مثال: محمود أحمد علي',
                prefixIcon: Icons.person_outline_rounded,
                initialValue: draft.fullName,
                onChanged: (value) =>
                    onDraftChanged(draft.copyWith(fullName: value)),
              ),
            ),
            _LabeledField(
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
                onChanged: (value) =>
                    onDraftChanged(draft.copyWith(nationalId: value)),
                decoration: _inputDecoration(
                  hintText: '14 رقم',
                  icon: Icons.credit_card_rounded,
                  counterText: '',
                ),
              ),
            ),
            _DatePickerTile(
              date: draft.dateOfBirth,
              onTap: () => _pickDate(context, draft),
            ),
            _LabeledField(
              label: 'رقم الهاتف',
              helper: 'تم تأكيده مسبقًا لحماية حسابك',
              isValid: draft.phone.trim().isNotEmpty,
              child: CustomTextField(
                hintText: 'رقم الهاتف المؤكد',
                prefixIcon: Icons.verified_user_outlined,
                initialValue: draft.phone,
                readOnly: true,
              ),
            ),
          ],
        );
      case 1:
        final cityOptions =
            BeneficiaryOptions.citiesByGovernorate[draft.governorate] ??
            const <String>[];
        return _CardSection(
          children: [
            _LabeledField(
              label: 'العنوان التفصيلي',
              helper: 'نحتاجه للوصول للحالة عند المراجعة',
              child: CustomTextField(
                hintText: 'الشارع، رقم المنزل، علامة مميزة',
                prefixIcon: Icons.home_outlined,
                initialValue: draft.address,
                onChanged: (value) =>
                    onDraftChanged(draft.copyWith(address: value)),
              ),
            ),
            _LabeledField(
              label: 'المحافظة',
              helper: 'اختيارات محددة لتقليل الأخطاء',
              isValid: draft.governorate.isNotEmpty,
              child: DropdownButtonFormField<String>(
                initialValue: draft.governorate.isEmpty
                    ? null
                    : draft.governorate,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: _inputDecoration(
                  hintText: 'اختار المحافظة',
                  icon: Icons.map_outlined,
                ),
                items: BeneficiaryOptions.governorates
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(_governorateLabel(value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  final nextGovernorate = value ?? '';
                  final nextCityOptions =
                      BeneficiaryOptions.citiesByGovernorate[nextGovernorate] ??
                      const [];
                  final nextCity = nextCityOptions.contains(draft.city)
                      ? draft.city
                      : '';
                  onDraftChanged(
                    draft.copyWith(
                      governorate: nextGovernorate,
                      city: nextCity,
                    ),
                  );
                },
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _LabeledField(
                key: ValueKey(draft.governorate),
                label: 'المدينة',
                helper: draft.governorate.isEmpty
                    ? 'اختار المحافظة أولًا'
                    : 'المدن تظهر حسب المحافظة',
                isValid: draft.city.isNotEmpty,
                child: DropdownButtonFormField<String>(
                  initialValue: draft.city.isEmpty ? null : draft.city,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: _inputDecoration(
                    hintText: 'اختار المدينة',
                    icon: Icons.location_city_outlined,
                  ),
                  items: cityOptions
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: cityOptions.isEmpty
                      ? null
                      : (value) =>
                            onDraftChanged(draft.copyWith(city: value ?? '')),
                ),
              ),
            ),
          ],
        );
      case 2:
        return _CardSection(
          children: [
            const Text('عدد أفراد الأسرة', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'اختر العدد الأقرب للوضع الحالي',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            _FamilySizeSelector(
              value: draft.familySize,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(familySize: value)),
            ),
            const SizedBox(height: 24),
            _SelectionGrid(
              title: 'حالة الدخل',
              value: draft.incomeStatus,
              options: const [
                _SelectionOption(
                  value: IncomeStatusOption.none,
                  title: 'لا يوجد دخل',
                  subtitle: 'لا يوجد مصدر ثابت حاليًا',
                  icon: Icons.money_off_csred_rounded,
                ),
                _SelectionOption(
                  value: IncomeStatusOption.low,
                  title: 'دخل منخفض',
                  subtitle: 'الدخل لا يغطي الاحتياجات',
                  icon: Icons.trending_down_rounded,
                ),
                _SelectionOption(
                  value: IncomeStatusOption.middle,
                  title: 'دخل متوسط',
                  subtitle: 'يوجد دخل لكنه غير كافٍ',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ],
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(incomeStatus: value)),
            ),
          ],
        );
      case 3:
        return _CardSection(
          children: [
            _SelectionGrid(
              title: 'الحالة الصحية',
              value: draft.healthCondition,
              options: const [
                _SelectionOption(
                  value: HealthConditionOption.healthy,
                  title: 'سليم',
                  subtitle: 'لا توجد حالة صحية مؤثرة',
                  icon: Icons.favorite_rounded,
                ),
                _SelectionOption(
                  value: HealthConditionOption.chronic,
                  title: 'مرض مزمن',
                  subtitle: 'احتياج صحي مستمر أو علاج دوري',
                  icon: Icons.medical_services_outlined,
                ),
                _SelectionOption(
                  value: HealthConditionOption.disability,
                  title: 'إعاقة',
                  subtitle: 'احتياج دعم أو رعاية خاصة',
                  icon: Icons.accessible_forward_rounded,
                ),
              ],
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(healthCondition: value)),
            ),
          ],
        );
      default:
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
}

class _CardSection extends StatelessWidget {
  final List<Widget> children;

  const _CardSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String helper;
  final Widget child;
  final bool? isValid;

  const _LabeledField({
    super.key,
    required this.label,
    required this.helper,
    required this.child,
    this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final valid = isValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.titleLarge)),
            if (valid != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  valid
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  key: ValueKey(valid),
                  color: valid ? AppColors.primary : AppColors.textHint,
                  size: 22,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          helper,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valid == false ? AppColors.error : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerTile({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = date != null;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تاريخ الميلاد', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 3),
                  Text(
                    selected ? _formatDate(date!) : 'اختار التاريخ',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.touch_app_rounded,
              color: selected ? AppColors.primary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilySizeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _FamilySizeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperButton(
                icon: Icons.add_rounded,
                onTap: value < 20 ? () => onChanged(value + 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    '$value',
                    key: ValueKey(value),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.remove_rounded,
                onTap: value > 1 ? () => onChanged(value - 1) : null,
              ),
            ],
          ),
          Slider(
            min: 1,
            max: 20,
            divisions: 19,
            value: value.clamp(1, 20).toDouble(),
            onChanged: (next) => onChanged(next.round()),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.textHint.withValues(alpha: 0.20),
      ),
    );
  }
}

class _SelectionGrid extends StatelessWidget {
  final String title;
  final String value;
  final List<_SelectionOption> options;
  final ValueChanged<String> onChanged;

  const _SelectionGrid({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const SizedBox(height: 12),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectionCard(
              option: option,
              selected: value == option.value,
              onTap: () => onChanged(option.value),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final _SelectionOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.09)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.05),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                option.icon,
                color: selected ? AppColors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              scale: selected ? 1 : 0.75,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionOption {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;

  const _SelectionOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _StepCopy {
  final String title;
  final String helper;
  final IconData icon;

  const _StepCopy({
    required this.title,
    required this.helper,
    required this.icon,
  });

  static const items = <_StepCopy>[
    _StepCopy(
      title: 'بياناتك الأساسية',
      helper: 'نراجع الهوية بدون تعقيد أو أسئلة زائدة',
      icon: Icons.person_search_rounded,
    ),
    _StepCopy(
      title: 'العنوان',
      helper: 'اختيارات واضحة تساعد فريق المراجعة',
      icon: Icons.location_on_outlined,
    ),
    _StepCopy(
      title: 'الأسرة والدخل',
      helper: 'اختر الأقرب لوضعك الحالي بضغطة واحدة',
      icon: Icons.family_restroom_rounded,
    ),
    _StepCopy(
      title: 'الحالة الصحية',
      helper: 'بدون كتابة تفاصيل حساسة، اختيارات محترمة فقط',
      icon: Icons.health_and_safety_outlined,
    ),
    _StepCopy(
      title: 'التحقق من الهوية',
      helper: 'مستند واحد فقط: بطاقة الرقم القومي',
      icon: Icons.verified_outlined,
    ),
  ];
}

InputDecoration _inputDecoration({
  required String hintText,
  required IconData icon,
  String? counterText,
}) {
  return InputDecoration(
    hintText: hintText,
    counterText: counterText,
    prefixIcon: Icon(icon, color: AppColors.primary),
    filled: true,
    fillColor: AppColors.surface,
    border: _inputBorder(),
    enabledBorder: _inputBorder(),
    focusedBorder: _inputBorder(AppColors.primary),
  );
}

OutlineInputBorder _inputBorder([Color color = Colors.transparent]) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: 1.5),
  );
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
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
