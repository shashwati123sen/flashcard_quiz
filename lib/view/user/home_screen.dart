import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../Theme/theme.dart';
import '../../modal/category.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];

  List<String> _categoryFilters = ['All'];
  String _selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("categories")
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      _allCategories = snapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();

      _categoryFilters = ['All'] +
          _allCategories.map((category) => category.name).toSet().toList();

      _filteredCategories = _allCategories;
    });
  }

  void _filterCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        final matchesSearch = category.name.toLowerCase().contains(query.toLowerCase()) ||
            category.description.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = categoryFilter == null ||
            categoryFilter == "All" ||
            category.name.toLowerCase() == categoryFilter.toLowerCase();
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildCategoryCard(BuildContext context, Category category, int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(category: category),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.quiz,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                category.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.5, end: 0, duration: Duration(milliseconds: 300))
        .fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            floating: true,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            title: Text(
              "FlashCard Quiz",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: kToolbarHeight + 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, Learner!!!!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Let's test your knowledge",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _filterCategories(value),
                              decoration: InputDecoration(
                                hintText: "Search Categories ....",
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.primaryColor,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterCategories('');
                                  },
                                  icon: Icon(Icons.clear),
                                  color: AppTheme.primaryColor,
                                )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(16),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryFilters.length,
                itemBuilder: (context, index) {
                  final filter = _categoryFilters[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                      selected: _selectedFilter == filter,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilter = filter;
                          _filterCategories(
                            _searchController.text,
                            categoryFilter: filter,
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: _filteredCategories.isEmpty
                ? SliverToBoxAdapter(
              child: Center(
                child: Text(
                  "No Categories found",
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            )
                : SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCategoryCard(
                    context, _filteredCategories[index], index),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
