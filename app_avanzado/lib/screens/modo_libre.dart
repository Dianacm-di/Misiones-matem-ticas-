import 'package:flutter/material.dart';
import 'juego.dart';

class ModoLibreScreen extends StatefulWidget {
  const ModoLibreScreen({super.key});

  @override
  _ModoLibreScreenState createState() => _ModoLibreScreenState();
}

class _ModoLibreScreenState extends State<ModoLibreScreen> {
  String temaSeleccionado = 'Suma';
  String dificultadSeleccionada = 'Fácil';

  final List<String> temas = [
    'Suma',
    'Resta',
    'Multiplicación',
    'División',
    'Geometría',
    'Lógica',
    'Fracciones',
    'Mixto',
  ];

  final List<String> dificultades = ['Fácil', 'Medio', 'Difícil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modo Libre'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[200]!, Colors.teal[200]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona el Tema:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children:
                            temas
                                .map(
                                  (tema) => FilterChip(
                                    label: Text(tema),
                                    selected: temaSeleccionado == tema,
                                    onSelected: (selected) {
                                      setState(() {
                                        temaSeleccionado = tema;
                                      });
                                    },
                                    selectedColor: Colors.green[300],
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona la Dificultad:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children:
                            dificultades
                                .map(
                                  (dif) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      child: FilterChip(
                                        label: Text(dif),
                                        selected: dificultadSeleccionada == dif,
                                        onSelected: (selected) {
                                          setState(() {
                                            dificultadSeleccionada = dif;
                                          });
                                        },
                                        selectedColor: _getColorDificultad(dif),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  int nivelEquivalente = _getNivelEquivalente();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => JuegoScreen(
                            nivel: nivelEquivalente,
                            modoLibre: true,
                            tema: temaSeleccionado,
                            dificultad: dificultadSeleccionada,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'COMENZAR JUEGO',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorDificultad(String dificultad) {
    switch (dificultad) {
      case 'Fácil':
        return Colors.green[300]!;
      case 'Medio':
        return Colors.orange[300]!;
      case 'Difícil':
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  int _getNivelEquivalente() {
    int baseNivel = temas.indexOf(temaSeleccionado) + 1;
    if (baseNivel > 8) baseNivel = 8;
    return baseNivel;
  }
}
