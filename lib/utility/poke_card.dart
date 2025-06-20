import 'package:flutter/material.dart';

class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final bool isFavorito;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDeleteTap;

  const PokemonCard({
    Key? key,
    required this.pokemon,
    this.isFavorito = false,
    this.onTap,
    this.onFavoriteTap,
    this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: onDeleteTap != null
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDeleteTap,
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: isFavorito ? Colors.red : Colors.grey,
                      ),
                      onPressed: onFavoriteTap,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
