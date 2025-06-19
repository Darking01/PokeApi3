import 'package:flutter/material.dart';
import '../services/poke_services.dart';
import '../services/firestore_service.dart';
import 'favoritos.dart';
import 'detalles.dart';
import 'perfil.dart';
import 'login.dart';

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
  List<Map<String, dynamic>> _pokemonsCache = [];
  String _search = '';
  final UserFirestoreService _userService = UserFirestoreService();

  String? _photoUrl;
  String? _username;

  // Paginación
  final ScrollController _scrollController = ScrollController();
  int _currentOffset = 0;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMorePokemons();
    _loadFavoritos();
    _loadProfileData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMorePokemons() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final pokemons = await PokemonService.fetchPokemons(
      limit: _pageSize,
      offset: _currentOffset,
    );
    if (!mounted) return;
    setState(() {
      _pokemonsCache.addAll(pokemons);
      _currentOffset += _pageSize;
      _isLoadingMore = false;
      if (pokemons.length < _pageSize) _hasMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePokemons();
    }
  }

  Future<void> _loadFavoritos() async {
    final favoritos = await _userService.getFavoritos();
    if (!mounted) return;
    setState(() {
      _favoritos = favoritos.toSet();
    });
  }

  Future<void> _loadProfileData() async {
    final data = await _userService.getUserData();
    if (!mounted) return;
    setState(() {
      _photoUrl = data?['photoUrl'];
      _username = data?['username'] ?? '';
    });
  }

  void _toggleFavorito(String name) async {
    setState(() {
      if (_favoritos.contains(name)) {
        _favoritos.remove(name);
      } else {
        _favoritos.add(name);
      }
      _notificaciones++;
    });
    await _userService.updateFavoritos(_favoritos.toList());
  }

  void _removeFavorito(String name) async {
    setState(() {
      _favoritos.remove(name);
      _notificaciones++;
    });
    await _userService.updateFavoritos(_favoritos.toList());
  }

  Drawer buildAppDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.redAccent),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: _photoUrl == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  _username ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
              ).then((value) async {
                await _loadProfileData();
                if (!mounted) return;
                setState(() {});
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
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
          icon: CircleAvatar(
            backgroundImage: _photoUrl != null
                ? NetworkImage(_photoUrl!)
                : null,
            child: _photoUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
            backgroundColor: Colors.grey[300],
            radius: 16,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PerfilPage(favoritosCount: _favoritos.length),
              ),
            ).then((value) async {
              await _loadProfileData();
              if (!mounted) return;
              setState(() {});
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPokemones() {
    if (_pokemonsCache.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final filtered = _pokemonsCache
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
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: filtered.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= filtered.length) {
                return const Center(child: CircularProgressIndicator());
              }
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
                          onPressed: () async {
                            Navigator.pop(context); // Cierra el diálogo
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetallesPage(pokemonName: pokemon['name']),
                              ),
                            );
                            if (result == true) {
                              await _loadFavoritos();
                              setState(() {});
                            }
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
            favoritos: _pokemonsCache
                .where((poke) => _favoritos.contains(poke['name']))
                .toList(),
            onRemove: _removeFavorito,
          ),
        ],
      ),
    );
  }
}
