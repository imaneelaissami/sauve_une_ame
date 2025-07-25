import 'package:flutter/material.dart';


class MarqueeContinuouslyScrollingText extends StatefulWidget {
  final List<String> texts;
  final TextStyle? style;
  final double velocity;
  final double gap;

  const MarqueeContinuouslyScrollingText({
    required this.texts,
    this.style,
    this.velocity = 50,
    this.gap = 50,
    Key? key,
  }) : super(key: key);

  @override
  _MarqueeContinuouslyScrollingTextState createState() =>
      _MarqueeContinuouslyScrollingTextState();
}

class _MarqueeContinuouslyScrollingTextState
    extends State<MarqueeContinuouslyScrollingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final GlobalKey _textKey = GlobalKey();
  final GlobalKey _containerKey = GlobalKey();

  double _textWidth = 0;
  double _containerWidth = 0;

  late String _combinedText;

  @override
  void initState() {
    super.initState();
    _combinedText = widget.texts.join('     ***     ');
    _controller = AnimationController(vsync: this,duration: Duration(seconds: 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  void _startAnimation() {
    if (!mounted) return;

    final RenderBox? textBox =
    _textKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? containerBox =
    _containerKey.currentContext?.findRenderObject() as RenderBox?;

    if (textBox == null || containerBox == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimation();
      });
      return;
    }

    setState(() {
      _textWidth = textBox.size.width;
      _containerWidth = containerBox.size.width;
    });

    final double startPosition = _containerWidth;
    final double endPosition = -_textWidth;
    final totalDistance = startPosition - endPosition;
    final durationSeconds = totalDistance / widget.velocity;

    _controller.duration =
        Duration(milliseconds: (durationSeconds * 1000).toInt());

    _animation = Tween<double>(begin: startPosition, end: endPosition)
        .animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.repeat();
        }
      });

    //_controller.forward(from: 0);
    if (durationSeconds > 0) {
      _controller.duration =
          Duration(milliseconds: (durationSeconds * 1000).toInt());

      _animation = Tween<double>(begin: startPosition, end: endPosition)
          .animate(_controller);

      _controller.repeat();
    } else {
      print("Erreur: la durée doit être supérieure à 0, valeur actuelle = $durationSeconds");
    }


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        key: _containerKey,
        height: 30,
        alignment: Alignment.centerLeft,
        child: _textWidth == 0
            ? Text(
          _combinedText,
          key: _textKey,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
        )
            : AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_animation.value, 0),
              child: child,
            );
          },
          child: Text(
            _combinedText,
            key: _textKey,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Color lightPink = const Color(0xFFE4CFC8);
  final Color mediumBrown = const Color(0xFFB57D7F);
  final Color darkBrown = const Color(0xFF5A1F35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink,
      body: Column(
        children: [
          // شريط النص المتحرك + padding
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Container(
              color: darkBrown,
              height: 30,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: MarqueeContinuouslyScrollingText(
                texts: [
                  'Sauvons les animaux!',
                  'لننقذ الحيوانات',
                  'Les animaux ont une âme comme nous',
                  'للحيوانات روح مثلنا',
                ],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                velocity: 50,
                gap: 50,
              ),
            ),
          ),

          // باقي الصفحة
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 70),
                margin: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                decoration: BoxDecoration(
                  color: mediumBrown.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: darkBrown.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اللوجو
                    Container(
                      height: 100,
                      child: Image.network(
                        'https://img.icons8.com/3d-fluency/94/cat.png',
                        color: darkBrown,
                        fit: BoxFit.contain,
                        width: 200,  // هنا الحجم اللي بغيتي
                        height: 200, // تقدر تخليهم نفس القيمة ولا مختلفة
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      icon: Icon(Icons.vpn_key, color: Colors.white),
                      label: Text(
                        "Se connecter", style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrown,
                        padding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      icon: Icon(Icons.person_add, color: Colors.black),
                      label: Text(
                        "Créer un compte",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
