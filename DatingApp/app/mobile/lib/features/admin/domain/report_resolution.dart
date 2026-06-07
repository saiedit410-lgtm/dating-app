/// What an admin chooses to do with an open report.
enum ReportResolution {
  warn,
  suspend,
  ban,
  dismiss;

  static ReportResolution? fromName(String? name) {
    for (final ReportResolution r in ReportResolution.values) {
      if (r.name == name) return r;
    }
    return null;
  }

  /// User-facing copy used in the report-detail screen.
  String get label {
    switch (this) {
      case ReportResolution.warn:
        return 'Warn';
      case ReportResolution.suspend:
        return 'Suspend';
      case ReportResolution.ban:
        return 'Ban';
      case ReportResolution.dismiss:
        return 'Dismiss';
    }
  }
}
