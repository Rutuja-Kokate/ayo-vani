import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Stored teacher profile model for classroom identity and analytics provenance.
class TeacherProfile {
  final String teacherId;
  final String name;
  final String role;
  final String className;
  final String focus;
  final String schoolId;
  final int studentsCount;

  const TeacherProfile({
    required this.teacherId,
    required this.name,
    this.role = 'Classroom Educator',
    this.className = 'Class 1',
    this.focus = 'Primary Section • Tribal Language Focus',
    this.schoolId = 'school_primary_01',
    this.studentsCount = 32,
  });

  Map<String, dynamic> toJson() => {
        'teacherId': teacherId,
        'name': name,
        'role': role,
        'className': className,
        'focus': focus,
        'schoolId': schoolId,
        'studentsCount': studentsCount,
      };

  factory TeacherProfile.fromJson(Map<String, dynamic> json) => TeacherProfile(
        teacherId: json['teacherId'] as String? ?? 'teacher_01',
        name: json['name'] as String? ?? 'Teacher',
        role: json['role'] as String? ?? 'Classroom Educator',
        className: json['className'] as String? ?? 'Class 1',
        focus: json['focus'] as String? ?? 'Primary Section • Tribal Language Focus',
        schoolId: json['schoolId'] as String? ?? 'school_primary_01',
        studentsCount: json['studentsCount'] as int? ?? 32,
      );

  TeacherProfile copyWith({
    String? teacherId,
    String? name,
    String? role,
    String? className,
    String? focus,
    String? schoolId,
    int? studentsCount,
  }) =>
      TeacherProfile(
        teacherId: teacherId ?? this.teacherId,
        name: name ?? this.name,
        role: role ?? this.role,
        className: className ?? this.className,
        focus: focus ?? this.focus,
        schoolId: schoolId ?? this.schoolId,
        studentsCount: studentsCount ?? this.studentsCount,
      );
}

/// Service managing persistent per-install device UUID and teacher identity.
class TeacherProfileService {
  static final TeacherProfileService instance =
      TeacherProfileService._internal();
  factory TeacherProfileService() => instance;
  TeacherProfileService._internal();

  static const String _kDeviceIdKey = 'ayo_device_uuid';
  static const String _kTeacherIdKey = 'ayo_teacher_id';
  static const String _kTeacherNameKey = 'ayo_teacher_name';
  static const String _kTeacherRoleKey = 'ayo_teacher_role';
  static const String _kTeacherClassKey = 'ayo_teacher_class';
  static const String _kTeacherFocusKey = 'ayo_teacher_focus';
  static const String _kSchoolIdKey = 'ayo_school_id';
  static const String _kStudentsCountKey = 'ayo_students_count';

  String? _deviceId;
  TeacherProfile? _currentProfile;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Per-install UUID persisted in shared_preferences
    _deviceId = prefs.getString(_kDeviceIdKey);
    if (_deviceId == null || _deviceId!.isEmpty) {
      _deviceId = const Uuid().v4();
      await prefs.setString(_kDeviceIdKey, _deviceId!);
    }

    // 2. Teacher identity from persistent profile store
    var teacherId = prefs.getString(_kTeacherIdKey);
    if (teacherId == null || teacherId.isEmpty) {
      teacherId = 'teacher_${_deviceId!.substring(0, 8)}';
      await prefs.setString(_kTeacherIdKey, teacherId);
    }
    final teacherName = prefs.getString(_kTeacherNameKey) ?? 'Teacher';
    final role = prefs.getString(_kTeacherRoleKey) ?? 'Classroom Educator';
    final className = prefs.getString(_kTeacherClassKey) ?? 'Class 1';
    final focus = prefs.getString(_kTeacherFocusKey) ?? 'Primary Section • Tribal Language Focus';
    final schoolId = prefs.getString(_kSchoolIdKey) ?? 'school_primary_01';
    final studentsCount = prefs.getInt(_kStudentsCountKey) ?? 32;

    _currentProfile = TeacherProfile(
      teacherId: teacherId,
      name: teacherName,
      role: role,
      className: className,
      focus: focus,
      schoolId: schoolId,
      studentsCount: studentsCount,
    );
  }

  /// Returns the per-install device UUID.
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    await init();
    return _deviceId!;
  }

  /// Returns the active teacher profile.
  Future<TeacherProfile> getProfile() async {
    if (_currentProfile != null) return _currentProfile!;
    await init();
    return _currentProfile!;
  }

  /// Returns the teacher ID for validation provenance.
  Future<String> getTeacherId() async {
    final profile = await getProfile();
    return profile.teacherId;
  }

  /// Updates and persists the teacher profile.
  Future<void> saveProfile(TeacherProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTeacherIdKey, profile.teacherId);
    await prefs.setString(_kTeacherNameKey, profile.name);
    await prefs.setString(_kTeacherRoleKey, profile.role);
    await prefs.setString(_kTeacherClassKey, profile.className);
    await prefs.setString(_kTeacherFocusKey, profile.focus);
    await prefs.setString(_kSchoolIdKey, profile.schoolId);
    await prefs.setInt(_kStudentsCountKey, profile.studentsCount);
    _currentProfile = profile;
  }
}
