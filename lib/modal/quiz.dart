import 'package:quiz_project/modal/question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String categoryId;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.timeLimit,
    required this.questions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id: id,
      title: map['title'] ?? "",
      categoryId: map['categoryId'] ?? "",
      timeLimit: map['timeLimit'] is int
          ? map['timeLimit']
          : int.tryParse(map['timeLimit'].toString()) ?? 0,
      questions: (map['questions'] as List<dynamic>? ?? [])
          .map((e) => Question.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimit,
      'questions': questions.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toMapV2() {
    return {
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimit,
      'questions': questions.map((e) => e.toMap()).toList(),
      'createdAt': createdAt ?? DateTime.now(),
      'updateAt': DateTime.now(),
    };
  }

  Quiz copyWith({
    String? title,
    String? categoryId,
    int? timeLimit,
    List<Question>? questions,
  }) {
    return Quiz(
      id: id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

}
