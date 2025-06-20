import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  MaterialColor _primaryColor = Colors.red;
  bool _autoColorByPokemon = false;

  static const Map<String, MaterialColor> typeColors = {
    'normal': Colors.brown,
    'fire': Colors.red,
    'water': Colors.blue,
    'electric': Colors.amber,
    'grass': Colors.green,
    'ice': Colors.cyan,
    'fighting': Colors.orange,
    'poison': Colors.purple,
    'ground': Colors.brown,
    'flying': Colors.indigo,
    'psychic': Colors.pink,
    'bug': Colors.lightGreen,
    'rock': Colors.grey,
    'ghost': Colors.deepPurple,
    'dragon': Colors.indigo,
    'dark': Colors.blueGrey,
    'steel': Colors.blueGrey,
    'fairy': Colors.pink,
  };

  bool get isDarkMode => _isDarkMode;
  MaterialColor get primaryColor => _primaryColor;
  bool get autoColorByPokemon => _autoColorByPokemon;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setPrimaryColor(MaterialColor color) {
    _primaryColor = color;
    _autoColorByPokemon = false;
    notifyListeners();
  }

  void setAutoColorByPokemon(bool value) {
    _autoColorByPokemon = value;
    notifyListeners();
  }

  void setPrimaryColorByType(String type) {
    _primaryColor = typeColors[type] ?? Colors.red;
    notifyListeners();
  }
}
