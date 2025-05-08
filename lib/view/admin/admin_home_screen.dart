import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../Theme/theme.dart';
import 'Manage_Quiz_Screen.dart';
import 'manage_categories_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount = await _firestore.collection('categories').count().get();
    final quizzesCount = await _firestore.collection('quizzes').count().get();

    final latestQuizzes = await _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final categories = await _firestore.collection('categories').get();
    final categoryData = await Future.wait(
      categories.docs.map(
            (category) async {
          final quizCount = await _firestore
              .collection('quizzes')
              .where('categoryId', isEqualTo: category.id)
              .count()
              .get();

          return {
            'name': category.data()['name'] as String,
            'count': quizCount.count,
          };
        },
      ),
    );

    return {
      'totalCategories': categoriesCount.count,
      'totalQuizzes': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'categoryData': categoryData
    };
  }

  String _formatData(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 32),
              ),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Admin Dashboard',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occured'));
          }

          final Map<String, dynamic> state = snapshot.data!;
          final List<dynamic> categoryData = state['categoryData'];
          final List<QueryDocumentSnapshot> latestQuizzes = state['latestQuizzes'];

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Here is your quiz application overview",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Categories',
                          state['totalCategories'].toString(),
                          Icons.category,
                          AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Quizzes',
                          state['totalQuizzes'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(29),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pie_chart_rounded,
                                  color: AppTheme.primaryColor, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Category Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: categoryData.length,
                            itemBuilder: (context, index) {
                              final category = categoryData[index];
                              final totalQuizzes = categoryData.fold<int>(
                                  0, (sum, item) => sum + (item['count'] as int));
                              final percentage = totalQuizzes > 0
                                  ? (category['count'] as int) /
                                  totalQuizzes *
                                  100
                                  : 0.0;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['name'] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            '${category['count']} ${category['count'] == 1 ? 'quiz' : 'quizzes'}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${percentage.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(29),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history_rounded,
                                  color: AppTheme.primaryColor, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: latestQuizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = latestQuizzes[index].data()
                              as Map<String, dynamic>;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                        AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.quiz_rounded,
                                          color: AppTheme.primaryColor, size: 20),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            quiz['title'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Created on ${_formatData(quiz['createdAt'].toDate())}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textSecondaryColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(29),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.speed_rounded,
                                  color: AppTheme.primaryColor, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Quiz Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _buildDashboardCard(
                                context,
                                'Quizzes',
                                Icons.quiz_rounded,
                                    () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ManageQuizScreen()));
                                },
                              ),
                              _buildDashboardCard(
                                context,
                                'Categories',
                                Icons.category_rounded,
                                    () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManageCategoriesScreen()));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
