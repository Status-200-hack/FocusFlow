class FocusSessionModel {
  final String id;
  final String userId;
  final int durationMinutes;
  final DateTime completedAt;
  final String? taskId;
  final DateTime createdAt;

  FocusSessionModel({
    required this.id,
    required this.userId,
    required this.durationMinutes,
    required this.completedAt,
    this.taskId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'durationMinutes': durationMinutes,
    'completedAt': completedAt.toIso8601String(),
    'taskId': taskId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) => FocusSessionModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    durationMinutes: json['durationMinutes'] as int,
    completedAt: DateTime.parse(json['completedAt'] as String),
    taskId: json['taskId'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  FocusSessionModel copyWith({
    String? id,
    String? userId,
    int? durationMinutes,
    DateTime? completedAt,
    String? taskId,
    DateTime? createdAt,
  }) => FocusSessionModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    completedAt: completedAt ?? this.completedAt,
    taskId: taskId ?? this.taskId,
    createdAt: createdAt ?? this.createdAt,
  );
}
