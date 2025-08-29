import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teb_mesada/features/activity/activity.dart';

enum ScheduleFrequency { daily, weekDay, selectedDates }

class Schedule {
  static const collectionName = 'schedule';
  static const daysOfWeek = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

  late String id;
  late String familyId;
  late String childUserId;
  late String activityId;
  late ScheduleFrequency scheduleFrequency;
  late List<DateTime> selectedDates;
  late Activity activity;
  late bool mandatory;
  late bool positiveConsequence;
  late double consequenceValue;
  late List<String> weekSelectedDay;
  late int monthSelectedDay;
  late Map<DateTime, bool> appointments;

  late TextEditingController consequenceValueTextController = TextEditingController();

  Schedule({
    this.id = '',
    this.familyId = '',
    this.activityId = '',
    this.childUserId = '',
    this.mandatory = false,
    this.positiveConsequence = true,
    this.consequenceValue = 0.0,
    this.scheduleFrequency = ScheduleFrequency.daily,
    List<DateTime>? selectedDates,
    List<String>? weekSelectedDay,
    this.monthSelectedDay = 1,
    Activity? activity,
    Map<DateTime, bool>? appointments,
  }) {
    this.activity = activity ?? Activity(familyId: familyId);
    this.weekSelectedDay = weekSelectedDay ?? [];
    this.selectedDates = selectedDates ?? [];
    this.appointments = appointments ?? {};
    consequenceValueTextController.text = consequenceValue.toString();
  }

  bool hasAppointment(DateTime datetime) {
    return appointments[DateTime(datetime.year, datetime.month, datetime.day)] ?? false;
  }

  bool get hasAppointmentToday => hasAppointment(DateTime.now());

  static ScheduleFrequency scheduleFrequencyFromString(String value) {
    return value == ScheduleFrequency.daily.name
        ? ScheduleFrequency.daily
        : value == ScheduleFrequency.weekDay.name
        ? ScheduleFrequency.weekDay
        : ScheduleFrequency.selectedDates;
  }

  bool hasScheduleOnDate(DateTime date) {
    if (scheduleFrequency == ScheduleFrequency.daily) {
      return true;
    }

    if (scheduleFrequency == ScheduleFrequency.selectedDates) {
      return selectedDates.contains(DateTime(date.year, date.month, date.day));
    }

    if (scheduleFrequency == ScheduleFrequency.weekDay) {
      return weekSelectedDay.contains(Schedule.daysOfWeek[date.weekday - 1]);
    }

    return false;
  }

  static String scheduleFrequencyName(ScheduleFrequency value) {
    return value.name == ScheduleFrequency.daily.name
        ? 'Diária'
        : value.name == ScheduleFrequency.weekDay.name
        ? 'Dias da semana'
        : 'Datas pré-determinadas';
  }

  static Map<String, bool> serializeAppointments(Map<DateTime, bool> appointments) {
    return appointments.map((key, value) {
      return MapEntry(DateFormat('yyyy-MM-dd').format(key), value);
    });
  }

  static Map<DateTime, bool> deserializeAppointments(dynamic appointments) {
    if (appointments == null || appointments is! Map) return {};

    final Map<String, dynamic> appointmentsMap = Map<String, dynamic>.from(appointments);

    final Map<DateTime, bool> result = {};

    appointmentsMap.forEach((stringKey, dynamicValue) {
      result[DateTime.parse(stringKey)] = dynamicValue;
    });

    return result;
  }

  static Schedule fromMap(Map<String, dynamic> map) {
    var schedule = Schedule();

    try {
      schedule = Schedule(
        id: map['id'] ?? '',
        familyId: map['familyId'] ?? '',
        activityId: map['activityId'] ?? '',
        childUserId: map['childUserId'] ?? '',
        mandatory: map['mandatory'] ?? false,
        positiveConsequence: map['positiveConsequence'] ?? true,
        consequenceValue: map['consequenceValue'] ?? 0.0,
        scheduleFrequency: scheduleFrequencyFromString(map['scheduleFrequency'] ?? ''),
        selectedDates:
            (map['selectedDates'] as List<dynamic>?)
                ?.map((e) => DateTime.fromMicrosecondsSinceEpoch(e.microsecondsSinceEpoch))
                .toList() ??
            [],
        weekSelectedDay:
            (map['weekSelectedDay'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        monthSelectedDay: map['monthSelectedDay'] ?? 1,
        appointments: deserializeAppointments(map['appointments'] ?? {}),
      );

      return schedule;
    } catch (e) {
      return schedule;
    }
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};

    r = {
      'id': id,
      'familyId': familyId,
      'activityId': activityId,
      'childUserId': childUserId,
      'mandatory': mandatory,
      'positiveConsequence': positiveConsequence,
      'consequenceValue': consequenceValue,
      'scheduleFrequency': scheduleFrequency.name,
      'selectedDates': selectedDates,
      'weekSelectedDay': weekSelectedDay,
      'monthSelectedDay': monthSelectedDay,
      'appointments': serializeAppointments(appointments),
    };

    return r;
  }
}
