// import 'package:brainbee/presentation/views/extras/Rewards/models/reward.dart';
// import 'package:flutter/material.dart';
// import 'package:brainbee/core/constants/bb_colors.dart';

// class RedemptionBottomSheet extends StatefulWidget {
//   final RewardModel reward;
//   final int currentCoins;
//   final Function(RewardModel redeemedReward, int coinsDeducted)
//   onRedemptionSuccess;

//   const RedemptionBottomSheet({
//     super.key,
//     required this.reward,
//     required this.currentCoins,
//     required this.onRedemptionSuccess,
//   });

//   @override
//   State<RedemptionBottomSheet> createState() => _RedemptionBottomSheetState();
// }

// class _RedemptionBottomSheetState extends State<RedemptionBottomSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _inputController = TextEditingController();
//   bool _isLoading = false;
//   bool _showConfirmation = false;

//   // Mock daily redemption limit (600 coins per day)
//   final int dailyRedemptionLimit = 600;
//   final int todayRedeemed = 150; // Mock value - would come from backend

//   @override
//   void dispose() {
//     _inputController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.75,
//       decoration: const BoxDecoration(
//         color: BBColors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(24),
//           topRight: Radius.circular(24),
//         ),
//       ),
//       child: _showConfirmation ? _buildConfirmationView() : _buildInputView(),
//     );
//   }

//   Widget _buildInputView() {
//     final remainingDailyLimit = dailyRedemptionLimit - todayRedeemed;
//     final canRedeemToday = widget.reward.coinPrice <= remainingDailyLimit;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Handle bar
//         Center(
//           child: Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(top: 12),
//             decoration: BoxDecoration(
//               color: BBColors.borderGray,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ),
//         // Header
//         Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [
//                           BBColors.primaryColor,
//                           BBColors.secondaryColor,
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       _getRewardIcon(),
//                       color: BBColors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Redeem ${widget.reward.title}',
//                           style: Theme.of(
//                             context,
//                           ).textTheme.titleLarge?.copyWith(
//                             color: BBColors.darkHeading,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           '${widget.reward.coinPrice} Coins',
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(color: BBColors.bodyText),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close, color: BBColors.bodyText),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               // Daily limit warning
//               if (!canRedeemToday)
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: BBColors.alertRed.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: BBColors.alertRed.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.warning_amber_rounded,
//                         color: BBColors.alertRed,
//                         size: 24,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Daily Limit Exceeded',
//                               style: Theme.of(
//                                 context,
//                               ).textTheme.titleSmall?.copyWith(
//                                 color: BBColors.alertRed,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'You can only redeem $dailyRedemptionLimit coins per day. You have $remainingDailyLimit coins remaining today.',
//                               style: Theme.of(context).textTheme.bodySmall
//                                   ?.copyWith(color: BBColors.alertRed),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               else
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: BBColors.primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: BBColors.primaryColor.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.info_outline,
//                         color: BBColors.primaryColor,
//                         size: 24,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Daily limit: $remainingDailyLimit coins remaining today',
//                           style: Theme.of(context).textTheme.bodySmall
//                               ?.copyWith(color: BBColors.primaryColor),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         // Form
//         if (canRedeemToday) ...[
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (widget.reward.requiresUserInput) ...[
//                       Text(
//                         widget.reward.inputLabel ?? 'Required Information',
//                         style: Theme.of(
//                           context,
//                         ).textTheme.titleMedium?.copyWith(
//                           color: BBColors.darkHeading,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextFormField(
//                         controller: _inputController,
//                         decoration: InputDecoration(
//                           hintText:
//                               widget.reward.inputPlaceholder ??
//                               'Enter required information',
//                           prefixIcon: Icon(
//                             _getInputIcon(),
//                             color: BBColors.bodyText,
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'This field is required';
//                           }
//                           if (widget.reward.inputLabel?.toLowerCase().contains(
//                                 'email',
//                               ) ==
//                               true) {
//                             if (!RegExp(
//                               r'^[\w-\.] @([\w-] \.) [\w-]{2,4}$',
//                             ).hasMatch(value)) {
//                               return 'Please enter a valid email address';
//                             }
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                     ],
//                     // Important note
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: BBColors.yellowAccent.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: BBColors.yellowAccent.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 color: BBColors.yellowAccent,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Important',
//                                 style: Theme.of(
//                                   context,
//                                 ).textTheme.titleSmall?.copyWith(
//                                   color: BBColors.yellowAccent,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '• Coin redemptions are non-refundable\n• Information cannot be edited after submission\n• Delivery time varies by reward type',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.bodySmall?.copyWith(
//                               color: BBColors.bodyText,
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Spacer(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Bottom button
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _proceedToConfirmation,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: BBColors.primaryColor,
//                   foregroundColor: BBColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child:
//                     _isLoading
//                         ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             color: BBColors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                         : Text(
//                           'Continue',
//                           style: Theme.of(
//                             context,
//                           ).textTheme.titleMedium?.copyWith(
//                             color: BBColors.white,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//               ),
//             ),
//           ),
//         ] else ...[
//           const Spacer(),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: BBColors.disabledText,
//                   foregroundColor: BBColors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   'Close',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: BBColors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildConfirmationView() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Handle bar
//         Center(
//           child: Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(top: 12),
//             decoration: BoxDecoration(
//               color: BBColors.borderGray,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ),
//         // Header
//         Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: BBColors.successGreen,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(
//                       Icons.check,
//                       color: BBColors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Confirm Redemption',
//                           style: Theme.of(
//                             context,
//                           ).textTheme.titleLarge?.copyWith(
//                             color: BBColors.darkHeading,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           'Review your details below',
//                           style: Theme.of(context).textTheme.bodyMedium
//                               ?.copyWith(color: BBColors.bodyText),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         // Confirmation details
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: BBColors.lightGrayBG,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildConfirmationRow('Reward', widget.reward.title),
//                       const SizedBox(height: 12),
//                       _buildConfirmationRow(
//                         'Cost',
//                         '${widget.reward.coinPrice} Coins',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildConfirmationRow(
//                         'Current Balance',
//                         '${widget.currentCoins} Coins',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildConfirmationRow(
//                         'Remaining Balance',
//                         '${widget.currentCoins - widget.reward.coinPrice} Coins',
//                         isHighlight: true,
//                       ),
//                       if (widget.reward.requiresUserInput &&
//                           _inputController.text.isNotEmpty) ...[
//                         const SizedBox(height: 12),
//                         _buildConfirmationRow(
//                           widget.reward.inputLabel ?? 'Information',
//                           _inputController.text,
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: BBColors.alertRed.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: BBColors.alertRed.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.warning_amber_rounded,
//                             color: BBColors.alertRed,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Final Warning',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.titleSmall?.copyWith(
//                               color: BBColors.alertRed,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'This action cannot be undone. Make sure all information is correct.',
//                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: BBColors.alertRed,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//               ],
//             ),
//           ),
//         ),
//         // Bottom buttons
//         Padding(
//           padding: const EdgeInsets.all(20),
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed:
//                       _isLoading
//                           ? null
//                           : () {
//                             setState(() {
//                               _showConfirmation = false;
//                             });
//                           },
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: BBColors.bodyText),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Back',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: BBColors.bodyText,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 flex: 2,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _confirmRedemption,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: BBColors.successGreen,
//                     foregroundColor: BBColors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child:
//                       _isLoading
//                           ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: BBColors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                           : Text(
//                             'Confirm Redemption',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.titleMedium?.copyWith(
//                               color: BBColors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildConfirmationRow(
//     String label,
//     String value, {
//     bool isHighlight = false,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: Theme.of(
//             context,
//           ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
//         ),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             color: isHighlight ? BBColors.successGreen : BBColors.darkHeading,
//             fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   void _proceedToConfirmation() {
//     if (widget.reward.requiresUserInput) {
//       if (!_formKey.currentState!.validate()) {
//         return;
//       }
//     }

//     setState(() {
//       _showConfirmation = true;
//     });
//   }

//   void _confirmRedemption() async {
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call
//     await Future.delayed(const Duration(seconds: 2));

//     // Create redeemed reward
//     final redeemedReward = widget.reward.copyWith(
//       status: RewardStatus.redeemed,
//       redeemedAt: DateTime.now(),
//       submittedInfo:
//           widget.reward.requiresUserInput ? _inputController.text : null,
//     );

//     // Show success dialog
//     if (mounted) {
//       await _showSuccessDialog();

//       // Call callback and close
//       widget.onRedemptionSuccess(redeemedReward, widget.reward.coinPrice);
//       Navigator.pop(context);
//       Navigator.pop(context); // Also close the detail screen
//     }
//   }

//   Future<void> _showSuccessDialog() async {
//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: BBColors.successGreen,
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: const Icon(
//                     Icons.check,
//                     color: BBColors.white,
//                     size: 40,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Redemption Successful!',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: BBColors.darkHeading,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Your ${widget.reward.title} will be processed shortly. You\'ll receive a confirmation email.',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyMedium?.copyWith(color: BBColors.bodyText),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: BBColors.successGreen,
//                       foregroundColor: BBColors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       'OK',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         color: BBColors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   IconData _getRewardIcon() {
//     switch (widget.reward.title.toLowerCase()) {
//       case 'pubg mobile uc':
//         return Icons.sports_esports;
//       case 'amazon gift card':
//         return Icons.card_giftcard;
//       case 'spotify premium':
//         return Icons.music_note;
//       case 'netflix subscription':
//         return Icons.movie;
//       case 'gaming mouse':
//         return Icons.mouse;
//       case 'discord nitro':
//         return Icons.chat;
//       default:
//         return Icons.redeem;
//     }
//   }

//   IconData _getInputIcon() {
//     final label = widget.reward.inputLabel?.toLowerCase() ?? '';
//     if (label.contains('email')) return Icons.email_outlined;
//     if (label.contains('address')) return Icons.location_on_outlined;
//     if (label.contains('id') || label.contains('username')) {
//       return Icons.person_outline;
//     }
//     return Icons.text_fields;
//   }
// }
