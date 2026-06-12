import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_list_vm.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _tempCategory;
  late double _tempMinPrice;
  late double _tempMaxPrice;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ProductListViewModel>(context, listen: false);
    _tempCategory = vm.selectedCategory;
    _tempMinPrice = vm.minPrice;
    _tempMaxPrice = vm.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductListViewModel>(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title & Clear Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempCategory = '';
                    _tempMinPrice = 0.0;
                    _tempMaxPrice = 2000.0;
                  });
                },
                child: const Text(
                  'Reset All',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 15),

          // Price range filter section
          const Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${_tempMinPrice.round()}', style: const TextStyle(color: Colors.grey)),
              Text('\$${_tempMaxPrice.round()}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          RangeSlider(
            values: RangeValues(_tempMinPrice, _tempMaxPrice),
            min: 0.0,
            max: 2000.0,
            divisions: 40,
            activeColor: Colors.cyanAccent,
            inactiveColor: Colors.white12,
            labels: RangeLabels(
              '\$${_tempMinPrice.round()}',
              '\$${_tempMaxPrice.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _tempMinPrice = values.start;
                _tempMaxPrice = values.end;
              });
            },
          ),
          const SizedBox(height: 20),

          // Categories section
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vm.categories.length,
              itemBuilder: (context, index) {
                final cat = vm.categories[index];
                final slug = cat['slug']!;
                final name = cat['name']!;
                final isSelected = _tempCategory == slug;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      name,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.cyanAccent,
                    backgroundColor: const Color(0xFF2E2E2E),
                    checkmarkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Colors.cyanAccent : Colors.transparent,
                      ),
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _tempCategory = slug;
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Update state in ViewModel
                    vm.updatePriceRange(_tempMinPrice, _tempMaxPrice);
                    vm.selectCategory(_tempCategory);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
