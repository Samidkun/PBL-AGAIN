import 'package:flutter/material.dart';
import 'package:luxe_nail/services/api_service.dart';

class DesignStepPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<dynamic> items;
  final String? selectedValue;
  final Function(String) onSelect;
  final VoidCallback? onSkip;
  final VoidCallback onNext;
  final bool disabled;

  const DesignStepPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.selectedValue,
    required this.onSelect,
    required this.onNext,
    this.onSkip,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF451A2B),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF975B73),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text("No items available"))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item['name'] == selectedValue;
                    final imageUrl = item['image'] != null
                        ? "${ApiService.baseUrl}/served-image/${item['image']}"
                        : null;

                    return GestureDetector(
                      onTap: disabled
                          ? null
                          : () {
                              onSelect(item['name']);
                              onNext();
                            },
                      child: Opacity(
                        opacity: disabled ? 0.5 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF975B73)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(17)),
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[100],
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[100],
                                          child: const Icon(Icons.image,
                                              color: Colors.grey),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  item['name'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isSelected
                                        ? const Color(0xFF975B73)
                                        : const Color(0xFF451A2B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
