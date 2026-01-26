import 'package:dsv360/models/holiday.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HolidayRepository extends AsyncNotifier<List<Holiday>> {
  @override
  Future<List<Holiday>> build() async {
    return _getMockHolidays();
  }

  Future<List<Holiday>> _getMockHolidays() async {
    final List<Holiday> allHolidays = [];
    final Map<String, List<Map<String, String>>> regionalHolidays = {
      'Mumbai': [
        {'date': '2026-01-26', 'name': 'Republic Day', 'month': 'January 2026'},
        {'date': '2026-03-04', 'name': 'Holi', 'month': 'March 2026'},
        {'date': '2026-03-19', 'name': 'Gudi Padwa', 'month': 'March 2026'},
        {'date': '2026-04-03', 'name': 'Good Friday', 'month': 'April 2026'},
        {
          'date': '2026-05-01',
          'name': 'Maharashtra Day / Labour Day',
          'month': 'May 2026',
        },
        {
          'date': '2026-08-28',
          'name': 'Raksha Bandhan',
          'month': 'August 2026',
        },
        {
          'date': '2026-09-14',
          'name': 'Ganesh Chaturthi',
          'month': 'September 2026',
        },
        {
          'date': '2026-10-02',
          'name': 'Gandhi Jayanti',
          'month': 'October 2026',
        },
        {'date': '2026-10-20', 'name': 'Dussehra', 'month': 'October 2026'},
        {'date': '2026-11-09', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-11-10', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-12-25', 'name': 'Christmas', 'month': 'December 2026'},
        {'date': '2027-01-01', 'name': 'New Year', 'month': 'January 2027'},
      ],
      'Pune': [
        {'date': '2026-01-26', 'name': 'Republic Day', 'month': 'January 2026'},
        {'date': '2026-03-04', 'name': 'Holi', 'month': 'March 2026'},
        {'date': '2026-03-19', 'name': 'Gudi Padwa', 'month': 'March 2026'},
        {'date': '2026-04-03', 'name': 'Good Friday', 'month': 'April 2026'},
        {
          'date': '2026-05-01',
          'name': 'Maharashtra Day / Labour Day',
          'month': 'May 2026',
        },
        {
          'date': '2026-08-28',
          'name': 'Raksha Bandhan',
          'month': 'August 2026',
        },
        {
          'date': '2026-09-14',
          'name': 'Ganesh Chaturthi',
          'month': 'September 2026',
        },
        {
          'date': '2026-10-02',
          'name': 'Gandhi Jayanti',
          'month': 'October 2026',
        },
        {'date': '2026-10-20', 'name': 'Dussehra', 'month': 'October 2026'},
        {'date': '2026-11-09', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-11-10', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-12-25', 'name': 'Christmas', 'month': 'December 2026'},
        {'date': '2027-01-01', 'name': 'New Year', 'month': 'January 2027'},
      ],
      'Vapi': [
        {
          'date': '2026-01-14',
          'name': 'Makar Sankranti / Kite Day',
          'month': 'January 2026',
        },
        {'date': '2026-01-26', 'name': 'Republic Day', 'month': 'January 2026'},
        {'date': '2026-03-04', 'name': 'Holi', 'month': 'March 2026'},
        {'date': '2026-04-03', 'name': 'Good Friday', 'month': 'April 2026'},
        {
          'date': '2026-05-01',
          'name': 'Gujarat Day / Labour Day',
          'month': 'May 2026',
        },
        {
          'date': '2026-08-28',
          'name': 'Raksha Bandhan',
          'month': 'August 2026',
        },
        {
          'date': '2026-09-14',
          'name': 'Ganesh Chaturthi',
          'month': 'September 2026',
        },
        {
          'date': '2026-10-02',
          'name': 'Gandhi Jayanti',
          'month': 'October 2026',
        },
        {'date': '2026-10-20', 'name': 'Dussehra', 'month': 'October 2026'},
        {'date': '2026-11-09', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-11-10', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-12-25', 'name': 'Christmas', 'month': 'December 2026'},
        {'date': '2027-01-01', 'name': 'New Year', 'month': 'January 2027'},
      ],
      'Ambasamudram': [
        {
          'date': '2026-01-15',
          'name': 'Mattu Pongal/Thiruvalluvar Day',
          'month': 'January 2026',
        },
        {
          'date': '2026-01-16',
          'name': 'Kanuma Panduga/Pongal',
          'month': 'January 2026',
        },
        {'date': '2026-01-26', 'name': 'Republic Day', 'month': 'January 2026'},
        {'date': '2026-04-03', 'name': 'Good Friday', 'month': 'April 2026'},
        {'date': '2026-04-14', 'name': 'Tamil New Year', 'month': 'April 2026'},
        {'date': '2026-05-01', 'name': 'Labour Day', 'month': 'May 2026'},
        {
          'date': '2026-08-28',
          'name': 'Vinayagar Chathurthi',
          'month': 'August 2026',
        },
        {
          'date': '2026-10-02',
          'name': 'Gandhi Jayanti',
          'month': 'October 2026',
        },
        {'date': '2026-10-19', 'name': 'Ayudha Pooja', 'month': 'October 2026'},
        {'date': '2026-10-20', 'name': 'Dussehra', 'month': 'October 2026'},
        {'date': '2026-11-09', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-12-25', 'name': 'Christmas', 'month': 'December 2026'},
        {'date': '2027-01-01', 'name': 'New Year', 'month': 'January 2027'},
      ],
      'Australia': [
        {
          'date': '2026-01-26',
          'name': 'Australia Day',
          'month': 'January 2026',
        },
        {
          'date': '2026-03-09',
          'name': 'Labour Day',
          'month': 'March 2026',
        },
        {'date': '2026-04-03', 'name': 'Good Friday', 'month': 'April 2026'},
        {'date': '2026-04-06', 'name': 'Easter Monday', 'month': 'April 2026'},
        {'date': '2026-05-01', 'name': 'Labour Day', 'month': 'May 2026'},
        {'date': '2026-06-08', 'name': 'Kings’s Birthday', 'month': 'June 2026'},
        {'date': '2026-10-20', 'name': 'Dussehra', 'month': 'October 2026'},
        {'date': '2026-11-03', 'name': 'Melbourne Cup Day', 'month': 'November 2026'},
        {'date': '2026-11-09', 'name': 'Diwali', 'month': 'November 2026'},
        {'date': '2026-12-25', 'name': 'Christmas', 'month': 'December 2026'},
        {'date': '2026-12-28', 'name': 'Boxing Day', 'month': 'December 2026'},
        {'date': '2027-01-01', 'name': 'New Year', 'month': 'January 2027'},
      ],
    };

    regionalHolidays.forEach((loc, holidays) {
      for (var h in holidays) {
        allHolidays.add(
          Holiday(
            date: h['date']!,
            name: h['name']!,
            location: loc,
            month: h['month']!,
          ),
        );
      }
    });

    return allHolidays;
  }
}

final holidayRepositoryProvider =
    AsyncNotifierProvider<HolidayRepository, List<Holiday>>(
      HolidayRepository.new,
    );

final selectedLocationProvider = StateProvider<String>((ref) => 'Mumbai');
