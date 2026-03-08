/// An entry in the recent-files list, combining the document path and the
/// timestamp of when it was last opened.
class RecentEntry {
  const RecentEntry({required this.path, required this.openedAt});

  final String path;
  final DateTime openedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentEntry && other.path == path);

  @override
  int get hashCode => path.hashCode;
}
