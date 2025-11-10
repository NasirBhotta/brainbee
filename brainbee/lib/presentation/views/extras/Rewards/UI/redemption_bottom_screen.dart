import 'package:brainbee/presentation/views/extras/Rewards/models/reward.dart';
import 'package:brainbee/presentation/views/extras/Rewards/bloc/reward_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';

class RedemptionBottomSheet extends StatefulWidget {
  final RewardModel reward;
  final int currentCoins;

  const RedemptionBottomSheet({
    super.key,
    required this.reward,
    required this.currentCoins,
  });

  @override
  State<RedemptionBottomSheet> createState() => _RedemptionBottomSheetState();
}

class _RedemptionBottomSheetState extends State<RedemptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  bool _isProcessing = false;
  bool _showConfirmation = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child:
              _showConfirmation ? _buildConfirmationView() : _buildInputView(),
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: BBText(
                  data: 'Redeem ${widget.reward.title}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BBColors.darkHeading,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BBColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BBText(
                      data: 'Cost',
                      style: TextStyle(fontSize: 14, color: BBColors.bodyText),
                    ),
                    BBText(
                      data: '${widget.reward.coinPrice} Coins',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BBColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const BBText(
                      data: 'Your Balance',
                      style: TextStyle(fontSize: 14, color: BBColors.bodyText),
                    ),
                    BBText(
                      data: '${widget.currentCoins} Coins',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BBColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (widget.reward.requiresUserInput) ...[
            BBText(
              data: widget.reward.inputLabel ?? 'Required Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: BBColors.darkHeading,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: widget.reward.inputPlaceholder ?? 'Enter information',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: BBColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: BBColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BBColors.alertRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BBColors.alertRed.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: BBColors.alertRed, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: BBText(
                    data:
                        'Redemptions are non-refundable. Please verify your information.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: BBColors.alertRed),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isProcessing
                      ? null
                      : () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _showConfirmation = true);
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: BBColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const BBText(
                data: 'Continue',
                style: TextStyle(
                  color: BBColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: BBText(
                data: 'Confirm Redemption',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BBColors.darkHeading,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BBColors.lightGrayBG,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfirmationRow('Reward', widget.reward.title),
              const Divider(height: 20),
              _buildConfirmationRow('Cost', '${widget.reward.coinPrice} Coins'),
              const Divider(height: 20),
              _buildConfirmationRow(
                'Balance After',
                '${widget.currentCoins - widget.reward.coinPrice} Coins',
              ),
              if (widget.reward.requiresUserInput) ...[
                const Divider(height: 20),
                _buildConfirmationRow(
                  widget.reward.inputLabel ?? 'Information',
                  _inputController.text,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _isProcessing
                        ? null
                        : () => setState(() => _showConfirmation = false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: BBColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const BBText(
                  data: 'Back',
                  style: TextStyle(
                    color: BBColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleRedeem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BBColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isProcessing
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              BBColors.white,
                            ),
                          ),
                        )
                        : const BBText(
                          data: 'Confirm',
                          style: TextStyle(
                            color: BBColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BBText(
          data: label,
          style: const TextStyle(color: BBColors.bodyText, fontSize: 14),
        ),
        BBText(
          data: value,
          style: const TextStyle(
            color: BBColors.darkHeading,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleRedeem() {
    print("It is clicked");
    setState(() => _isProcessing = true);

    context.read<RewardBloc>().add(
      RedeemRewardEvent(
        rewardId: widget.reward.id,
        userInput:
            widget.reward.requiresUserInput
                ? _inputController.text.trim()
                : null,
      ),
    );

    // Close bottom sheet after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
