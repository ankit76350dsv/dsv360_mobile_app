import 'package:dsv360/models/holiday.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HolidayRepository extends AsyncNotifier<List<Holiday>> {
  @override
  Future<List<Holiday>> build() async {
    return _getMockHolidays();
  }

  Future<List<Holiday>> _getMockHolidays() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final List<Holiday> allHolidays = [];
    final locations = ['Mumbai', 'Pune'];

    final holidaysData = [
      {'date': '2026-01-26', 'name': 'Republic Day', 'month': 'January 2026'},
      {'date': '2026-02-26', 'name': 'Mahashivratri', 'month': 'February 2026'},
      {'date': '2026-03-04', 'name': 'Holi', 'month': 'March 2026'},
      {'date': '2026-03-19', 'name': 'Gudi Padwa', 'month': 'March 2026'},
      {'date': '2026-04-03', 'name': 'Good Friday', 'month': 'April 2026'},
      {'date': '2026-04-05', 'name': 'Ram Navami', 'month': 'April 2026'},
      {'date': '2026-04-10', 'name': 'Eid al-Fitr', 'month': 'April 2026'},
      {
        'date': '2026-05-01',
        'name': 'Maharashtra Day / Labour Day',
        'month': 'May 2026',
      },
      {'date': '2026-06-17', 'name': 'Bakri Eid', 'month': 'June 2026'},
      {
        'date': '2026-08-15',
        'name': 'Independence Day',
        'month': 'August 2026',
      },
      {
        'date': '2026-09-17',
        'name': 'Ganesh Chaturthi',
        'month': 'September 2026',
      },
      {'date': '2026-10-02', 'name': 'Gandhi Jayanti', 'month': 'October 2026'},
      {'date': '2026-12-25', 'name': 'Christmas', 'month': 'December 2026'},
    ];

    for (var loc in locations) {
      for (var h in holidaysData) {
        allHolidays.add(
          Holiday(
            date: h['date']!,
            name: h['name']!,
            location: loc,
            month: h['month']!,
          ),
        );
      }
    }

    return allHolidays;
  }
}

final holidayRepositoryProvider =
    AsyncNotifierProvider<HolidayRepository, List<Holiday>>(
      HolidayRepository.new,
    );

final selectedLocationProvider = StateProvider<String>((ref) => 'Mumbai');
