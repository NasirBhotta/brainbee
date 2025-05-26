import 'dart:async';
import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:flutter/material.dart';

class BbSearchingPlayers extends StatefulWidget {
  const BbSearchingPlayers({super.key});

  @override
  State<BbSearchingPlayers> createState() => _BbSearchingPlayersState();
}

class _BbSearchingPlayersState extends State<BbSearchingPlayers> {
  int countdown = 15;
  late Timer _timer;
  bool isMusic = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BBText(
          data: "Start Battle",
          style: context.textStyle.titleMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: BBColors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: BBColors.borderGray)),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(12),
      height: context.screenHeight * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [BBColors.primaryColor, BBColors.secondaryColor],
          begin: Alignment(0, 1),
          end: Alignment(0, -1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  right: 20,
                  left: 10,
                  top: 10,
                  bottom: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/compass.png',
                        width: 24,
                        height: 24,
                        color: Colors.blue,
                        errorBuilder:
                            (context, error, stack) => Icon(
                              Icons.calculate,
                              color: Colors.blue[800],
                              size: 24,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BBText(
                      data: 'Mathematics',
                      style: context.textStyle.titleSmall?.copyWith(
                        color: BBColors.bodyText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon:
                      isMusic
                          ? const Icon(Icons.volume_up)
                          : const Icon(Icons.volume_off_outlined),
                  color: Colors.grey,
                  onPressed: () {
                    setState(() {
                      isMusic = !isMusic;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BBText(
                data: 'Waiting for a match',
                style: context.textStyle.bodyLarge?.copyWith(
                  color: BBColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$countdown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.screenHeight * 0.03),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayer('N', const Color(0xFF8CAA56), 'nasirbhotta'),

              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: BBText(
                    data: 'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              _buildPlayer('C', const Color(0xFFE94A76), 'waiting'),
            ],
          ),
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF6A6A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const BBText(
                      data: 'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: countdown > 0 ? null : () {},
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey.withValues(alpha: 0.2);
                        }
                        return BBColors.primaryBlue;
                      }),
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.white.withValues(alpha: 0.7),
                      ),
                      padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0),
                    ),
                    child: BBText(
                      data:
                          countdown > 0
                              ? 'Ready (00:0${countdown > 0 ? countdown : 0})'
                              : 'Ready',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(String firstLetter, Color color, String fullName) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: BBText(
              data: firstLetter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        BBText(
          data: '@$fullName',
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }
}
