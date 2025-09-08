import 'package:enciclopedia_mate/model/formula.dart';
import 'package:flutter/material.dart';
class ListaFormulasScreen extends StatefulWidget {
  const ListaFormulasScreen({super.key});

  @override
  State<ListaFormulasScreen> createState() => _ListaFormulasScreenState();
}

class _ListaFormulasScreenState extends State<ListaFormulasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lista de formulas", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)),
      body: ListView.builder(
        itemCount: formulas.length,
        itemBuilder: (context, index) {
          Formula formula = formulas[index];
          return ListTile(
            title: Text(formula.nombre),
            trailing: IconButton(
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/detalleFormula',
                    arguments: formula,
                  ),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          );
        },
      ),
    );
  }
}


final List<Formula> formulas = [
  Formula(
    id: '1',
    nombre: 'Teorema de Pitágoras',
    imagen: 'assets/img/f1.png',
    descripcion:
        'En un triángulo rectángulo, el cuadrado de la longitud de la hipotenusa (el lado opuesto al ángulo recto) es igual a la suma de los cuadrados de las longitudes de los otros dos lados (catetos).',
    ejemplo: 'assets/img/f11.png',
  ),
  Formula(
    id: '2',
    nombre: 'Ecuacion de segundo grado',
    imagen: 'assets/img/f2.png',
    descripcion:
        'La fórmula general de ecuaciones de segundo grado (o ecuación cuadrática) sirve para encontrar las soluciones (raíces) de cualquier ecuación cuadrática, sin importar su complejidad, siempre y cuando la ecuación esté en la forma estándar ax² + bx + c = 0, donde a ≠ 0',
    ejemplo: 'assets/img/f22.png',
  ),
  Formula(
    id: '3',
    nombre: 'Area de un rectangulo',
    imagen: 'assets/img/f3.png',
    descripcion:
        'El área de un rectángulo se calcula multiplicando su base por su altura. La fórmula es: Área = base * altura',
    ejemplo: 'assets/img/f33.png',
  ),
  Formula(
    id: '4',
    nombre: 'Area de un circulo',
    imagen: 'assets/img/f4.png',
    descripcion:
        'El área de un círculo se calcula utilizando la fórmula A = πr², donde A es el área, π (pi) es una constante matemática aproximadamente igual a 3.14159, y r es el radio del círculo.',
    ejemplo: 'assets/img/f44.png',
  ),
  Formula(
    id: '5',
    nombre: 'Volumen de un cilindro',
    imagen: 'assets/img/f5.png',
    descripcion:
        'El volumen de un cilindro se calcula utilizando la fórmula V = πr²h, donde V es el volumen, r es el radio de la base circular y h es la altura del cilindro. En otras palabras, se calcula el área de la base circular (πr²) y luego se multiplica por la altura para obtener el volumen total.',
    ejemplo: 'assets/img/f55.png',
  ),
  Formula(
    id: '6',
    nombre: 'Volumen de una esfera',
    imagen: 'assets/img/f6.png',
    descripcion:
        'El volumen de una esfera se calcula mediante la fórmula V = (4/3)πr³, donde \'V\' representa el volumen, \'π\' es una constante matemática (aproximadamente 3.14159), y 'r' es el radio de la esfera.',
    ejemplo: 'assets/img/f66.png',
  ),


];