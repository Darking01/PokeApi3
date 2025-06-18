import 'package:flutter/material.dart';

class FavoritosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoritos;
  final Function(String) onRemove;

  const FavoritosScreen({
    Key? key,
    required this.favoritos,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favoritos.isEmpty) {
      return const Center(child: Text('No tienes favoritos aún.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final pokemon = favoritos[index];

        return Card(
          elevation: 4.0,
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemove(pokemon['name']),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
