import 'package:flutter/material.dart';
import '../services/poke_services.dart';
import '../services/firestore_service.dart';
import '../utility/poke_stat_bar.dart';

class DetallesPage extends StatefulWidget {
  final String pokemonName;
  const DetallesPage({Key? key, required this.pokemonName}) : super(key: key);

  static const statIcons = {
    'hp': Icons.favorite,
    'attack': Icons.flash_on,
    'defense': Icons.shield,
    'special-attack': Icons.bolt,
    'special-defense': Icons.security,
    'speed': Icons.directions_run,
  };

  static const statColors = {
    'hp': Colors.red,
    'attack': Colors.orange,
    'defense': Colors.blue,
    'special-attack': Colors.purple,
    'special-defense': Colors.green,
    'speed': Colors.amber,
  };

  @override
  State<DetallesPage> createState() => _DetallesPageState();
}

class _DetallesPageState extends State<DetallesPage> {
  bool _isFavorito = false;
  bool _loadingFav = false;
  bool _favoritoCambiado = false;
  final UserFirestoreService _userService = UserFirestoreService();

  @override
  void initState() {
    super.initState();
    _checkFavorito();
  }

  Future<void> _checkFavorito() async {
    final favoritos = await _userService.getFavoritos();
    if (!mounted) return;
    setState(() {
      _isFavorito = favoritos.contains(widget.pokemonName);
    });
  }

  Future<void> _toggleFavorito() async {
    setState(() => _loadingFav = true);
    final favoritos = await _userService.getFavoritos();
    if (favoritos.contains(widget.pokemonName)) {
      favoritos.remove(widget.pokemonName);
    } else {
      favoritos.add(widget.pokemonName);
    }
    await _userService.updateFavoritos(favoritos);
    if (!mounted) return;
    setState(() {
      _isFavorito = favoritos.contains(widget.pokemonName);
      _loadingFav = false;
      _favoritoCambiado = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorito ? '¡Agregado a favoritos!' : 'Eliminado de favoritos',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Pokémon'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _favoritoCambiado);
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PokemonService.fetchPokemonDetail(widget.pokemonName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (data['image'] != null)
                  Image.network(
                    data['image'],
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(height: 16),
                Text(
                  data['name'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Tipos
                if (data['types'] != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Tipo(s): ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...List<Widget>.from(
                        (data['types'] as List).map(
                          (type) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(type.toString().toUpperCase()),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                // Peso y altura
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Peso: ${data['weight'] ?? '-'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Altura: ${data['height'] ?? '-'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Habilidades
                if (data['abilities'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Habilidades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: (data['abilities'] as List)
                            .map<Widget>(
                              (a) => ActionChip(
                                label: Text(a.toString()),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const AlertDialog(
                                      content: SizedBox(
                                        height: 60,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                  );
                                  final desc =
                                      await PokemonService.fetchAbilityDescription(
                                        a.toString(),
                                      );
                                  if (!mounted) return;
                                  Navigator.pop(context); // Cierra el loading
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(a.toString().toUpperCase()),
                                      content: Text(desc),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                _loadingFav
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: Icon(
                          _isFavorito ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorito ? Colors.red : Colors.grey,
                        ),
                        label: Text(
                          _isFavorito
                              ? 'Quitar de favoritos'
                              : 'Agregar a favoritos',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFavorito
                              ? Colors.red[100]
                              : Colors.grey[200],
                          foregroundColor: Colors.black,
                          minimumSize: const Size(180, 48),
                        ),
                        onPressed: _toggleFavorito,
                      ),
                const SizedBox(height: 24),
                const Text(
                  'Estadísticas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...List<Widget>.from(
                  (data['stats'] as List).map((stat) {
                    final statName = stat['name'] as String;
                    final baseStat = stat['base_stat'] as int;
                    final icon =
                        DetallesPage.statIcons[statName] ?? Icons.bar_chart;
                    final color =
                        DetallesPage.statColors[statName] ?? Colors.blueGrey;
                    return PokeStatBar(
                      statName: statName,
                      baseStat: baseStat,
                      icon: icon,
                      color: color,
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
