import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class LoadingShimmer extends StatelessWidget {
  final ShimmerType type;
  final int itemCount;
  final double height;
  final double width;

  const LoadingShimmer({
    this.type = ShimmerType.cardShimmer,
    this.itemCount = 1,
    this.height = 100,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ShimmerType.cardShimmer:
        return _buildCardShimmer();
      case ShimmerType.listItemShimmer:
        return _buildListItemShimmer();
      case ShimmerType.circleShimmer:
        return _buildCircleShimmer();
      case ShimmerType.rectangleShimmer:
        return _buildRectangleShimmer();
    }
  }

  Widget _buildCardShimmer() {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingS,
            horizontal: AppSizes.paddingM,
          ),
          child: Shimmer.fromColors(
            baseColor: AppColors.lightCardBackground,
            highlightColor: Colors.grey[300]!,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItemShimmer() {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingM,
            horizontal: AppSizes.paddingM,
          ),
          child: Shimmer.fromColors(
            baseColor: AppColors.lightCardBackground,
            highlightColor: Colors.grey[300]!,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircleShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightCardBackground,
      highlightColor: Colors.grey[300]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildRectangleShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightCardBackground,
      highlightColor: Colors.grey[300]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
      ),
    );
  }
}

enum ShimmerType { cardShimmer, listItemShimmer, circleShimmer, rectangleShimmer }
