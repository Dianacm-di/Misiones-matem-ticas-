class CalculatorUtils {
  static int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }

  static String preprocessFactorials(String expression) {
    // Reemplaza "n!" con factoriales calculados
    RegExp regExp = RegExp(r'(\d+)!');
    return expression.replaceAllMapped(regExp, (match) {
      int number = int.parse(match.group(1)!);
      return factorial(number).toString();
    });
  }
}
