enum SyncStatus { idle, syncing, error, offline }

class SyncResult {
  const SyncResult({
    required this.success,
    this.pushed = 0,
    this.pulled = 0,
    this.conflicts = 0,
    this.error,
  });

  final bool success;
  final int pushed;
  final int pulled;
  final int conflicts;
  final String? error;

  static const offline = SyncResult(success: false, error: 'offline');
}
