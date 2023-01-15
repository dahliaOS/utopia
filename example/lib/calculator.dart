/*
Copyright 2019 The dahliaOS Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'dart:math' as math;
import './extraMath.dart';
import 'pageController.dart';

class Calculator extends StatelessWidget {
  @override
  Widget /*!*/ build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          accentColor: Colors.black,
          brightness: Brightness.light
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        
        scaffoldBackgroundColor: Color.fromARGB(255, 0, 0, 0),
        colorScheme: ColorScheme.fromSwatch(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          primarySwatch: Colors.grey,
          accentColor: Colors.black,
          brightness: Brightness.dark
        ),
      ),
      home: CalculatorHome(),
    );
  }
}

enum _messageMode {
  ERROR,
  WARNING,
  NOTICE,
  EASTER_EGG
}
enum _games {
  NONE,
  PI
}
enum _blockable {
  OPERATORS,
  DIGITS,
  EQUALS,
  FUNCTIONS
}

class _CalculatorHomeState extends State<CalculatorHome> {
  // Statics
  TextSelection _currentSelection =
      TextSelection(baseOffset: 0, extentOffset: 0);
  final GlobalKey _textFieldKey = GlobalKey();
  final textFieldPadding = EdgeInsets.only(right: 8.0);
  static TextStyle textFieldTextStyle =
      TextStyle(fontSize: 80.0, fontWeight: FontWeight.w300);
  Color _numColor = Color.fromARGB(238, 0, 0, 0);
  Color _opColor = Color.fromARGB(236, 0, 0, 0);
  double? _fontSize = textFieldTextStyle.fontSize;
  static const _twoPageBreakpoint = 640;
  // Controllers
  TextEditingController _controller = TextEditingController(text: '');
  var _pageController = AdvancedPageController(initialPage: 0);
  // Toggles
  /// Defaults to degree mode (false)
  bool _useRadians = false;
  /// Refers to the sin, cos, sqrt, etc.
  bool _invertedMode = false;
  //bool _toggled = false;
  /// Whether or not the result is an error.
  bool _errored = false;
  /// Whether a calculation result is showing.
  /// This shows the body in bold and resets when adding new buttons.
  bool _solved = false;
  /// What to block.
  List<_blockable> _blocking = [];
  /// Whether or not the result is an Easter egg.
  /// Refrain from using this for real calculations.
  bool _egged = false;
  // Secondary Error
  _messageMode _secondaryErrorType = _messageMode.ERROR;
  bool _secondaryErrorVisible = false;
  String _secondaryErrorValue = "";
  // Game Mode
  _games _game = _games.NONE;

  void _setSecondaryError(String message, [_messageMode type = _messageMode.ERROR]) {
    _secondaryErrorValue = message;
    _secondaryErrorType = type;
    // The following is slightly convoluted for "show this for 3 seconds and fade out"
    setState(() => _secondaryErrorVisible = true);
    (() async {
      await Future.delayed(Duration(seconds: 3));
      setState(() => _secondaryErrorVisible = false);
    })();
  }

  void _onTextChanged() {
    final inputWidth =
        _textFieldKey.currentContext!.size!.width - textFieldPadding.horizontal;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: _controller.text,
        style: textFieldTextStyle,
      ),
    );
    textPainter.layout();

    var textWidth = textPainter.width;
    var fontSize = textFieldTextStyle.fontSize;

    while (textWidth > inputWidth && fontSize! > 40.0) {
      fontSize -= 0.5;
      textPainter.text = TextSpan(
        text: _controller.text,
        style: textFieldTextStyle.copyWith(fontSize: fontSize),
      );
      textPainter.layout();
      textWidth = textPainter.width;
    }

    setState(() {
      _fontSize = fontSize;
    });
  }

  void _append(String character) {
    setState(() {
      if (_controller.selection.baseOffset >= 0) {
        _currentSelection = TextSelection(
          baseOffset: _controller.selection.baseOffset + 1,
          extentOffset: _controller.selection.extentOffset + 1,
        );
        _controller.text =
            _controller.text.substring(0, _controller.selection.baseOffset) +
                character +
                _controller.text.substring(
                    _controller.selection.baseOffset, _controller.text.length);
        _controller.selection = _currentSelection;
      } else {
        _controller.text += character;
      }
    });
    _onTextChanged();
  }

  void _clear([bool longPress = false]) {
    setState(() {
      if (_errored || _solved || longPress) {
        _errored = false;
        _egged = false;
        _solved = false;
        _controller.text = '';
        _blocking = [];
      } else {
        // if (_controller.selection.baseOffset >= 0) {
        //   _currentSelection = TextSelection(
        //       baseOffset: _controller.selection.baseOffset - 1,
        //       extentOffset: _controller.selection.extentOffset - 1);
        //   _controller.text = _controller.text
        //           .substring(0, _controller.selection.baseOffset - 1) +
        //       _controller.text.substring(
        //           _controller.selection.baseOffset, _controller.text.length);
        //   _controller.selection = _currentSelection;
        // } else {
          if (_controller.text.length > 0) {
            _controller.text =
              _controller.text.substring(0, _controller.text.length - 1);
          }
        // }
      }
    });
    _onTextChanged();
  }

  int errorcount = 0;

  void _equals() {
    String originalExp = _controller.text.toString();
    if (_blocking.contains(_blockable.EQUALS)) {
      _setSecondaryError("Cannot use this now", _messageMode.WARNING);
      return;
    }
    if (_solved) return;
    setState(() {
      try {
        var diff = "(".allMatches(_controller.text).length -
            ")".allMatches(_controller.text).length;
        if (diff > 0) {
          _controller.text += ')' * diff;
        }
        String expText = _controller.text
            .replaceAll('e+', 'e')
            .replaceAll('e', '*10^')
            .replaceAll('÷', '/')
            .replaceAll('×', '*')
            .replaceAll('%', '/100')
            .replaceAll('sin(', _useRadians ? 'sin(' : 'sin(π/180.0 *')
            .replaceAll('cos(', _useRadians ? 'cos(' : 'cos(π/180.0 *')
            .replaceAll('tan(', _useRadians ? 'tan(' : 'tan(π/180.0 *')
            .replaceAll('sin⁻¹', _useRadians ? 'asin' : '180/π*asin')
            .replaceAll('cos⁻¹', _useRadians ? 'acos' : '180/π*acos')
            .replaceAll('tan⁻¹', _useRadians ? 'atan' : '180/π*atan')
            .replaceAll('π', 'PI')
            .replaceAll('℮', 'E')
            .replaceAllMapped(
                RegExp(r'(\d+)\!'), (Match m) => "fact(${m.group(1)})")
            .replaceAllMapped(
                RegExp(
                    r'(?:\(([^)]+)\)|([0-9A-Za-z]+(?:\.\d+)?))\^(?:\(([^)]+)\)|([0-9A-Za-z]+(?:\.\d+)?))'),
                (Match m) =>
                    "pow(${m.group(1) ?? ''}${m.group(2) ?? ''},${m.group(3) ?? ''}${m.group(4) ?? ''})")
            .replaceAll('√(', 'sqrt(');
        //print(expText);
        Expression exp = Expression.parse(expText);
        var context = {
          "PI": math.pi,
          "E": math.e,
          "asin": math.asin,
          "acos": math.acos,
          "atan": math.atan,
          "sin": math.sin,
          "cos": math.cos,
          "tan": math.tan,
          "ln": math.log,
          "log": log10,
          "pow": math.pow,
          "sqrt": math.sqrt,
          "fact": factorial,
        };
        final evaluator = const ExpressionEvaluator();
        num outcome = evaluator.eval(exp, context);
        _controller.text = outcome
            .toStringAsPrecision(13)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
        if (_controller.text == "NaN") {
          _controller.text = "Impossible";
          _errored = true;
        } else if (originalExp.startsWith("4÷1")) {
          _setSecondaryError("Happy April Fools' Day!", _messageMode.EASTER_EGG);
          if (DateTime.now().month == DateTime.april && DateTime.now().day == 1) {
            _controller.text = "https://youtu.be/bxqLsrlakK8";
            _errored = true;
            _egged = true;
          }
        } else {
          _solved = true;
        }
        _blocking = [];
      } catch (e) {
        if (errorcount < 5 && originalExp == "error+123") {
          _controller.text = 'Congratulations!';
          _errored = true;
          _egged = true;
        } else if (originalExp == "(×.×)") {
          _controller.text = 'dead';
          _errored = true;
          _egged = true;
        } else if (originalExp == "you little...π" || originalExp == "you little...!") {
          _controller.text = 'warning';
          _errored = true;
        } else if (errorcount > 5) {
          _controller.text = 'you little...';
          _errored = true;
        } else {
          _controller.text = 'error';
          _errored = true;
        }
        errorcount++;
      }
    });
    _onTextChanged();
  }

  @deprecated
  Widget _buildButton(String label, {
    Function()? onPress,
    Function()? onLongPress,
    _blockable? blockingCategory,
    Function()? block,
    bool isOperator = false
  }) {
    if (onPress == null)
      onPress = () {
        if (_errored || (_solved && !isOperator)) {
          _errored = false;
          _egged = false;
          _solved = false;
          _blocking = [];
          _controller.text = '';
        } else if (_solved && isOperator) {
          _solved = false;
          _blocking = [_blockable.OPERATORS, _blockable.EQUALS];
        } else if (_blocking.contains(blockingCategory)) {
          _setSecondaryError("Cannot use that now", _messageMode.WARNING);
          return;
        }
        _append(label);
        block?.call();
      };
    return Expanded(
      child: InkWell(
        onTap: onPress,
        onLongPress: (onLongPress != null) ? onLongPress() : (label == 'C')
            ? () => _clear(true)
            : (label == '=' && _blocking.contains(blockingCategory))
              ? () {
                _blocking = [];
                _equals();
              }
            : (_errored || _solved || _blocking.contains(blockingCategory))
              ? () {
                _append(label);
                _blocking = [];
              } : null,
        child: Center(
            child: Text(
          label,
          style: TextStyle(
              fontSize:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? 32.0
                      : 20.0, //24
              fontWeight: FontWeight.w300,
              color: Colors.white),
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > _twoPageBreakpoint) {
      _pageController.viewportFraction = 0.5;
    } else {
      _pageController.viewportFraction = 1.0;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _useRadians = !_useRadians),
              child: Text(_useRadians ? 'RAD' : 'DEG',
                style: TextStyle(color: Colors.grey)),
            ),
            AnimatedOpacity(
              opacity: _game != _games.NONE ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: (_game != _games.NONE) ? IconButton(
                icon: Icon(Icons.videogame_asset_outlined),
                onPressed:  () => _game == _games.PI ? null /* TODO: set the prior to the Digits of Pi game */
                : null ,
                color: Theme.of(context).colorScheme.secondary
              ): Padding( //make the illusion that it's still there
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.videogame_asset_outlined, color: Theme.of(context).colorScheme.secondary),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                TextField(
                  key: _textFieldKey,
                  controller: _controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: textFieldPadding,
                  ),
                  textAlign: TextAlign.right,
                  style: textFieldTextStyle.copyWith(
                      fontSize: _fontSize,
                      fontWeight: _solved ? FontWeight.bold : null,
                      color: _egged
                          ? Colors.lightBlue[400]
                          : _errored
                              ? Colors.red
                              : null),
                  focusNode: AlwaysDisabledFocusNode(),
                ),
                Expanded(child: Container()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AnimatedOpacity(
                          opacity: _secondaryErrorVisible ? 1.0 : 0.0,
                          duration: _secondaryErrorVisible ? Duration(milliseconds: 10) : Duration(seconds: 1),
                          //onEnd: () => _secondaryErrorVisible = false,
                          child: Text(
                            _secondaryErrorValue,
                            style: TextStyle(
                              color: _secondaryErrorType == _messageMode.ERROR ? Colors.red
                              : _secondaryErrorType == _messageMode.WARNING ? Colors.amber
                              : _secondaryErrorType == _messageMode.NOTICE ? Theme.of(context).textTheme.bodyText1?.color
                              : _secondaryErrorType == _messageMode.EASTER_EGG ? Colors.lightBlue
                              : Colors.red, //even though this slot will never be used
                              fontSize: 20.0,
                            )),
                        ),
                        //Expanded(child: Container())
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Material(
              color: _opColor,
              child: PageView(
                controller: _pageController,
                padEnds: false,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildButton('C', onPress: _clear),
                                  _buildButton('('),
                                  _buildButton(')'),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Material(
                                color: _numColor,
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8)),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildButton('7', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                          _buildButton('8', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                          _buildButton('9', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildButton('4', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                          _buildButton('5', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                          _buildButton('6', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildButton('1', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                          _buildButton('2', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                          _buildButton('3', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildButton('%', blockingCategory: _blockable.OPERATORS, block: () => _blocking = [_blockable.EQUALS, _blockable.OPERATORS]),
                                          _buildButton('0', blockingCategory: _blockable.DIGITS, block: () => _blocking = []),
                                          _buildButton('.', blockingCategory: _blockable.OPERATORS, block: () => _blocking = [_blockable.EQUALS, _blockable.OPERATORS]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Column(
                        children: <Widget>[
                          _buildButton('÷', blockingCategory: _blockable.OPERATORS, block: () => _blocking = [_blockable.EQUALS, _blockable.OPERATORS]),
                          _buildButton('×', blockingCategory: _blockable.OPERATORS, block: () => _blocking = [_blockable.EQUALS, _blockable.OPERATORS]),
                          _buildButton('-', blockingCategory: _blockable.OPERATORS, block: () => _blocking = [_blockable.EQUALS, _blockable.OPERATORS]),
                          _buildButton('+', blockingCategory: _blockable.OPERATORS, block: () => _blocking = [_blockable.EQUALS, _blockable.OPERATORS]),
                          _buildButton('=', onPress: _equals, blockingCategory: _blockable.EQUALS),
                        ],
                      )),
                      if (MediaQuery.of(context).size.width <= _twoPageBreakpoint) InkWell(
                        child: Container(
                          color: Theme.of(context).colorScheme.secondary,
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () => _pageController.animateToPage(
                          1,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: Theme.of(context).colorScheme.secondary,
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width <= _twoPageBreakpoint) InkWell(
                          child: Container(
                            height: double.infinity,
                            //color: _opColor,
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () => _pageController.animateToPage(
                            0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton(
                                        _invertedMode ? 'sin⁻¹' : 'sin',
                                        onPress: () => _invertedMode
                                            ? _append('sin⁻¹(')
                                            : _append('sin(')),
                                    _buildButton(
                                        _invertedMode ? 'cos⁻¹' : 'cos',
                                        onPress: () => _invertedMode
                                            ? _append('cos⁻¹(')
                                            : _append('cos(')),
                                    _buildButton(
                                        _invertedMode ? 'tan⁻¹' : 'tan',
                                        onPress: () => _invertedMode
                                            ? _append('tan⁻¹(')
                                            : _append('tan(')),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton(
                                        _invertedMode ? 'eˣ' : 'ln',
                                        onPress: () => _invertedMode
                                            ? _append('℮^(')
                                            : _append('ln(')),
                                    _buildButton(
                                        _invertedMode ? '10ˣ' : 'log',
                                        onPress: () => _invertedMode
                                            ? _append('10^(')
                                            : _append('log(')),
                                    _buildButton(
                                        _invertedMode ? 'x²' : '√',
                                        onPress: () => _invertedMode
                                            ? _append('^2')
                                            : _append('√(')),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton('π'),
                                    _buildButton('e', onPress: () => _append('℮')),
                                    _buildButton('^'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton(_invertedMode ? '𝗜𝗡𝗩' : 'INV',
                                        onPress: () {
                                      setState(() {
                                        _invertedMode = !_invertedMode;
                                      });
                                    }),
                                    _buildButton(_useRadians ? 'RAD' : 'DEG', onPress: () {
                                      setState(() {
                                        _useRadians = !_useRadians;
                                      });
                                      _setSecondaryError("This button will be removed in the future", _messageMode.WARNING);
                                    }),
                                    _buildButton('!'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
