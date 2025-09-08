import 'package:flutter/material.dart';
import 'screens/inicio.dart';

void main() {
  runApp(MisionMatematica());
}

class MisionMatematica extends StatelessWidget {
  const MisionMatematica({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misión Matemática',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Comic Sans MS',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InicioScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
