import 'package:flutter/material.dart';
import '../services/recipe_service.dart';

/// Resolves image_url to a full URL and displays it.
/// image_url may be:
///   - null → shows placeholder
///   - "/static/images/..." → prepends kBaseUrl
///   - "https://..." → used as-is (TikTok CDN thumbnail)
class RecipeImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  String? get _resolvedUrl {
    final url = imageUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '$kBaseUrl$url';
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final child = url != null
        ? Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : _placeholder();

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8E0D0),
      child: const Center(
        child: Text('🍽️', style: TextStyle(fontSize: 36)),
      ),
    );
  }
}
