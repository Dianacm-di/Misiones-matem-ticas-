import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class JuegoScreen extends StatefulWidget {
  final int nivel;
  final bool modoLibre;
  final String? tema;
  final String? dificultad;

  const JuegoScreen({
    super.key,
    required this.nivel,
    this.modoLibre = false,
    this.tema,
    this.dificultad,
  });

  @override
  _JuegoScreenState createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen>
    with TickerProviderStateMixin {
  int vidas = 3;
  int puntos = 0;
  int preguntaActual = 0;
  int totalPreguntas = 15;
  String pregunta = '';
  List<String> opciones = [];
  int respuestaCorrecta = 0;
  String? explicacion;

  int tiempoRestante = 30;
  Timer? temporizador;

  int ayudasUsadas = 0;
  int maxAyudas = 3;

  late AnimationController _animationController;
  late AnimationController _timerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _timerAnimation;
  Random random = Random();

  // Instancias de AudioPlayer
  final AudioPlayer _audioPlayerCorrecto = AudioPlayer();
  final AudioPlayer _audioPlayerIncorrecto = AudioPlayer();

  // --- NUEVAS VARIABLES PARA CONTROL DE PREGUNTAS ---
  List<Function> _allQuestionGenerators = [];
  List<Function> _availableQuestionGenerators = [];
  // --- FIN NUEVAS VARIABLES ---

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _timerController = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _timerController, curve: Curves.linear));

    _ajustarDificultad();
    _inicializarGeneradoresDePreguntas(); // Nueva llamada
    _generarPregunta();
    _iniciarTemporizador();
  }

  void _inicializarGeneradoresDePreguntas() {
    _allQuestionGenerators.clear();
    _availableQuestionGenerators.clear();

    if (widget.modoLibre && widget.tema != null) {
      switch (widget.tema!) {
        case 'Suma':
          _allQuestionGenerators.add(_generarSuma);
          break;
        case 'Resta':
          _allQuestionGenerators.add(_generarResta);
          break;
        case 'Multiplicación':
          _allQuestionGenerators.add(_generarMultiplicacion);
          break;
        case 'División':
          _allQuestionGenerators.add(_generarDivision);
          break;
        case 'Geometría':
          _allQuestionGenerators.add(_generarGeometria);
          break;
        case 'Lógica':
          _allQuestionGenerators.add(_generarLogica);
          break;
        case 'Fracciones':
          _allQuestionGenerators.add(_generarFracciones);
          break;
        case 'Mixto':
          _allQuestionGenerators.addAll([
            _generarSuma,
            _generarResta,
            _generarMultiplicacion,
            _generarDivision,
            _generarGeometria,
            _generarLogica,
            _generarFracciones,
          ]);
          break;
      }
    } else {
      String currentThematic = _getTematica(widget.nivel);

      switch (currentThematic) {
        case 'Suma':
          _allQuestionGenerators.add(_generarSuma);
          break;
        case 'Resta':
          _allQuestionGenerators.add(_generarResta);
          break;
        case 'Multiplicación':
          _allQuestionGenerators.add(_generarMultiplicacion);
          break;
        case 'División':
          _allQuestionGenerators.add(_generarDivision);
          break;
        case 'Geometría':
          _allQuestionGenerators.add(_generarGeometria);
          break;
        case 'Lógica':
          _allQuestionGenerators.add(_generarLogica);
          break;
        case 'Fracciones':
          _allQuestionGenerators.add(_generarFracciones);
          break;
        case 'Desafío Final':
          _allQuestionGenerators.addAll([
            _generarSuma,
            _generarResta,
            _generarMultiplicacion,
            _generarDivision,
            _generarGeometria,
            _generarLogica,
            _generarFracciones,
          ]);
          break;
      }
    }
    _availableQuestionGenerators = List.from(_allQuestionGenerators);
    if (_availableQuestionGenerators.length < totalPreguntas) {
      int currentLength = _availableQuestionGenerators.length;
      while (_availableQuestionGenerators.length < totalPreguntas) {
        _availableQuestionGenerators.addAll(
          List.from(
            _allQuestionGenerators.sublist(
              0,
              min(
                currentLength,
                totalPreguntas - _availableQuestionGenerators.length,
              ),
            ),
          ),
        );
      }
    }
    _availableQuestionGenerators.shuffle();
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
    if (nivel > tematicas.length) {
      return 'Desafío Final';
    }
    return tematicas[nivel - 1];
  }

  void _ajustarDificultad() {
    if (widget.modoLibre && widget.dificultad != null) {
      switch (widget.dificultad!) {
        case 'Fácil':
          totalPreguntas = 10;
          tiempoRestante = 45;
          break;
        case 'Medio':
          totalPreguntas = 15;
          tiempoRestante = 30;
          break;
        case 'Difícil':
          totalPreguntas = 20;
          tiempoRestante = 20;
          break;
      }
    } else {
      totalPreguntas = 10 + (widget.nivel * 2);
      tiempoRestante = 35 - (widget.nivel * 2);
      if (tiempoRestante < 15) tiempoRestante = 15;
    }
  }

  void _iniciarTemporizador() {
    temporizador?.cancel();
    _timerController.reset();
    _timerController.forward();

    temporizador = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        tiempoRestante--;
      });

      if (tiempoRestante <= 0) {
        timer.cancel();
        _tiempoAgotado();
      }
    });
  }

  void _tiempoAgotado() {
    temporizador?.cancel();
    if (!mounted) return;
    vidas--;
    _mostrarFeedback(
      '¡Tiempo agotado! Respuesta: ${opciones[respuestaCorrecta]}',
      Colors.orange,
    );

    if (vidas <= 0) {
      _finalizarJuego(false);
    } else {
      _siguientePregunta();
    }
  }

  @override
  void dispose() {
    temporizador?.cancel();
    _animationController.dispose();
    _timerController.dispose();
    _audioPlayerCorrecto.dispose();
    _audioPlayerIncorrecto.dispose();
    super.dispose();
  }

  void _generarPregunta() {
    explicacion = null;

    if (_availableQuestionGenerators.isEmpty) {
      _inicializarGeneradoresDePreguntas();
    }

    Function generarFuncion = _availableQuestionGenerators.removeAt(0);
    generarFuncion();
  }

  int _getDificultadNumerica() {
    if (widget.modoLibre && widget.dificultad != null) {
      switch (widget.dificultad!) {
        case 'Fácil':
          return 1;
        case 'Medio':
          return 2;
        case 'Difícil':
          return 3;
      }
    }
    return (widget.nivel > 4)
        ? 3
        : (widget.nivel > 2)
        ? 2
        : 1;
  }

  void _generarSuma() {
    int dif = _getDificultadNumerica();
    int a = random.nextInt(10 * dif) + 1;
    int b = random.nextInt(10 * dif) + 1;
    int correcto = a + b;
    pregunta = '$a + $b = ?';
    explicacion =
        'Para sumar, cuenta desde $a y avanza $b números más: $a + $b = $correcto';
    _generarOpciones(correcto);
  }

  void _generarResta() {
    int dif = _getDificultadNumerica();
    int a = random.nextInt(20 * dif) + 10;
    int b = random.nextInt(a);
    int correcto = a - b;
    pregunta = '$a - $b = ?';
    explicacion =
        'Para restar, cuenta hacia atrás desde $a un total de $b números: $a - $b = $correcto';
    _generarOpciones(correcto);
  }

  void _generarMultiplicacion() {
    int dif = _getDificultadNumerica();
    int maxNum =
        dif == 1
            ? 5
            : dif == 2
            ? 10
            : 15;
    int a = random.nextInt(maxNum) + 1;
    int b = random.nextInt(maxNum) + 1;
    int correcto = a * b;
    pregunta = '$a × $b = ?';
    explicacion = '$a × $b significa sumar $a veces el número $b: $correcto';
    _generarOpciones(correcto);
  }

  void _generarDivision() {
    int dif = _getDificultadNumerica();
    int maxNum =
        dif == 1
            ? 5
            : dif == 2
            ? 10
            : 15;
    int b = random.nextInt(maxNum) + 2;
    int correcto = random.nextInt(maxNum) + 1;
    int a = b * correcto;
    pregunta = '$a ÷ $b = ?';
    explicacion =
        '$a ÷ $b significa: ¿cuántas veces cabe $b en $a? Respuesta: $correcto';
    _generarOpciones(correcto);
  }

  void _generarGeometria() {
    List<Map<String, dynamic>> preguntas = [
      {
        'q': '¿Cuántos lados tiene un triángulo?',
        'a': 3,
        'e': 'Un triángulo tiene 3 lados y 3 ángulos',
      },
      {
        'q': '¿Cuántos grados tiene un círculo?',
        'a': 360,
        'e': 'Un círculo completo tiene 360 grados',
      },
      {
        'q': '¿Cuántos lados tiene un hexágono?',
        'a': 6,
        'e': 'Un hexágono es una figura de 6 lados',
      },
      {
        'q': '¿Cuántos ángulos tiene un cuadrado?',
        'a': 4,
        'e': 'Un cuadrado tiene 4 ángulos rectos (90°)',
      },
      {
        'q': '¿Cuántos lados tiene un pentágono?',
        'a': 5,
        'e': 'Un pentágono tiene 5 lados',
      },
    ];
    var p = preguntas[random.nextInt(preguntas.length)];
    pregunta = p['q'];
    explicacion = p['e'];
    _generarOpciones(p['a']);
  }

  void _generarLogica() {
    int tipo = random.nextInt(3);
    switch (tipo) {
      case 0:
        int inicio = random.nextInt(10) + 1;
        int incremento = random.nextInt(5) + 2;
        int a = inicio;
        int b = a + incremento;
        int c = b + incremento;
        int correcto = c + incremento;
        pregunta = '¿Qué número sigue? $a, $b, $c, ?';
        explicacion =
            'La secuencia suma $incremento cada vez: $a + $incremento = $b, $b + $incremento = $c, $c + $incremento = $correcto';
        _generarOpciones(correcto);
        break;
      case 1:
        int base = random.nextInt(20) + 2;
        if (base % 2 != 0) base++;
        int correcto = base + 4;
        pregunta = '¿Qué número par sigue? ${base - 2}, $base, ${base + 2}, ?';
        explicacion = 'Los números pares aumentan de 2 en 2: $correcto';
        _generarOpciones(correcto);
        break;
      case 2:
        int a = random.nextInt(8) + 2;
        int b = a * 2;
        int c = b * 2;
        int correcto = c * 2;
        pregunta = '¿Qué número sigue? $a, $b, $c, ?';
        explicacion = 'Cada número se duplica: $c × 2 = $correcto';
        _generarOpciones(correcto);
        break;
    }
  }

  void _generarFracciones() {
    int numerador = random.nextInt(4) + 1;
    int denominador = random.nextInt(4) + 2;
    double resultado = numerador / denominador;
    int correcto = (resultado * 100).round();
    pregunta = '$numerador/$denominador como porcentaje es:';
    explicacion =
        '$numerador ÷ $denominador = ${resultado.toStringAsFixed(2)}, que es $correcto%';
    _generarOpcionesPorcentaje(correcto);
  }

  void _generarOpciones(int correcto) {
    opciones.clear();
    Set<int> valoresUsados = {correcto};
    respuestaCorrecta = random.nextInt(4);

    for (int i = 0; i < 4; i++) {
      if (i == respuestaCorrecta) {
        opciones.add(correcto.toString());
      } else {
        int incorrecto;
        int intentos = 0;

        do {
          int rango = max(20, correcto ~/ 2);
          incorrecto = correcto + random.nextInt(rango * 2) - rango;

          if (incorrecto < 0) {
            incorrecto = random.nextInt(correcto * 2) + 1;
          }

          intentos++;

          if (intentos > 50) {
            incorrecto =
                correcto +
                (random.nextBool() ? 1 : -1) *
                    (random.nextInt(10) + 1) *
                    (i + 1);
            if (incorrecto < 0) {
              incorrecto = random.nextInt(100);
            }
          }
        } while (valoresUsados.contains(incorrecto) && intentos < 100);

        valoresUsados.add(incorrecto);
        opciones.add(incorrecto.toString());
      }
    }
  }

  void _generarOpcionesPorcentaje(int correcto) {
    opciones.clear();
    Set<int> valoresUsados = {correcto};
    respuestaCorrecta = random.nextInt(4);

    for (int i = 0; i < 4; i++) {
      if (i == respuestaCorrecta) {
        opciones.add('$correcto%');
      } else {
        int incorrecto;
        int intentos = 0;

        do {
          incorrecto = correcto + random.nextInt(61) - 30;

          if (incorrecto < 0) {
            incorrecto = random.nextInt(correcto > 20 ? correcto : 20);
          }
          if (incorrecto > 100) incorrecto = 100 - random.nextInt(20);

          intentos++;

          if (intentos > 30) {
            incorrecto =
                correcto +
                (random.nextBool() ? 1 : -1) * (random.nextInt(10) + 5);
            if (incorrecto < 0) {
              incorrecto = random.nextInt(100);
            }
            if (incorrecto > 100) {
              incorrecto = 100 - random.nextInt(50);
            }
          }
        } while (valoresUsados.contains(incorrecto) && intentos < 50);

        valoresUsados.add(incorrecto);
        opciones.add('$incorrecto%');
      }
    }
  }

  void _usarAyuda() {
    if (ayudasUsadas >= maxAyudas) return;
    if (!mounted) return;

    ayudasUsadas++;

    List<int> incorrectas = [];
    for (int i = 0; i < opciones.length; i++) {
      if (i != respuestaCorrecta && opciones[i] != '❌') {
        incorrectas.add(i);
      }
    }

    if (incorrectas.isNotEmpty) {
      int eliminar = incorrectas[random.nextInt(incorrectas.length)];
      setState(() {
        opciones[eliminar] = '❌';
      });
    }

    _mostrarFeedback('Ayuda usada: eliminé una opción incorrecta', Colors.blue);
  }

  void _responder(int opcionSeleccionada) {
    if (opciones[opcionSeleccionada] == '❌') return;
    if (!mounted) return;
    temporizador?.cancel();
    bool correcto = opcionSeleccionada == respuestaCorrecta;

    if (correcto) {
      _audioPlayerCorrecto.play(AssetSource('sounds/correcto.mp3'));

      int puntosGanados = 10 + (tiempoRestante ~/ 5);
      puntos += puntosGanados;
      _animationController.forward().then((_) {
        if (mounted) _animationController.reverse();
      });
      _mostrarFeedback('¡Correcto! +$puntosGanados puntos', Colors.green);
    } else {
      _audioPlayerIncorrecto.play(AssetSource('sounds/incorrecto.mp3'));

      vidas--;
      String mensaje = 'Incorrecto. Respuesta: ${opciones[respuestaCorrecta]}';
      if (explicacion != null && opciones[respuestaCorrecta] != '❌') {
        mensaje += '\n$explicacion';
      }
      _mostrarFeedback(mensaje, Colors.red);
    }

    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) {
        return;
      }
      if (vidas <= 0) {
        _finalizarJuego(false);
      } else if (preguntaActual + 1 >= totalPreguntas) {
        _finalizarJuego(true);
      } else {
        _siguientePregunta();
      }
    });
  }

  void _siguientePregunta() {
    if (!mounted) return;
    setState(() {
      preguntaActual++;
      tiempoRestante =
          widget.modoLibre && widget.dificultad != null
              ? (widget.dificultad == 'Fácil'
                  ? 45
                  : widget.dificultad == 'Medio'
                  ? 30
                  : 20)
              : 35 - (widget.nivel * 2);
      if (tiempoRestante < 15) tiempoRestante = 15;
      _generarPregunta();
      _iniciarTemporizador();
    });
  }

  void _mostrarFeedback(String mensaje, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _mostrarExplicacion() {
    if (explicacion == null || !mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.orange),
                SizedBox(width: 10),
                Text('Explicación'),
              ],
            ),
            content: Text(explicacion!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ENTENDIDO'),
              ),
            ],
          ),
    );
  }

  void _finalizarJuego(bool completado) {
    temporizador?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(completado ? '¡Nivel Completado!' : 'Juego Terminado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completado ? Icons.celebration : Icons.sentiment_dissatisfied,
                  size: 60,
                  color: completado ? Colors.green : Colors.red,
                ),
                SizedBox(height: 10),
                Text('Puntos obtenidos: $puntos'),
                Text('Ayudas usadas: $ayudasUsadas/$maxAyudas'),
                if (completado && !widget.modoLibre)
                  Text('¡Has desbloqueado el siguiente nivel!'),
                if (widget.modoLibre) Text('¡Excelente práctica!'),
              ],
            ),
            actions: [
              if (widget.modoLibre)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (!mounted) return;
                    setState(() {
                      vidas = 3;
                      puntos = 0;
                      preguntaActual = 0;
                      ayudasUsadas = 0;
                      _ajustarDificultad();
                      _inicializarGeneradoresDePreguntas(); // Reiniciar generadores
                      _generarPregunta();
                      _iniciarTemporizador();
                    });
                  },
                  child: Text('JUGAR DE NUEVO'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, {
                    'completado': completado,
                    'puntos': puntos,
                  });
                },
                child: Text('CONTINUAR'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modoLibre
              ? '${widget.tema} - ${widget.dificultad}'
              : 'Nivel ${widget.nivel}',
        ),
        backgroundColor:
            widget.modoLibre ? Colors.green[600] : Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tiempoRestante <= 10 ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: tiempoRestante <= 10 ? Colors.white : Colors.black,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$tiempoRestante',
                    style: TextStyle(
                      color: tiempoRestante <= 10 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                Text(' $vidas'),
                SizedBox(width: 15),
                Icon(Icons.star, color: Colors.yellow),
                Text(' $puntos'),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                widget.modoLibre
                    ? [Colors.teal[100]!, Colors.green[100]!]
                    : [Colors.indigo[100]!, Colors.purple[100]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 8,
                child: AnimatedBuilder(
                  animation: _timerAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value:
                          tiempoRestante /
                          (widget.modoLibre && widget.dificultad != null
                              ? (widget.dificultad == 'Fácil'
                                  ? 45
                                  : widget.dificultad == 'Medio'
                                  ? 30
                                  : 20)
                              : 35 - (widget.nivel * 2)),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tiempoRestante <= 10 ? Colors.red : Colors.blue,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pregunta ${preguntaActual + 1} de $totalPreguntas'),
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                ayudasUsadas < maxAyudas ? _usarAyuda : null,
                            icon: Icon(Icons.help_outline),
                            tooltip:
                                'Ayuda (${maxAyudas - ayudasUsadas} restantes)',
                          ),
                          IconButton(
                            onPressed:
                                explicacion != null
                                    ? _mostrarExplicacion
                                    : null,
                            icon: Icon(Icons.lightbulb_outline),
                            tooltip: 'Ver explicación',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Card(
                      elevation: 8,
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Text(
                          pregunta,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30),

              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    bool isEliminada = opciones[index] == '❌';

                    return ElevatedButton(
                      onPressed: !isEliminada ? () => _responder(index) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isEliminada ? Colors.grey[400] : Colors.blue[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        opciones[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isEliminada ? Colors.grey : Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
