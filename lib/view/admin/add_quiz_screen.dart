import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Theme/theme.dart';
import '../../modal/category.dart';
import '../../modal/question.dart';
import '../../modal/quiz.dart';

class AddQuizScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  const AddQuizScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class QuestionFormItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionsControllers;
  int correctOptionIndex;

  QuestionFormItem({
    required this.questionController,
    required this.optionsControllers,
    required this.correctOptionIndex,
  });

  void dispose() {
    questionController.dispose();
    for (var controller in optionsControllers) {
      controller.dispose();
    }
  }
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<QuestionFormItem> _questionsItem = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _addQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionsItem) {
      item.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questionsItem.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          optionsControllers: List.generate(4, (_) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionsItem[index].dispose();
      _questionsItem.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questions = _questionsItem.map((item) {
        return Question(
          text: item.questionController.text.trim(),
          options: item.optionsControllers.map((e) => e.text.trim()).toList(),
          correctOptionIndex: item.correctOptionIndex,
        );
      }).toList();

      final quizDoc = _firestore.collection("quizzes").doc();

      await quizDoc.set(
        Quiz(
          id: quizDoc.id,
          title: _titleController.text.trim(),
          categoryId: _selectedCategoryId!,
          timeLimit: int.parse(_timeLimitController.text),
          questions: questions,
          createdAt: DateTime.now(),
        ).toMap(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Quiz added successfully", style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add quiz", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text( widget.categoryName != null ? "Add ${widget.categoryName} QUiz":"Add Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quiz Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
                SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    labelText: "Quiz Title",
                    hintText: "Enter quiz title",
                    prefixIcon: Icon(Icons.title, color: AppTheme.primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter quiz title";
                    return null;
                  },
                ),
                SizedBox(height: 20),
                if (widget.categoryId == null)
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('categories').orderBy('name').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Text("Error");
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                      }
                      final categories = snapshot.data!.docs
                          .map((doc) => Category.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                          .toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 20),
                          labelText: "Category",
                          hintText: "Select category",
                          prefixIcon: Icon(Icons.category, color: AppTheme.primaryColor),
                        ),
                        items: categories
                            .map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ))
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Please select a category";
                          return null;
                        },
                      );
                    },
                  ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _timeLimitController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    labelText: "Time Limit (in minute)",
                    hintText: "Enter time limit",
                    prefixIcon: Icon(Icons.timer, color: AppTheme.primaryColor),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    if (value == null || value.isEmpty) return "Please enter time limit";
                    if (number == null || number <= 0) return "Please enter a valid time limit";
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Questions',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor)),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          label: Text('Add Question'),
                          icon: Icon(Icons.add),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    ..._questionsItem.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Question ${index + 1}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor)),
                                  if (_questionsItem.length > 1)
                                    IconButton(
                                      onPressed: () => _removeQuestion(index),
                                      icon: Icon(Icons.delete, color: Colors.redAccent),
                                    )
                                ],
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: question.questionController,
                                decoration: InputDecoration(
                                  labelText: "Question Title",
                                  hintText: "Enter question",
                                  prefixIcon: Icon(Icons.question_answer, color: AppTheme.primaryColor),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return "Please enter question";
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              ...question.optionsControllers.asMap().entries.map((entry) {
                                final optionIndex = entry.key;
                                final controller = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                        activeColor: AppTheme.primaryColor,
                                        value: optionIndex,
                                        groupValue: question.correctOptionIndex,
                                        onChanged: (value) {
                                          setState(() {
                                            question.correctOptionIndex = value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            labelText: "Option ${optionIndex + 1}",
                                            hintText: "Enter option",
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) return "Please enter option";
                                            return null;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 32),
                    Center(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                              : Text("Save Quiz",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
