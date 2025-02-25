class DailyChallenge {
  final DateTime date;
  bool isCompleted;

  DailyChallenge({
    required this.date,
    this.isCompleted = false,
  });

  // Add methods to convert to/from JSON for persistence
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'],
    );
  }
}
