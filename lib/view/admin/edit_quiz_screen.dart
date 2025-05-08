import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Theme/theme.dart';
import '../../modal/question.dart';
import '../../modal/quiz.dart';

class EditQuizScreen extends StatefulWidget {
  final Quiz quiz;
  const EditQuizScreen({super.key, required this.quiz});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
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

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  late List<QuestionFormItem> _questionsItem;

  @override
  void initState() {
    super.initState();
    _initData();
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

  void _initData() {
    _titleController = TextEditingController(text: widget.quiz.title);
    _timeLimitController = TextEditingController(text: widget.quiz.timeLimit.toString());

    _questionsItem = widget.quiz.questions.map((question) {
      return QuestionFormItem(
        questionController: TextEditingController(text: question.text),
        optionsControllers: question.options.map((option) => TextEditingController(text: option)).toList(),
        correctOptionIndex: question.correctOptionIndex,
      );
    }).toList();
  }

  void _addQuestion() {
    setState(() {
      _questionsItem.add(
        QuestionFormItem(
          questionController: TextEditingController(),
          optionsControllers: List.generate(4, (e) => TextEditingController()),
          correctOptionIndex: 0,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    if (_questionsItem.length > 1) {
      setState(() {
        _questionsItem[index].dispose();
        _questionsItem.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Quiz must have at least one question"),
        ),
      );
    }
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) return;

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

      final quizDoc = _firestore.collection("quizzes").doc(widget.quiz.id);

      final updateQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        timeLimit: int.parse(_timeLimitController.text),
        questions: questions,
      );
      await quizDoc.update(updateQuiz.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Quiz updated successfully", style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update quiz", style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}
