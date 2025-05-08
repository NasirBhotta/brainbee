import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

enum TimeToggleOption { weekly, monthly }

class BBSegmentedToggle extends StatefulWidget {
  final Function(TimeToggleOption) onOptionSelected;
  final TimeToggleOption initialOption;
  const BBSegmentedToggle({
    super.key,
    required this.onOptionSelected,
    required this.initialOption,
  });

  @override
  State<BBSegmentedToggle> createState() => _BBSegmentedToggleState();
}

class _BBSegmentedToggleState extends State<BBSegmentedToggle> {
  late TimeToggleOption selectedOption;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedOption = widget.initialOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BBColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BBColors.borderGray, width: 1),
      ),
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildOptions(TimeToggleOption.weekly, "weekly"),
          _buildOptions(TimeToggleOption.monthly, "monthly"),
        ],
      ),
    );
  }

  Widget _buildOptions(TimeToggleOption option, String label) {
    final bool isSelected = selectedOption == option;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedOption = option;
          });
          widget.onOptionSelected(option);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: isSelected ? BBColors.black : BBColors.white,
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [BBColors.primaryColor, BBColors.secondaryColor],
                    )
                    : null,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,

          child: BBText(
            data: label,
            style: context.textStyle.labelMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: isSelected ? BBColors.white : BBColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
