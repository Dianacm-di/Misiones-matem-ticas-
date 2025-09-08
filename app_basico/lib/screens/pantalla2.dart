import 'package:enciclopedia_mate/model/formula.dart';
import 'package:flutter/material.dart';

class DetalleFormulaScreen extends StatefulWidget {
  final Formula formula;

  const DetalleFormulaScreen({super.key, required this.formula});

  @override
  State<DetalleFormulaScreen> createState() => _DetalleFormulaScreenState();
}

class _DetalleFormulaScreenState extends State<DetalleFormulaScreen> {
  bool __verEjemplo = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formula.nombre,
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(widget.formula.imagen, height: 200),
            const SizedBox(height: 20),
            Text(
              widget.formula.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(widget.formula.descripcion),
            const SizedBox(height: 20),
            //boton para mostrar/ocultar el ejemplo
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    __verEjemplo =
                        !__verEjemplo; // Cambia el estado de visibilidad
                  });
                },
                icon: Icon(
                  __verEjemplo ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(
                  __verEjemplo ? 'Ocultar Ejemplo' : 'Mostrar Ejemplo',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (__verEjemplo) // Solo muestra el ejemplo si _showExample es true
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ejemplo:',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Image.asset(widget.formula.ejemplo, height: 200),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
