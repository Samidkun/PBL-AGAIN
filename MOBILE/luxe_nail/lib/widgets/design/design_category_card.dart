import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxe_nail/utils/responsive.dart';

class DesignCategoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isSelected;
  final Function(int) onSelected;
  final String baseUrl;

  const DesignCategoryCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelected,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final int price = (item['price'] ?? 0) as int;
    final String name = (item['name'] ?? '').toString();
    final String imagePath = (item['image'] ?? '').toString();
    final String imageUrl = imagePath.isEmpty ? '' : '$baseUrl/$imagePath';

    final priceText = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);

    final cardWidth = Responsive.sW(context, 120);

    return GestureDetector(
      onTap: () => onSelected(item['id'] as int),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9E6475) : const Color(0xFFAF7C85),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // PRICE BAR (atas)
            Container(
              width: double.infinity,
              height: Responsive.sH(context, 22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  priceText,
                  style: const TextStyle(
                    color: Color(0xFF451A2B),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // BOX PUTIH UNTUK GAMBAR (tengah)
            Container(
              width: double.infinity,
              height: Responsive.sH(context, 78),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: Color(0xFFB97A8B),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 24,
                        color: Color(0xFFB97A8B),
                      ),
                    ),
            ),

            const SizedBox(height: 6),

            // BOX PUTIH UNTUK NAMA (bawah)
            Container(
              width: double.infinity,
              height: Responsive.sH(context, 22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEE),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF451A2B),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
