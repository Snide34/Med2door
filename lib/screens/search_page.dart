import 'package:flutter/material.dart';
import 'package:med2door/product.dart';
import 'package:med2door/services/product_service.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  List<Product> _allMedicines = [];
  List<Product> _filteredMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
    _searchController.addListener(_filterMedicines);
  }

  Future<void> _fetchMedicines() async {
    try {
      final products = await ProductService().getProducts();
      if (mounted) {
        setState(() {
          _allMedicines = products;
          _filteredMedicines = _allMedicines;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching medicines: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMedicines);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMedicines() {
    setState(() {
      _filteredMedicines = _allMedicines.where((medicine) {
        final matchesSearch = medicine.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            medicine.composition.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' || medicine.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_colors.kGrey50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: app_colors.kWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search Medicines', style: TextStyle(color: app_colors.kWhite, fontWeight: FontWeight.w600)),
        backgroundColor: app_colors.kPrimaryTealDark,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildResultsCount(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMedicines.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: app_colors.kWhite,
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search medicines...',
          prefixIcon: const Icon(Icons.search, color: app_colors.kIconGrey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: app_colors.kIconGrey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: app_colors.kGrey50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    const categories = ['All', 'Pain Relief', 'Vitamins', 'Acne', 'ADHD','Covid Care', 'First Aid'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      color: app_colors.kWhite,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _filterMedicines();
                    });
                  }
                },
                selectedColor: app_colors.kPrimaryTeal,
                labelStyle: TextStyle(color: isSelected ? app_colors.kWhite : app_colors.kPrimaryTealDark),
                backgroundColor: app_colors.kWhite,
                shape: StadiumBorder(side: BorderSide(color: isSelected ? app_colors.kPrimaryTeal : app_colors.kBorderGrey)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text('${_filteredMedicines.length} results found', style: const TextStyle(color: app_colors.kTextGrey)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off, size: 80, color: app_colors.kGrey),
          SizedBox(height: 16),
          Text('No medicines found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: app_colors.kGrey800)),
          Text('Try adjusting your search or filter', style: TextStyle(color: app_colors.kTextGrey)),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredMedicines.length,
      itemBuilder: (context, index) {
        final medicine = _filteredMedicines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: app_colors.kGrey.withAlpha(26),
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed('/medicine-details', arguments: medicine),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: medicine.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: app_colors.kGrey200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: app_colors.kGrey200,
                        child: const Icon(Icons.image_not_supported, color: app_colors.kGrey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(medicine.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(medicine.composition, style: const TextStyle(color: app_colors.kTextGrey), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Text('₹${double.tryParse(medicine.price)?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: app_colors.kPrimaryTealDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
