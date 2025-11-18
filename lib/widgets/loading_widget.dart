import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class PlaylistLoadingList extends StatelessWidget {
  const PlaylistLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoadingWidget(
                width: 150,
                height: 150,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(height: 8),
              const LoadingWidget(
                width: 120,
                height: 16,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              const SizedBox(height: 4),
              const LoadingWidget(
                width: 80,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TrackLoadingList extends StatelessWidget {
  const TrackLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const LoadingWidget(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LoadingWidget(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    const SizedBox(height: 4),
                    const LoadingWidget(
                      width: 120,
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CenterLoadingWidget extends StatelessWidget {
  final String? message;
  
  const CenterLoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
