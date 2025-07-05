import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scanner/app/student_model.dart';
import 'package:scanner/screens/logs/logs_cb.dart';

class Attendance extends GetView<AttendanceController> {
  const Attendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDarkMode.value;

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
        body: SafeArea(
          child: Obx(
            () => switch (controller.view.value) {
              AttendanceView.loaded => Column(
                children: [
                  // Header
                  _buildHeader(controller, isDark),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          // Stats Cards
                          _buildStatsCards(controller, isDark),
                          SizedBox(height: 16.h),

                          // Date Selection & Search
                          _buildSearchAndFilters(controller, isDark),
                          SizedBox(height: 16.h),

                          // Student List
                          _buildStudentList(controller, isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AttendanceView.loading => Center(
                child: CircularProgressIndicator(
                  color: isDark ? Colors.white : Colors.blue.shade600,
                ),
              ),
            },
          ),
        ),
      );
    });
  }

  Widget _buildHeader(AttendanceController controller, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color:
                          isDark ? Colors.blue.shade400 : Colors.blue.shade600,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Attendance',
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Morning & Afternoon Sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Dark mode toggle button
              Container(
                height: 35.h,
                width: 35.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.yellow.shade600 : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  onPressed: () => controller.isDarkMode.toggle(),
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 35.h,
                width: 35.h,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.download, color: Colors.white, size: 16.sp),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 35.h,
                width: 35.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  onPressed: () => Get.offAndToNamed('/scanner'),
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(AttendanceController controller, bool isDark) {
    return Obx(
      () => Row(
        children: [
          _buildStatCard(
            'Total',
            controller.totalStudents.toString(),
            isDark ? Colors.grey.shade300 : Colors.grey.shade900,
            isDark,
          ),
          SizedBox(width: 8.w),
          _buildStatCard(
            'Present',
            controller.presentCount.toString(),
            Colors.green.shade600,
            isDark,
          ),
          SizedBox(width: 8.w),
          _buildStatCard(
            'Absent',
            controller.absentCount.toString(),
            Colors.red.shade600,
            isDark,
          ),
          SizedBox(width: 8.w),
          _buildStatCard(
            'Late',
            controller.lateCount.toString(),
            Colors.orange.shade600,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(AttendanceController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          Text(
            'Select Date',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8.r),
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              ),
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: isDark ? ThemeData.dark() : ThemeData.light(),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    controller.selectedDate.value = DateFormat(
                      'yyyy-MM-dd',
                    ).format(date);
                    controller.fetchLogs();
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16.sp,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      controller.selectedDate.value.isNotEmpty
                          ? DateFormat('MMM dd, yyyy').format(
                            DateTime.parse(controller.selectedDate.value),
                          )
                          : 'Select Date',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color:
                            isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Search and Filter Row
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchTerm.value = value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 16.sp,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.blue.shade700 : Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: InkWell(
                  onTap: () => showFilterBottomSheet(controller, isDark),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Filter',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Active Filters
          Obx(() {
            final hasActiveFilters =
                controller.selectedGrade.value != 'All' ||
                controller.selectedSession.value != 'All' ||
                controller.selectedStatus.value != 'All';

            if (!hasActiveFilters) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Wrap(
                spacing: 4.w,
                runSpacing: 4.h,
                children: [
                  if (controller.selectedGrade.value != 'All')
                    _buildFilterChip(
                      controller.selectedGrade.value,
                      Colors.blue,
                      () => controller.selectedGrade.value = 'All',
                      isDark,
                    ),
                  if (controller.selectedSession.value != 'All')
                    _buildFilterChip(
                      controller.selectedSession.value,
                      Colors.purple,
                      () => controller.selectedSession.value = 'All',
                      isDark,
                    ),
                  if (controller.selectedStatus.value != 'All')
                    _buildFilterChip(
                      controller.selectedStatus.value,
                      Colors.green,
                      () => controller.selectedStatus.value = 'All',
                      isDark,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    Color color,
    VoidCallback onRemove,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: isDark ? color : color,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14.sp,
              color: isDark ? color : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(AttendanceController controller, bool isDark) {
    return Obx(() {
      if (controller.filteredStudents.isEmpty) {
        return Container(
          padding: EdgeInsets.all(48.w),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48.sp,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                'No attendance records found',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children:
            controller.filteredStudents
                .map(
                  (student) => _buildStudentCard(student, controller, isDark),
                )
                .toList(),
      );
    });
  }

  Widget _buildStudentCard(
    Student student,
    AttendanceController controller,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(
                              isDark ? 0.3 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            student.grade,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark
                                      ? Colors.indigo.shade300
                                      : Colors.indigo.shade800,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                student.session == 'Morning'
                                    ? Colors.blue.withOpacity(
                                      isDark ? 0.3 : 0.1,
                                    )
                                    : Colors.purple.withOpacity(
                                      isDark ? 0.3 : 0.1,
                                    ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            student.session,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  student.session == 'Morning'
                                      ? isDark
                                          ? Colors.blue.shade300
                                          : Colors.blue.shade800
                                      : isDark
                                      ? Colors.purple.shade300
                                      : Colors.purple.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM dd').format(DateTime.parse(student.date)),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: controller
                          .getStatusBackgroundColor(student.status)
                          .withOpacity(isDark ? 0.3 : 1.0),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.getStatusIcon(student.status),
                          size: 12.sp,
                          color:
                              isDark
                                  ? controller.getStatusColor(student.status)
                                  : controller.getStatusColor(student.status),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          student.status,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark
                                    ? controller.getStatusColor(student.status)
                                    : controller.getStatusColor(student.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showFilterBottomSheet(AttendanceController controller, bool isDark) {
    Get.bottomSheet(
      Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 20.sp,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Filter Options',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.close,
                          size: 24.sp,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Grade Level Filter
                  SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grade Level',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Wrap(
                            spacing: 8.w,
                            children:
                                [
                                      'All',
                                      'Nursery',
                                      'Kindergarten',
                                      'Grade 1',
                                      'Grade 2',
                                      'Grade 3',
                                      'Grade 4',
                                      'Grade 5',
                                      'Grade 6',
                                    ]
                                    .map(
                                      (grade) => ChoiceChip(
                                        label: Text(
                                          grade,
                                          style: TextStyle(
                                            color:
                                                controller
                                                            .selectedGrade
                                                            .value ==
                                                        grade
                                                    ? Colors.white
                                                    : isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        selected:
                                            controller.selectedGrade.value ==
                                            grade,
                                        selectedColor:
                                            isDark
                                                ? Colors.blue.shade700
                                                : Colors.blue.shade600,
                                        backgroundColor:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade200,
                                        onSelected: (selected) {
                                          if (selected) {
                                            controller.selectedGrade.value =
                                                grade;
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Session Filter
                  SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Wrap(
                            spacing: 8.w,
                            children:
                                ['All', 'Morning', 'Afternoon']
                                    .map(
                                      (session) => ChoiceChip(
                                        label: Text(
                                          session,
                                          style: TextStyle(
                                            color:
                                                controller
                                                            .selectedSession
                                                            .value ==
                                                        session
                                                    ? Colors.white
                                                    : isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        selected:
                                            controller.selectedSession.value ==
                                            session,
                                        selectedColor:
                                            isDark
                                                ? Colors.purple.shade700
                                                : Colors.purple.shade600,
                                        backgroundColor:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade200,
                                        onSelected: (selected) {
                                          if (selected) {
                                            controller.selectedSession.value =
                                                session;
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Attendance Status Filter
                  SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Status',
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(
                          () => Wrap(
                            spacing: 8.w,
                            children:
                                ['All', 'Present', 'Absent', 'Late']
                                    .map(
                                      (status) => ChoiceChip(
                                        label: Text(
                                          status,
                                          style: TextStyle(
                                            color:
                                                controller
                                                            .selectedStatus
                                                            .value ==
                                                        status
                                                    ? Colors.white
                                                    : isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        selected:
                                            controller.selectedStatus.value ==
                                            status,
                                        selectedColor:
                                            isDark
                                                ? Colors.green.shade700
                                                : Colors.green.shade600,
                                        backgroundColor:
                                            isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade200,
                                        onSelected: (selected) {
                                          if (selected) {
                                            controller.selectedStatus.value =
                                                status;
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearFilters();
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                            ),
                          ),
                          child: Text(
                            'Clear Filters',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark
                                    ? Colors.blue.shade700
                                    : Colors.blue.shade600,
                          ),
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(Get.context!).viewInsets.bottom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      isScrollControlled: true,
    );
  }
}
