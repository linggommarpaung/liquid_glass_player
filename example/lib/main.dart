import 'package:flutter/material.dart';
import 'package:liquid_glass_player/liquid_glass_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            height: 450,
            child: LiquidGlassPlayer(
              videoUrl: "https://www.w3schools.com/tags/mov_bbb.mp4",
              autoPlay: true,
              showControls: true,
            ),
          ),
        ),
      ),
    );
  }
}
