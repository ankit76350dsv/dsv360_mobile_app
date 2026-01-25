class Holiday {
  final String date;
  final String name;
  final String location;
  final String month;

  Holiday({
    required this.date,
    required this.name,
    required this.location,
    required this.month,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: json['Date']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      location: json['Location']?.toString() ?? '',
      month: json['Month']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'Date': date, 'Name': name, 'Location': location, 'Month': month};
  }

  int get day => DateTime.tryParse(date)?.day ?? 0;
}
