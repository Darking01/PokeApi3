import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class PokemonService {
  static Future<List<Map<String, dynamic>>> fetchPokemons({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      final pokemons = await Future.wait(
        results.map((item) async {
          final detailResponse = await http.get(Uri.parse(item['url']));
          if (detailResponse.statusCode == 200) {
            final detailData = json.decode(detailResponse.body);
            final id = detailData['id'];
            final imageUrl =
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
            return {'name': detailData['name'], 'image': imageUrl};
          }
          return {'name': item['name'], 'image': null};
        }),
      );

      return pokemons;
    } else {
      throw Exception('Error al cargar los pokémones');
    }
  }

  // NUEVO: Obtener detalles y estadísticas de un Pokémon por nombre
  static Future<Map<String, dynamic>> fetchPokemonDetail(String name) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final id = data['id'];
      final imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
      final stats = data['stats']
          .map(
            (stat) => {
              'name': stat['stat']['name'],
              'base_stat': stat['base_stat'],
            },
          )
          .toList();
      final abilities = data['abilities']
          .map((a) => a['ability']['name'])
          .toList();
      final types = data['types'].map((t) => t['type']['name']).toList();
      final weight = data['weight'];
      final height = data['height'];
      return {
        'name': data['name'],
        'image': imageUrl,
        'stats': stats,
        'abilities': abilities,
        'types': types,
        'weight': weight,
        'height': height,
      };
    } else {
      throw Exception('Error al cargar detalles del pokémon');
    }
  }

  static Future<String> fetchAbilityDescription(String abilityName) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/ability/$abilityName'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final effectEntries = data['effect_entries'] as List;
      final entry = effectEntries.firstWhere(
        (e) => e['language']['name'] == 'es',
        orElse: () => effectEntries.firstWhere(
          (e) => e['language']['name'] == 'en',
          orElse: () => null,
        ),
      );
      return entry != null ? entry['effect'] : 'Sin descripción disponible';
    } else {
      return 'No se pudo obtener la descripción';
    }
  }
}

String getRandomPokemonImageUrl() {
  final random = Random();
  final pokeId = random.nextInt(898) + 1; // 1 a 898
  return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokeId.png';
}
