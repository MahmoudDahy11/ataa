import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:ataa/features/donor/presentation/cubit/payment_method_cubit.dart';
import 'package:ataa/features/donor/presentation/cubit/payment_method_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentMethodCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('طريقة الدفع', style: AppTextStyles.bodyLarge),
        centerTitle: true,
      ),
      body: BlocListener<PaymentMethodCubit, PaymentMethodState>(
        listener: (context, state) {
          if (state is PaymentMethodError) {
            showSnakBar(context, state.message, isError: true);
          } else if (state is PaymentMethodSuccess) {
            Hive.box('app_config').put('is_registered', true);
            context.goNamed('donor_profile');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر طريقة الدفع المفضلة',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),
              _PaymentOptions(cubit: cubit),
              const Spacer(),
              _ConfirmButton(cubit: cubit),
              const SizedBox(height: 12),
              _SkipButton(cubit: cubit),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptions extends StatelessWidget {
  final PaymentMethodCubit cubit;
  const _PaymentOptions({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaymentType?>(
      valueListenable: cubit.selectedTypeNotifier,
      builder: (_, selected, _) => Column(
        children: [
          _PaymentOptionTile(
            label: 'بطاقة بنكية (Visa / Mastercard)',
            icon: Icons.credit_card,
            type: PaymentType.visa,
            selected: selected,
            onTap: () => cubit.selectType(PaymentType.visa),
          ),
          const SizedBox(height: 12),
          _PaymentOptionTile(
            label: 'فودافون كاش',
            icon: Icons.phone_android,
            type: PaymentType.vodafoneCash,
            selected: selected,
            onTap: () => cubit.selectType(PaymentType.vodafoneCash),
          ),
          if (selected == PaymentType.vodafoneCash) ...[
            const SizedBox(height: 16),
            CustomTextField(
              controller: cubit.vodafoneController,
              hintText: '01xxxxxxxxx',
              keyboardType: TextInputType.phone,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final PaymentType type;
  final PaymentType? selected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.label,
    required this.icon,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final PaymentMethodCubit cubit;
  const _ConfirmButton({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (_, state) {
        final isLoading = state is PaymentMethodLoading;
        return ValueListenableBuilder<PaymentType?>(
          valueListenable: cubit.selectedTypeNotifier,
          builder: (_, selected, _) => ValueListenableBuilder<bool>(
            valueListenable: cubit.isButtonEnabledNotifier,
            builder: (_, isEnabled, _) => Visibility(
              visible: selected != null,
              child: CustomGradientButton(
                text: 'تأكيد',
                isLoading: isLoading,
                onPressed: (isEnabled && !isLoading) ? cubit.saveMethod : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkipButton extends StatelessWidget {
  final PaymentMethodCubit cubit;
  const _SkipButton({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: cubit.saveMethod,
      child: Text(
        'تخطي الآن',
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
      ),
    );
  }
}
