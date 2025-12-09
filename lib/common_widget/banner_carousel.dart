import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eco_snap/common/color_extension.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final List<String> images = [
    'assets/img/banner1.png',
    'assets/img/banner2.png',
    'assets/img/banner3.png',
    'assets/img/banner4.png',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CarouselSlider(
            items: images
                .map(
                  (imagePath) => Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                .toList(),
            options: CarouselOptions(
              height: 180,
              autoPlay: true, // เปิด auto play
              autoPlayInterval: const Duration(seconds: 5), // เลื่อนเองทุก 5 วิ
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: images.asMap().entries.map((entry) {
            final isActive = _currentIndex == entry.key;
            return Container(
              width: isActive ? 12 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? TColor.gray80 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
