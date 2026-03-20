import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  
  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class CharacterCardShimmer extends StatelessWidget {
  const CharacterCardShimmer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            const Center(
              child: LoadingShimmer(
                width: 80,
                height: 80,
                borderRadius: 40,
              ),
            ),
            const SizedBox(height: 12),
            
            // Name
            const LoadingShimmer(
              width: double.infinity,
              height: 20,
            ),
            const SizedBox(height: 8),
            
            // Tags
            Row(
              children: [
                const LoadingShimmer(width: 60, height: 16),
                const SizedBox(width: 8),
                const LoadingShimmer(width: 50, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ListItemShimmer extends StatelessWidget {
  const ListItemShimmer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const LoadingShimmer(width: 48, height: 48, borderRadius: 24),
      title: const LoadingShimmer(width: double.infinity, height: 16),
      subtitle: const Padding(
        padding: EdgeInsets.only(top: 8),
        child: LoadingShimmer(width: 200, height: 12),
      ),
    );
  }
}
