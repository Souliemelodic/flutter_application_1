import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = '0';
  final List<String> _tokens = [];
  bool _showingResult = false;

  String get _display =>
      _tokens.isEmpty ? _input : '${_tokens.join(' ')} $_input';

  void _press(String value) {
    setState(() {
      if (value == 'C') {
        _input = '0';
        _tokens.clear();
        _showingResult = false;
      } else if (value == '=') {
        _calculate();
      } else if (_isOperator(value)) {
        _pressOperator(value);
      } else if (value == '.') {
        if (_showingResult) _startNewCalculation();
        if (!_input.contains('.')) _input += '.';
      } else {
        if (_showingResult) _startNewCalculation();
        _input = _input == '0' ? value : _input + value;
      }
    });
  }

  bool _isOperator(String value) => ['+', '-', '/', 'x'].contains(value);

  void _startNewCalculation() {
    _input = '0';
    _tokens.clear();
    _showingResult = false;
  }

  void _pressOperator(String operator) {
    if (_showingResult) {
      _tokens
        ..clear()
        ..add(_input);
      _showingResult = false;
    } else if (_tokens.isEmpty) {
      _tokens.add(_input);
    } else if (_isOperator(_tokens.last)) {
      _tokens[_tokens.length - 1] = operator;
      return;
    }
    _tokens.add(operator);
    _input = '0';
  }

  void _calculate() {
    if (_tokens.isEmpty) return;
    final values = [..._tokens, _input];
    try {
      final numbers = <double>[double.parse(values.first)];
      final operators = <String>[];
      for (var index = 1; index < values.length; index += 2) {
        operators.add(values[index]);
        numbers.add(double.parse(values[index + 1]));
      }
      for (var index = operators.length - 1; index >= 0; index--) {
        if (operators[index] == 'x' || operators[index] == '/') {
          final right = numbers[index + 1];
          if (operators[index] == '/' && right == 0) {
            throw const FormatException('Cannot divide by zero');
          }
          numbers[index] = operators[index] == 'x'
              ? numbers[index] * right
              : numbers[index] / right;
          numbers.removeAt(index + 1);
          operators.removeAt(index);
        }
      }
      var result = numbers.first;
      for (var index = 0; index < operators.length; index++) {
        result = operators[index] == '+'
            ? result + numbers[index + 1]
            : result - numbers[index + 1];
      }
      _input = result == result.roundToDouble()
          ? result.toInt().toString()
          : result.toString();
      _tokens.clear();
      _showingResult = true;
    } on FormatException {
      _input = 'Error';
      _tokens.clear();
      _showingResult = true;
    }
  }

  Widget _button(String label, Color operatorColor) {
    final isOperator = _isOperator(label) || label == '=';
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: FilledButton(
          onPressed: () => _press(label),
          style: FilledButton.styleFrom(
            backgroundColor: isOperator ? operatorColor : null,
            minimumSize: const Size(0, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(label, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  Widget _row(List<String> labels, Color operatorColor) => Row(
        children: [
          for (final label in labels) _button(label, operatorColor),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Calculator')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _display,
                    key: const Key('calculator-display'),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            _row(['7', '8', '9', '/'], scheme.primary),
            _row(['4', '5', '6', 'x'], scheme.primary),
            _row(['1', '2', '3', '-'], scheme.primary),
            _row(['C', '0', '.', '+'], scheme.primary),
            _row(['='], scheme.tertiary),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
