class LeaveSummary {
  final int remainingTotalLeaves;
  final int remainingPaidLeaves;
  final int remainingSickLeaves;
  final int usedPaidLeave;
  final int usedUnpaidLeave;
  final int usedSickLeave;
  final int totalSickLeave;
  final int totalPaidLeave;

  LeaveSummary({
    required this.remainingTotalLeaves,
    required this.remainingPaidLeaves,
    required this.remainingSickLeaves,
    required this.usedPaidLeave,
    required this.usedUnpaidLeave,
    required this.usedSickLeave,
    required this.totalSickLeave,
    required this.totalPaidLeave,
  });

  // Helper method to parse string to int
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory LeaveSummary.fromJson(Map<String, dynamic> json) => LeaveSummary(
        remainingTotalLeaves: _parseInt(json['Remaining_Total_Leaves']),
        remainingPaidLeaves: _parseInt(json['Remaining_Paid_Leaves']),
        remainingSickLeaves: _parseInt(json['Remaining_Sick_Leaves']),
        usedPaidLeave: _parseInt(json['Used_Paid_Leave']),
        usedUnpaidLeave: _parseInt(json['Used_Unpaid_Leave']),
        usedSickLeave: _parseInt(json['Used_Sick_Leave']),
        totalSickLeave: _parseInt(json['Total_Sick_Leave']),
        totalPaidLeave: _parseInt(json['Total_Paid_Leave']),
      );

  Map<String, dynamic> toJson() => {
        'Remaining_Total_Leaves': remainingTotalLeaves.toString(),
        'Remaining_Paid_Leaves': remainingPaidLeaves.toString(),
        'Remaining_Sick_Leaves': remainingSickLeaves.toString(),
        'Used_Paid_Leave': usedPaidLeave.toString(),
        'Used_Unpaid_Leave': usedUnpaidLeave.toString(),
        'Used_Sick_Leave': usedSickLeave.toString(),
        'Total_Sick_Leave': totalSickLeave.toString(),
        'Total_Paid_Leave': totalPaidLeave.toString(),
      };

  // Calculated properties for display
  int get totalLeaves => remainingTotalLeaves + usedPaidLeave + usedUnpaidLeave + usedSickLeave;

  // Helper methods to get data for LeaveSummaryCard
  // Remaining card
  String get remainingValue => remainingTotalLeaves.toString();
  String get remainingSubtitle => 'Out of $totalLeaves leaves';

  // Paid card
  String get paidValue => remainingPaidLeaves.toString();
  String get paidSubtitle => 'Out of $totalPaidLeave leaves';

  // Sick card
  String get sickValue => remainingSickLeaves.toString();
  String get sickSubtitle => 'Out of $totalSickLeave leaves';

  // Unpaid card
  String get unpaidValue => usedUnpaidLeave.toString();
  String get unpaidSubtitle => 'This month';
}

