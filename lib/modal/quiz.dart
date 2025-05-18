import 'question.dart';

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
      title: map['title'] ?? '',
      categoryId: map['categoryId'] ?? '',
      timeLimit: map['timeLimit'] ?? 0,
      questions: (map['questions'] as List)
          .map((e) => Question.fromMap(e))
          .toList(),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimit,
      'questions': questions.map((e) => e.toMap()).toList(),
      'createdAt' : DateTime.now(),
      'updatedAt' : DateTime.now(),
    };
  }

  Quiz copyWith({
    String? title,
    String? categoryId,
    int? timeLimit,
    List<Question>? questions,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id ,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }


}
