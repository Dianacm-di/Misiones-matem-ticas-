import 'package:enciclopedia_mate/model/formula.dart';
import 'package:enciclopedia_mate/screens/pantalla1.dart';
import 'package:enciclopedia_mate/screens/pantalla2.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enciclopedia Matematica',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const InicioScreen(),
        '/listaFormulas': (context) => const ListaFormulasScreen(),
        '/detalleFormula':
            (context) => DetalleFormulaScreen(
              formula: ModalRoute.of(context)!.settings.arguments as Formula,
            ),
      },
    );
  }
}

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enciclopedia Matematica",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: Image.asset('assets/img/enciclopedia.png', height: 200),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/listaFormulas');
              },
              style: ElevatedButton.styleFrom(
                elevation: 10,
                shadowColor: Colors.blue,
                backgroundColor: Colors.blue,
              ),
              child: Text(
                "Entrar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
