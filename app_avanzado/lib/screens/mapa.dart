import 'package:flutter/material.dart';
import 'juego.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  int nivelesDesbloqueados = 1;
  int puntosTotales = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Aventuras'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                '🏆 $puntosTotales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[200]!, Colors.blue[200]!],
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.all(20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            int nivel = index + 1;
            bool desbloqueado = nivel <= nivelesDesbloqueados;

            return GestureDetector(
              onTap: desbloqueado ? () => _iniciarNivel(nivel) : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors:
                        desbloqueado
                            ? [Colors.orange[300]!, Colors.red[300]!]
                            : [Colors.grey[400]!, Colors.grey[600]!],
                  ),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconoNivel(nivel),
                      size: 50,
                      color: desbloqueado ? Colors.white : Colors.grey[300],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'NIVEL $nivel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: desbloqueado ? Colors.white : Colors.grey[300],
                      ),
                    ),
                    Text(
                      _getTematica(nivel),
                      style: TextStyle(
                        fontSize: 12,
                        color: desbloqueado ? Colors.white70 : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getIconoNivel(int nivel) {
    const iconos = [
      Icons.add,
      Icons.remove,
      Icons.close,
      Icons.pie_chart,
      Icons.architecture,
      Icons.psychology,
      Icons.percent,
      Icons.star,
    ];
    return iconos[nivel - 1];
  }

  String _getTematica(int nivel) {
    const tematicas = [
      'Suma',
      'Resta',
      'Multiplicación',
      'División',
      'Geometría',
      'Lógica',
      'Fracciones',
      'Desafío Final',
    ];
    return tematicas[nivel - 1];
  }

  void _iniciarNivel(int nivel) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JuegoScreen(nivel: nivel)),
    );

    if (resultado != null && resultado['completado']) {
      setState(() {
        puntosTotales += (resultado['puntos'] as int? ?? 0);
        if (nivel == nivelesDesbloqueados && nivel < 8) {
          nivelesDesbloqueados++;
        }
      });
    }
  }
}
