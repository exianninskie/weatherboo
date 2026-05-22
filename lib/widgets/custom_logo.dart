import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomLogo extends StatelessWidget {
  final double size;
  final bool showFull;

  const CustomLogo({
    super.key,
    this.size = 200,
    this.showFull = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weather icon
        Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.cloud,
              size: size * 0.35,
              color: Colors.white,
            ),
          ),
        ),
        if (showFull) ...[
          SizedBox(height: size * 0.1),
          // Text logo
          Text(
            'Weatherboo',
            style: GoogleFonts.quicksand(
              fontSize: size * 0.2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: size * 0.05),
          // Tagline
          Text(
            'Your Weather Companion',
            style: GoogleFonts.quicksand(
              fontSize: size * 0.08,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF667EEA),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
