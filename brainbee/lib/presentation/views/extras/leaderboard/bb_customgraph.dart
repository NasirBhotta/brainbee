import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/presentation/views/extras/leaderboard/bb_leaderboard.dart';
import 'package:flutter/material.dart';

class PodiumScreen extends StatefulWidget {
  final List<LeaderboardEntry>? data;
  const PodiumScreen({super.key, required this.data});

  @override
  // ignore: library_private_types_in_public_api
  _PodiumScreenState createState() => _PodiumScreenState();
}

class _PodiumScreenState extends State<PodiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1, _animation2, _animation3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation1 = Tween<double>(begin: 0, end: 180).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _animation2 = Tween<double>(begin: 0, end: 140).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _animation3 = Tween<double>(begin: 0, end: 120).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SizedBox(
        height: context.screenHeight * 0.5,
        child: Column(
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildAnimatedPodiumTile(
                  widget.data![1].name,
                  widget.data![1].score,
                  "🇫🇷",
                  widget.data![1].position,
                  1,
                  _animation2,
                ),
                buildAnimatedPodiumTile(
                  widget.data![0].name,
                  widget.data![0].score,
                  "🇵🇹",
                  widget.data![0].position,
                  2,
                  _animation1,
                  isWinner: true,
                ),
                buildAnimatedPodiumTile(
                  widget.data![2].name,
                  widget.data![2].score,
                  "🇨🇦",
                  widget.data![2].position,
                  3,
                  _animation3,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildAnimatedPodiumTile(
    String name,
    int score,
    String flag,
    int position,
    int number,
    Animation<double> animation, {
    bool isWinner = false,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return buildPodiumTile(
          name,
          score,
          flag,
          position,
          number,
          animation.value,
        );
      },
    );
  }

  Widget buildPodiumTile(
    String name,
    int score,
    String flag,
    int position,
    int number,
    double height, {
    bool isWinner = false,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          child: Text(flag, style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(100, height),
              painter: PodiumPainter(
                color: [BBColors.podiumColor1, BBColors.podiumColor2],
                num: number,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: Center(
                child: BBText(
                  data: "$position",
                  style: context.textStyle.displayLarge?.copyWith(
                    fontSize:
                        number == 1
                            ? 50
                            : number == 2
                            ? 60
                            : 40,
                    color: BBColors.white,
                  ),
                ),
              ),
            ),
            // if (isWinner)
            //   const Positioned(
            //     top: -30,
            //     child: Icon(Icons.emoji_events, color: Colors.amber, size: 30),
            //   ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.diamond, color: Colors.blue, size: 16),
            const SizedBox(width: 4),

            Text("$score", style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class PodiumPainter extends CustomPainter {
  final List<Color> color;
  final int num;
  PodiumPainter({required this.color, required this.num});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Front face
    Path front = Path();
    front.moveTo(0, size.height * 0.3);
    front.lineTo(size.width, size.height * 0.3);
    front.lineTo(size.width, size.height);
    front.lineTo(0, size.height);
    front.close();
    paint.color = num == 1 || num == 3 ? color[1] : color[0];
    canvas.drawPath(front, paint);

    // Right side
    // Path right = Path();
    // right.moveTo(size.width, size.height * 0.3);
    // right.lineTo(size.width * 1.1, size.height * 0.2);
    // right.lineTo(size.width * 1.1, size.height);
    // right.lineTo(size.width, size.height);
    // right.close();
    // paint.color = darken(color, 0.1);
    // canvas.drawPath(right, paint);

    double sideWidthTopRightCorner =
        num == 1
            ? size.width * 1
            : num == 3
            ? size.width * 0.9
            : size.width * 0.9;

    double sideWidthTopLeftCorer =
        num == 3 ? size.width * 0.0005 : size.width * 0.12;
    // Top face
    Path top = Path();
    top.moveTo(0, size.height * 0.3);
    top.lineTo(size.width, size.height * 0.3);
    top.lineTo(sideWidthTopRightCorner, size.height * 0.208);
    top.lineTo(sideWidthTopLeftCorer, size.height * 0.205);
    top.close();
    paint.color = lighten(num == 1 || num == 3 ? color[1] : color[0]);
    canvas.drawPath(top, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  Color darken(Color color, [double amount = .1]) => Color.fromRGBO(
    (color.red * (1 - amount)).round(),
    (color.green * (1 - amount)).round(),
    (color.blue * (1 - amount)).round(),
    1,
  );

  Color lighten(Color color, [double amount = .25]) => Color.fromRGBO(
    color.red + ((255 - color.red) * amount).round(),
    color.green + ((255 - color.green) * amount).round(),
    color.blue + ((255 - color.blue) * amount).round(),
    1,
  );
}
