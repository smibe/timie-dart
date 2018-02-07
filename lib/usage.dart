import 'dart:async';

import 'package:usage_stats/usage_stats_data.dart';
import 'package:usage_stats/usage_stats.dart';

class Usage {
  IUsageStats usageStats;
  Usage(IUsageStats usageStats) {
    this.usageStats = usageStats;
  }

  static DateTime getStartOfDay(num dayOffset) {
    var now = new DateTime.now();
    var start = new DateTime(now.year, now.month, now.day, 0, 0, 1);
    if (dayOffset != 0) start = start.add(new Duration(days: dayOffset));

    return start;
  }

  Future<List<UsageStatsData>> getUsageStats(int dayOffset) async {
    var start = getStartOfDay(dayOffset);

    var end = new DateTime(start.year, start.month, start.day, 23, 59, 58);

    var now = new DateTime.now();
    if (end.millisecondsSinceEpoch > now.millisecondsSinceEpoch) end = now;

    var result = await this.usageStats.buildUsageStats(
        start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);

    return result;
  }

  static int calcDuration(List<UsageStatsData> list) {
    num duration = 0;
    for (var s in list) {
      if (s.duration > 1000 && !s.packageName.endsWith("launcher")) {
        duration += s.duration;
      }
    }
    return duration;
  }
}
