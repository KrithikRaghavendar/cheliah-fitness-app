class MonthData {
  final String name;
  final String fullName;
  final int pct;

  const MonthData({
    required this.name,
    required this.fullName,
    required this.pct,
  });
}

class FitnessData {
  static List<MonthData> get monthData {
    final currentMonth = DateTime.now().month - 1; // 0-based
    const baseData = [
      MonthData(name: 'Jan', fullName: 'January', pct: 75),
      MonthData(name: 'Feb', fullName: 'February', pct: 40),
      MonthData(name: 'Mar', fullName: 'March', pct: 90),
      MonthData(name: 'Apr', fullName: 'April', pct: 60),
      MonthData(name: 'May', fullName: 'May', pct: 30),
      MonthData(name: 'Jun', fullName: 'June', pct: 50),
      MonthData(name: 'Jul', fullName: 'July', pct: 85),
      MonthData(name: 'Aug', fullName: 'August', pct: 20),
      MonthData(name: 'Sep', fullName: 'September', pct: 55),
      MonthData(name: 'Oct', fullName: 'October', pct: 70),
      MonthData(name: 'Nov', fullName: 'November', pct: 45),
      MonthData(name: 'Dec', fullName: 'December', pct: 10),
    ];
    return baseData.asMap().entries.map((entry) {
      if (entry.key > currentMonth) {
        return MonthData(
          name: entry.value.name,
          fullName: entry.value.fullName,
          pct: 0,
        );
      }
      return entry.value;
    }).toList();
  }

  static const Map<int, List<int>> weeklyData = {
    0: [5, 3, 6, 7], // Jan
    1: [2, 4, 3, 2], // Feb
    2: [3, 5, 6, 2], // Mar — current month (based on original JS, we use exact logic)
    3: [4, 5, 3, 5], // Apr
    4: [1, 3, 2, 3], // May
    5: [4, 3, 4, 3], // Jun
    6: [6, 7, 5, 6], // Jul
    7: [2, 1, 2, 1], // Aug
    8: [4, 3, 5, 3], // Sep
    9: [5, 6, 4, 5], // Oct
    10: [3, 4, 2, 4], // Nov
    11: [1, 0, 1, 1], // Dec
  };
}
