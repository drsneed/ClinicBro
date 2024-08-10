import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'scheduler_controls.dart'; // Ensure this is correctly imported

class SchedulerCarousel extends StatelessWidget {
  final void Function(String viewMode) onViewModeChange;
  final String selectedViewMode;
  final void Function(bool isMultiple) onViewTypeChange;
  final bool isMultiple;
  final void Function(bool showNavigation) onShowNavigationChange;
  final bool showNavigation;
  final void Function() onRefresh;
  const SchedulerCarousel({
    Key? key,
    required this.onViewModeChange,
    required this.selectedViewMode,
    required this.onViewTypeChange,
    required this.isMultiple,
    required this.onShowNavigationChange,
    required this.showNavigation,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 36.0, // Adjust height if needed
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
        initialPage: 0,
        scrollDirection: Axis.horizontal,
        autoPlay: false, // Disable auto-play if not needed
        enlargeCenterPage: false, // Adjust if needed
      ),
      items: [
        SchedulerControls(
          onViewModeChange: onViewModeChange,
          selectedViewMode: selectedViewMode,
          onViewTypeChange: onViewTypeChange,
          isMultiple: isMultiple,
          onShowNavigationChange: onShowNavigationChange,
          showNavigation: showNavigation,
          onRefresh: onRefresh,
        ),
        // Add more items here if needed
      ],
    );
  }
}
