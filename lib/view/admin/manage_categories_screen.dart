import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_project/view/admin/Manage_Quiz_Screen.dart';
import 'package:quiz_project/view/admin/add_quiz_screen.dart';

import '../../Theme/theme.dart';
import '../../modal/category.dart';
import 'add_category_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Quizzes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppTheme.primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("categories").orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final categories = snapshot.data!.docs
              .map((doc) => Category.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: AppTheme.textSecondaryColor),
                  const SizedBox(height: 16),
                  Text(
                    "No categories found",
                    style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddCategoryScreen()),
                      );
                    },
                    child: const Text("Add Category"),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(26),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.category_outlined, color: AppTheme.primaryColor),
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(category.description),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "edit",
                        child: ListTile(
                          leading: Icon(Icons.edit, color: AppTheme.primaryColor),
                          title: const Text("Edit"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text("Delete"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleCategoryAction(context, value, category),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageQuizScreen(categoryId: category.id, categoryName: category.name,), // ✅ pass category object
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleCategoryAction(
      BuildContext context,
      String action,
      Category category,
      ) async {
    if (action == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCategoryScreen(category: category), // ✅ fix null here
        ),
      );
    } else if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Category"),
          content: const Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
            )
          ],
        ),
      );

      if (confirm == true) {
        await _firestore.collection("categories").doc(category.id).delete();
      }
    }
  }
}
