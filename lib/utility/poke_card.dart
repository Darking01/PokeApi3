import 'package:flutter/material.dart';
import 'image_ui.dart';

class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> pokemon;
  final bool isFavorito;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onDeleteTap;
  final double? imageSize;

  const PokemonCard({
    Key? key,
    required this.pokemon,
    this.isFavorito = false,
    this.onTap,
    this.onFavoriteTap,
    this.onDeleteTap,
    this.imageSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardPadding = 12;
    final double nameBarHeight = 36;
    final double iconButtonSize = 32;
    final double imageMaxSize = (imageSize ?? 100) - nameBarHeight - cardPadding * 2;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              // Fondo de carta
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    AppImages.cartaPokemon,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              // Imagen del Pokémon centrada y limitada
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: cardPadding,
                    left: cardPadding,
                    right: cardPadding,
                    bottom: nameBarHeight + cardPadding,
                  ),
                  child: pokemon['image'] != null
                      ? Image.network(
                          pokemon['image'],
                          width: imageMaxSize,
                          height: imageMaxSize,
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              // Nombre del Pokémon, siempre visible abajo
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: nameBarHeight,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    pokemon['name'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Botón de favorito o eliminar
              Positioned(
                top: 8,
                right: 8,
                child: onDeleteTap != null
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        iconSize: iconButtonSize,
                        onPressed: onDeleteTap,
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: isFavorito ? Colors.red : Colors.grey,
                        ),
                        iconSize: iconButtonSize,
                        onPressed: onFavoriteTap,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
