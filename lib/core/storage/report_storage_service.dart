import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/report/models/skincare_report_model.dart';

class ReportStorageService {
  static const String _keyReportsHistory = 'aimm_skincare_reports_history';
  static const int _maxStoredReports = 100;

  static ReportStorageService? _instance;
  static ReportStorageService get instance => _instance ??= ReportStorageService._();
  ReportStorageService._();

  /// Retrieves all saved skincare reports, ordered from newest to oldest
  Future<List<SkincareReportModel>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyReportsHistory);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
      final reports = decodedList
          .map((item) => SkincareReportModel.fromMap(item as Map<String, dynamic>))
          .toList();
      // Sort by start time descending
      reports.sort((a, b) => b.startTime.compareTo(a.startTime));
      return reports;
    } catch (_) {
      return [];
    }
  }

  /// Saves a new report to persistent storage
  Future<void> saveReport(SkincareReportModel newReport) async {
    final reports = await getReports();
    // Prepend new report or update if id already exists
    reports.removeWhere((r) => r.id == newReport.id);
    reports.insert(0, newReport);

    // Keep within storage limit
    if (reports.length > _maxStoredReports) {
      reports.removeRange(_maxStoredReports, reports.length);
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonList = reports.map((r) => r.toMap()).toList();
    await prefs.setString(_keyReportsHistory, jsonEncode(jsonList));
  }

  /// Deletes a single report by ID
  Future<void> deleteReport(String id) async {
    final reports = await getReports();
    reports.removeWhere((r) => r.id == id);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = reports.map((r) => r.toMap()).toList();
    await prefs.setString(_keyReportsHistory, jsonEncode(jsonList));
  }

  /// Clears all historical reports
  Future<void> clearReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyReportsHistory);
  }
}
