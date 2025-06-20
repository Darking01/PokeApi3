import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utility/theme_provider.dart';
import '../services/firestore_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  static const List<MaterialColor> colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _loadingType = false;
  String? _pokemonType;

  Future<void> _setColorByPokemon(BuildContext context) async {
    setState(() => _loadingType = true);
    final userService = UserFirestoreService();
    final userData = await userService.getUserData();
    final photoUrl = userData?['photoUrl'];
    String? type;

    if (photoUrl != null) {
      // Extrae el número de pokémon del URL
      final regex = RegExp(r'/(\d+)\.png');
      final match = regex.firstMatch(photoUrl);
      if (match != null) {
        final pokeId = match.group(1);
        // Llama a la pokeapi para obtener el tipo
        final response = await http.get(
          Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokeId'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final types = data['types'] as List;
          if (types.isNotEmpty) {
            type = types[0]['type']['name'];
          }
        }
      }
    }

    setState(() {
      _loadingType = false;
      _pokemonType = type;
    });

    if (type != null) {
      Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).setPrimaryColorByType(type);
      Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).setAutoColorByPokemon(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Color cambiado según tu Pokémon de perfil ($type)'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo detectar el tipo de tu Pokémon de perfil'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Modo oscuro'),
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleDarkMode(value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Color principal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Wrap(
              spacing: 12,
              children: SettingPage.colorOptions.map((color) {
                return ChoiceChip(
                  label: Text(
                    color.toString().split('.').last,
                    style: TextStyle(
                      color: themeProvider.primaryColor == color
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: themeProvider.primaryColor == color,
                  selectedColor: color,
                  backgroundColor: color.shade100,
                  onSelected: (_) {
                    themeProvider.setPrimaryColor(color);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Usar color según tu Pokémon de perfil'),
              trailing: _loadingType
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: themeProvider.autoColorByPokemon,
                      onChanged: (value) async {
                        if (value) {
                          await _setColorByPokemon(context);
                        } else {
                          themeProvider.setAutoColorByPokemon(false);
                        }
                      },
                    ),
              subtitle: themeProvider.autoColorByPokemon && _pokemonType != null
                  ? Text('Tipo detectado: $_pokemonType')
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
