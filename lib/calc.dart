import 'package:flutter/material.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
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
  // ----- State -----
  String _currentInput = '0';     // number currently being typed
  String _previousInput = '';     // stored operand
  String? _operator;              // '+', '-', '*', '/', '%'
  bool _waitingForOperand = false;
  String _expressionHistory = ''; // shown in the top line of the display

  // ----- Helpers -----
  String _formatResult(double value) {
    if (!value.isFinite) return 'Error';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    // Round to 10 decimals, then strip trailing zeros
    final rounded = double.parse(value.toStringAsFixed(10));
    return rounded.toString();
  }

  double? _compute(String aStr, double b, String op) {
    final a = double.tryParse(aStr);
    if (a == null) return null;

    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) return null;
        return a / b;
      case '%':
        if (b == 0) return null;
        return a % b;
      default:
        return null;
    }
  }

  // ----- Actions -----
  void _inputNumber(String num) {
    setState(() {
      if (_waitingForOperand) {
        _currentInput = num;
        _waitingForOperand = false;
        _expressionHistory = '';
      } else {
        if (_currentInput == '0') {
          _currentInput = num;
        } else {
          _currentInput += num;
        }
      }
      // Clear leftover history after equals when user starts typing
      if (_operator == null && _previousInput.isEmpty) {
        _expressionHistory = '';
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_waitingForOperand) {
        _currentInput = '0.';
        _waitingForOperand = false;
        _expressionHistory = '';
      } else if (!_currentInput.contains('.')) {
        _currentInput += '.';
      }
    });
  }

  void _handleOperator(String nextOperator) {
    final inputValue = double.tryParse(_currentInput);
    if (inputValue == null) return;

    setState(() {
      if (_operator != null && !_waitingForOperand) {
        final result = _compute(_previousInput, inputValue, _operator!);
        if (result == null) {
          _showError('Cannot divide by zero');
          return;
        }
        final resultStr = _formatResult(result);
        _currentInput = resultStr;
        _previousInput = resultStr;
      } else {
        _previousInput = _currentInput;
      }

      _operator = nextOperator;
      _waitingForOperand = true;
      _expressionHistory = '';
    });
  }

  void _handleEquals() {
    if (_operator == null || _waitingForOperand) return;

    final inputValue = double.tryParse(_currentInput);
    if (inputValue == null) return;

    final result = _compute(_previousInput, inputValue, _operator!);
    if (result == null) {
      _showError('Cannot divide by zero');
      return;
    }

    final resultStr = _formatResult(result);
    final expression = '$_previousInput $_operator $_currentInput =';

    setState(() {
      _expressionHistory = expression;
      _currentInput = resultStr;
      _operator = null;
      _previousInput = '';
      _waitingForOperand = false;
    });
  }

  void _clearAll() {
    setState(() {
      _currentInput = '0';
      _previousInput = '';
      _operator = null;
      _waitingForOperand = false;
      _expressionHistory = '';
    });
  }

  void _deleteLast() {
    if (_waitingForOperand) return;

    setState(() {
      if (_currentInput.length > 1) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else {
        _currentInput = '0';
      }
      if (_operator == null && _previousInput.isEmpty) {
        _expressionHistory = '';
      }
    });
  }

  void _showError(String message) {
    setState(() {
      _currentInput = '0';
      _previousInput = '';
      _operator = null;
      _waitingForOperand = false;
      _expressionHistory = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ----- UI -----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F2F5), Color(0xFFE0E5EC)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 360,
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00141E).withValues(alpha: 0.3),
                    offset: const Offset(0, 25),
                    blurRadius: 40,
                    spreadRadius: -10,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDisplay(),
                  const SizedBox(height: 28),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // History line
          SizedBox(
            height: 24,
            child: Text(
              _buildHistoryText(),
              style: const TextStyle(
                color: Color(0xFF9BB8D4),
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Current value
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _currentInput,
              style: const TextStyle(
                color: Color(0xFFF0F9FF),
                fontSize: 46,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildHistoryText() {
    if (_operator != null && _previousInput.isNotEmpty) {
      return '$_previousInput $_operator';
    }
    return _expressionHistory;
  }

  Widget _buildButtons() {
    return Column(
      children: [
        _buildRow([
          _buildButton('AC', action: _clearAll, type: ButtonType.clear),
          _buildButton('⌫', action: _deleteLast, type: ButtonType.clear),
          _buildButton('%', action: () => _handleOperator('%'), type: ButtonType.operator),
          _buildButton('÷', action: () => _handleOperator('/'), type: ButtonType.operator),
        ]),
        const SizedBox(height: 13),
        _buildRow([
          _buildButton('7', action: () => _inputNumber('7')),
          _buildButton('8', action: () => _inputNumber('8')),
          _buildButton('9', action: () => _inputNumber('9')),
          _buildButton('×', action: () => _handleOperator('*'), type: ButtonType.operator),
        ]),
        const SizedBox(height: 13),
        _buildRow([
          _buildButton('4', action: () => _inputNumber('4')),
          _buildButton('5', action: () => _inputNumber('5')),
          _buildButton('6', action: () => _inputNumber('6')),
          _buildButton('−', action: () => _handleOperator('-'), type: ButtonType.operator),
        ]),
        const SizedBox(height: 13),
        _buildRow([
          _buildButton('1', action: () => _inputNumber('1')),
          _buildButton('2', action: () => _inputNumber('2')),
          _buildButton('3', action: () => _inputNumber('3')),
          _buildButton('+', action: () => _handleOperator('+'), type: ButtonType.operator),
        ]),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 13),
                child: _buildButton('0', action: () => _inputNumber('0')),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 13),
                child: _buildButton('.', action: _inputDecimal),
              ),
            ),
            Expanded(
              child: _buildButton('=', action: _handleEquals, type: ButtonType.equals),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.5),
                  child: c,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildButton(
    String label, {
    required VoidCallback action,
    ButtonType type = ButtonType.number,
  }) {
    Color bg;
    Color fg;
    Color shadow;

    switch (type) {
      case ButtonType.operator:
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF1E3A8A);
        shadow = const Color(0xFFC7D2FE);
        break;
      case ButtonType.equals:
        bg = const Color(0xFF2563EB);
        fg = Colors.white;
        shadow = const Color(0xFF1D4ED8);
        break;
      case ButtonType.clear:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        shadow = const Color(0xFFFECACA);
        break;
      case ButtonType.number:
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF1E2A3A);
        shadow = const Color(0xFFCBD5E1);
        break;
    }

    return _PressableButton(
      label: label,
      onPressed: action,
      backgroundColor: bg,
      foregroundColor: fg,
      shadowColor: shadow,
    );
  }
}

enum ButtonType { number, operator, equals, clear }

/// A button with a "physical key" press animation (translate down + shadow shrink).
class _PressableButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color shadowColor;

  const _PressableButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.shadowColor,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 5 : 0, 0),
        height: 68,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _pressed ? 1 : 6),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, 8),
              blurRadius: 14,
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.foregroundColor,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}