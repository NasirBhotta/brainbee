import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/presentation/views/learn/bb_popup_items.dart';
import 'package:flutter/material.dart';

void showSlidingPopup(
  BuildContext context,
  List<Map<String, dynamic>> items, {
  VoidCallback? onDismiss,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isDismissible: true,
    enableDrag: true,
    builder:
        (context) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder:
              (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        child: Column(
                          children: [
                            if (items.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Text(
                                  'Choose an option',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D3436),
                                  ),
                                ),
                              ),
                            _buildItemsGrid(context, items),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
  ).then((_) {
    if (onDismiss != null) onDismiss();
  });
}

Widget _buildItemsGrid(BuildContext context, List<Map<String, dynamic>> items) {
  // Determine layout based on item count and content
  final isBattleMode =
      items.isNotEmpty && items[0]['title']?.startsWith('Battle') == true;

  if (items.length <= 3) {
    // Horizontal layout for 3 or fewer items
    return Row(
      mainAxisAlignment:
          isBattleMode
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.spaceBetween,
      children:
          items.asMap().entries.map((entry) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: items.length == 1 ? 0 : 8,
                ),
                child: _buildEnhancedItem(context, entry.key, entry.value),
              ),
            );
          }).toList(),
    );
  } else {
    // Grid layout for more items
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildEnhancedItem(context, index, items[index]);
      },
    );
  }
}

Widget _buildEnhancedItem(
  BuildContext context,
  int index,
  Map<String, dynamic> item,
) {
  return Container(
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 245, 245, 245),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color.fromARGB(255, 245, 245, 245),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item['navigateTo']!),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image/Icon container
              if (item['imgPath'] != null)
                SizedBox(
                  width: 50,
                  height: 50,

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        item['imgPath']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Color(0xFFB0B0B0),
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Title
              if (item['title'] != null)
                Text(
                  item['title']!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D3436),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
