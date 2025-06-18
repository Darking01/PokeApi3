import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonService {
  static Future<List<Map<String, dynamic>>> fetchPokemons({
    int limit = 151,
  }) async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit'),
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
      return {'name': data['name'], 'image': imageUrl, 'stats': stats};
    } else {
      throw Exception('Error al cargar detalles del pokémon');
    }
  }
}
