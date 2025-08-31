import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OptimizedImage {
  static Widget build({
    required BuildContext context, // Add context parameter
    required String imageUrl,
    required double height,
    double? width,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    required Set<String> preloadedImages,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width ?? double.infinity,
      fit: fit,
      placeholder: !preloadedImages.contains(imageUrl) ? (context, url) => Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6750A4)),
          ),
        ),
      ) : null,
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[400], size: 24),
            const SizedBox(height: 4),
            Text(
              'Image unavailable',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 100),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheHeight: (height * MediaQuery.of(context).devicePixelRatio).round(),
      memCacheWidth: width != null
          ? (width! * MediaQuery.of(context).devicePixelRatio).round()
          : null,
    );
  }
}
