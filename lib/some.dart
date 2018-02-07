import 'package:usage_stats/usage_stats_data.dart';


class Some
{
  static DateTime now() {
    UsageStatsData data = new UsageStatsData("tt", "vv", 1);
    return new DateTime.now();
  }
}