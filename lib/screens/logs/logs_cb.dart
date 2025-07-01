import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scanner/app/constant.dart';
import 'package:scanner/app/settings_mixin.dart';
import 'package:scanner/app/student_model.dart';
import 'package:scanner/app/user_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AttendanceView { loading, loaded }

class AttendanceController extends GetxController with SettingsMixin {
  var view = AttendanceView.loading.obs;
  final RxList<Student> _allStudents = <Student>[].obs;
  final RxList<dynamic> _allStudentsList =
      <dynamic>[].obs; // All students from database
  final RxList<dynamic> _checkInData = <dynamic>[].obs; // Check-in data

  final RxList<Student> filteredStudents = <Student>[].obs;
  final RxString searchTerm = ''.obs;
  final RxString selectedGrade = 'All'.obs;
  final RxString selectedSession = 'All'.obs;
  final RxString selectedStatus = 'All'.obs;
  final RxString selectedDate = ''.obs;
  final RxBool showFilterModal = false.obs;

  final List<String> grades = [
    'All',
    'Kinder',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
  ];
  final List<String> sessions = ['All', 'Morning', 'Afternoon'];
  final List<String> statuses = ['All', 'Present', 'Absent', 'Late'];

  @override
  void onInit() async {
    super.onInit();
    User user = User.fromJson(
      jsonDecode((await SharedPreferences.getInstance()).getString('user')!),
    );
    selectedDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Listen to changes
    ever(searchTerm, (_) => _filterStudents());
    ever(selectedGrade, (_) => _filterStudents());
    ever(selectedSession, (_) => _filterStudents());
    ever(selectedStatus, (_) => _filterStudents());
    ever(selectedDate, (_) => _filterStudents());

    await _loadAllData(int.parse(user.id));
    await loadSettings();
    view(AttendanceView.loaded);
  }

  Future<void> _loadAllData(int userId) async {
    try {
      // First, get all students
      await _fetchAllStudents(userId);

      // Then, get check-in data for today
      await _fetchCheckInData(userId);

      // Process and combine the data
      _processAttendanceData();

      // Apply filters
      _filterStudents();
    } catch (e) {
      print('Error loading attendance data: $e');
    }
  }

  Future<void> _fetchAllStudents(int userId) async {
    var res = await GetConnect()
        .post("${AppStrings.baseUrl}student_checkin/api.php", {
          "method": "SELECT",
          "target": "*",
          "table": "students",
          "where": "incharge='$userId'",
          "token": "sdaesi",
        });
    print("res ${res.body}");

    if (res.statusCode == 200 && res.body != null) {
      _allStudentsList.value = res.body['data'] ?? [];
      print('Fetched ${_allStudentsList.length} students');
    }
  }

  Future<void> _fetchCheckInData(int userId) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    var res = await GetConnect().post(
      "${AppStrings.baseUrl}student_checkin/api.php",
      {
        "method": "SELECT",
        "target": "*",
        "table": "checkins",
        "where": "scan_date='$today'", // incharge='$userId' AND
        "token": "sdaesi",
      },
    );

    if (res.statusCode == 200 && res.body != null) {
      _checkInData.value = res.body['data'] ?? [];
      print('Fetched ${_checkInData.length} check-in records for today');
    }
  }

  void _processAttendanceData() {
    _allStudents.clear();
    DateTime now = DateTime.now();
    bool isAfter6PM = now.hour >= 18; // 6 PM check
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Create a map of check-in data for quick lookup
    Map<String, dynamic> checkInMap = {};
    for (var checkIn in _checkInData) {
      String studentKey = '${checkIn['lrn']}';

      checkInMap[studentKey] = checkIn;
    }

    // Process each student
    for (int i = 0; i < _allStudentsList.length; i++) {
      var student = _allStudentsList[i];
      String studentKey = '${student['lrn']}';
      var checkInRecord = checkInMap[studentKey];

      String studentName = "${student['first_name']} ${student['last_name']}";
      String grade = student['grade'] ?? '';
      int studentId = student['id'] ?? i;

      // Morning session
      print("checkin: ${checkInRecord}");
      String morningStatus = _determineMorningStatus(checkInRecord, isAfter6PM);
      _allStudents.add(
        Student(
          id: (studentId * 2) + 1,
          name: studentName,
          grade: grade,
          session: 'Morning',
          date: today,
          status: morningStatus,
        ),
      );

      // Afternoon session
      String afternoonStatus = _determineAfternoonStatus(
        checkInRecord,
        isAfter6PM,
      );
      _allStudents.add(
        Student(
          id: (studentId * 2) + 2,
          name: studentName,
          grade: grade,
          session: 'Afternoon',
          date: today,
          status: afternoonStatus,
        ),
      );
    }

    print('Processed ${_allStudents.length} attendance records');
  }

  String _determineMorningStatus(dynamic checkInRecord, bool isAfter6PM) {
    if (checkInRecord == null) {
      // No check-in record exists
      return isAfter6PM ? 'Absent' : 'Pending';
    }

    String? amIn = checkInRecord['am_in'];
    String? amOut = checkInRecord['am_out'];

    if (amIn != null || amOut != null) {
      // Check if late (assuming morning starts at 8:00 AM)
      if (amIn != null) {
        try {
          DateTime checkInTime = DateTime.parse(
            '${checkInRecord['scan_date']} $amIn',
          );

          DateTime morningStart = DateTime(
            checkInTime.year,
            checkInTime.month,
            checkInTime.day,
            8,
            0,
          );

          if (checkInTime.isAfter(morningStart)) {
            return 'Late';
          }
        } catch (e) {
          print('Error parsing morning check-in time: $e');
        }
      }
      return 'Present';
    }

    // No morning check-in data
    return isAfter6PM ? 'Absent' : 'Pending';
  }

  String _determineAfternoonStatus(dynamic checkInRecord, bool isAfter6PM) {
    if (checkInRecord == null) {
      // No check-in record exists
      return isAfter6PM ? 'Absent' : 'Pending';
    }

    String? pmIn = checkInRecord['pm_in'];
    String? pmOut = checkInRecord['pm_out'];

    if (pmIn != null || pmOut != null) {
      // Check if late (assuming afternoon starts at 1:00 PM)
      if (pmIn != null) {
        try {
          DateTime checkInTime = DateTime.parse(
            '${checkInRecord['scan_date']} $pmIn',
          );
          DateTime afternoonStart = DateTime(
            checkInTime.year,
            checkInTime.month,
            checkInTime.day,
            13,
            0,
          );

          if (checkInTime.isAfter(afternoonStart)) {
            return 'Late';
          }
        } catch (e) {
          print('Error parsing afternoon check-in time: $e');
        }
      }
      return 'Present';
    }

    // No afternoon check-in data
    return isAfter6PM ? 'Absent' : 'Pending';
  }

  void _filterStudents() {
    List<Student> filtered = List.from(_allStudents);

    // Search filter
    if (searchTerm.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (student) =>
                    student.name.toLowerCase().contains(
                      searchTerm.value.toLowerCase(),
                    ) ||
                    student.grade.toLowerCase().contains(
                      searchTerm.value.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Grade filter
    if (selectedGrade.value != 'All') {
      filtered =
          filtered
              .where((student) => student.grade == selectedGrade.value)
              .toList();
    }

    // Session filter
    if (selectedSession.value != 'All') {
      filtered =
          filtered
              .where((student) => student.session == selectedSession.value)
              .toList();
    }

    // Status filter
    if (selectedStatus.value != 'All') {
      filtered =
          filtered
              .where((student) => student.status == selectedStatus.value)
              .toList();
    }

    // Date filter
    if (selectedDate.value.isNotEmpty) {
      filtered =
          filtered
              .where((student) => student.date == selectedDate.value)
              .toList();
    }

    filteredStudents.value = filtered;
  }

  void updateStudentStatus(int studentId, String newStatus) {
    final index = _allStudents.indexWhere((student) => student.id == studentId);
    if (index != -1) {
      _allStudents[index].status = newStatus;
      _allStudents.refresh();
      _filterStudents();
    }
  }

  void clearFilters() {
    selectedGrade.value = 'All';
    selectedSession.value = 'All';
    selectedStatus.value = 'All';
    searchTerm.value = '';
  }

  // Refresh data manually
  Future<void> refreshData() async {
    view(AttendanceView.loading);
    User user = User.fromJson(
      jsonDecode((await SharedPreferences.getInstance()).getString('user')!),
    );
    await _loadAllData(int.parse(user.id));
    view(AttendanceView.loaded);
  }

  // Stats getters
  int get totalStudents => filteredStudents.length;
  int get presentCount =>
      filteredStudents.where((s) => s.status == 'Present').length;
  int get absentCount =>
      filteredStudents.where((s) => s.status == 'Absent').length;
  int get lateCount => filteredStudents.where((s) => s.status == 'Late').length;
  int get pendingCount =>
      filteredStudents.where((s) => s.status == 'Pending').length;

  Color getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green.withOpacity(0.1);
      case 'Absent':
        return Colors.red.withOpacity(0.1);
      case 'Late':
        return Colors.orange.withOpacity(0.1);
      case 'Pending':
        return Colors.blue.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Present':
        return Icons.check_circle_outline;
      case 'Absent':
        return Icons.cancel_outlined;
      case 'Late':
        return Icons.access_time;
      case 'Pending':
        return Icons.schedule;
      default:
        return Icons.people_outline;
    }
  }
}

class AttendanceBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceController());
  }
}
