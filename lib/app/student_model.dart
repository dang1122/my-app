class Student {
  final int id;
  final String name;
  final String grade;
  final String session;
  final String date;
  String status;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.session,
    required this.date,
    required this.status,
  });

  Student copyWith({String? status}) {
    return Student(
      id: id,
      name: name,
      grade: grade,
      session: session,
      date: date,
      status: status ?? this.status,
    );
  }
}
