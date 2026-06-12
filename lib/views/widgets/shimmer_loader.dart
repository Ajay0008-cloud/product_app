import 'package:flutter/material.dart';

class ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF16161A),
                Color(0xFF222226),
                Color(0xFF16161A),
              ],
              stops: [
                0.0,
                0.5 + 0.3 * (1.0 - (_controller.value * 2 - 1.0).abs()), // Wave effect
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFF16161A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: ShimmerPlaceholder(
              width: double.infinity,
              height: 150,
              borderRadius: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0, right: 12.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag skeleton
                const ShimmerPlaceholder(width: 60, height: 12, borderRadius: 4),
                const SizedBox(height: 8),
                // Title skeleton
                const ShimmerPlaceholder(width: double.infinity, height: 16, borderRadius: 4),
                const SizedBox(height: 6),
                const ShimmerPlaceholder(width: 120, height: 16, borderRadius: 4),
                const SizedBox(height: 12),
                // Price and Rating row skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerPlaceholder(width: 50, height: 18, borderRadius: 4),
                    ShimmerPlaceholder(width: 40, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerGridLoader extends StatelessWidget {
  const ShimmerGridLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const ShimmerProductCard(),
    );
  }
}
