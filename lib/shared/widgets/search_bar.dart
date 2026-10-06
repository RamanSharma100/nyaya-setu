import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool darkMode;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkMode ? Colors.white.withValues(alpha: 0.12) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: darkMode ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade200,
        ),
        boxShadow: darkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          color: darkMode ? Colors.white : AppColors.textPrimaryDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: darkMode ? Colors.white.withValues(alpha: 0.4) : Colors.grey.shade400,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: darkMode ? AppColors.accentGold : AppColors.textMutedDark,
            size: 20,
          ),
          suffixIcon: controller != null && (controller?.text.isNotEmpty ?? false)
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: darkMode ? Colors.white54 : Colors.grey.shade400,
                    size: 18,
                  ),
                  onPressed: () {
                    controller!.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
