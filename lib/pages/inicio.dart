import 'package:flutter/material.dart';
import '../services/poke_services.dart';
import 'favoritos.dart';
import 'detalles.dart';
import 'perfil.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({Key? key}) : super(key: key);

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<String> _favoritos = {};
  int _notificaciones = 0;
  List<Map<String, dynamic>>? _pokemonsCache;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPokemons();
  }

  Future<void> _loadPokemons() async {
    final pokemons = await PokemonService.fetchPokemons(limit: 151);
    if (!mounted) return;
    setState(() {
      _pokemonsCache = pokemons;
    });
  }

  void _toggleFavorito(String name) {
    setState(() {
      if (_favoritos.contains(name)) {
        _favoritos.remove(name);
        _notificaciones++;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
      } else {
        _favoritos.add(name);
        _notificaciones++;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Agregado a favoritos')));
      }
    });
  }

  void _removeFavorito(String name) {
    setState(() {
      _favoritos.remove(name);
      _notificaciones++;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Eliminado de favoritos')));
    });
  }

  Drawer buildAppDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.redAccent),
            child: Center(
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favoritos'),
            onTap: () {
              Navigator.pop(context);
              _tabController.animateTo(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PerfilPage(favoritosCount: _favoritos.length),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('PokeDesk'),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.catching_pokemon), text: "Pokemones"),
          Tab(icon: Icon(Icons.favorite), text: "Favoritos"),
        ],
      ),
      actions: [
        // Notificaciones
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                setState(() {
                  _notificaciones = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No hay nuevas notificaciones')),
                );
              },
            ),
            if (_notificaciones > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$_notificaciones',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Perfil
        IconButton(
          icon: const CircleAvatar(
            backgroundImage: AssetImage('assets/profile.png'),
            radius: 16,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PerfilPage(favoritosCount: _favoritos.length),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPokemones() {
    if (_pokemonsCache == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final filtered = _pokemonsCache!
        .where(
          (p) => p['name'].toString().toLowerCase().contains(
            _search.toLowerCase(),
          ),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar Pokémon',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final pokemon = filtered[index];
              final isFavorito = _favoritos.contains(pokemon['name']);
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(pokemon['name'].toString().toUpperCase()),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pokemon['image'] != null)
                            Image.network(
                              pokemon['image'],
                              width: 140,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          const SizedBox(height: 16),
                          const Text('¡Un pokémon salvaje ha aparecido!'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Atrás'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Cierra el diálogo
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetallesPage(pokemonName: pokemon['name']),
                              ),
                            );
                          },
                          child: const Text('Ver estadística'),
                        ),
                      ],
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (pokemon['image'] != null)
                              Image.network(
                                pokemon['image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            const SizedBox(height: 12),
                            Text(
                              pokemon['name'].toString().toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: isFavorito ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorito(pokemon['name']),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: buildAppDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPokemones(),
          FavoritosScreen(
            favoritos:
                _pokemonsCache
                    ?.where((poke) => _favoritos.contains(poke['name']))
                    .toList() ??
                [],
            onRemove: _removeFavorito,
          ),
        ],
      ),
    );
  }
}
