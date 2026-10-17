import 'package:meta/meta.dart';

/// Generic paginated response wrapper matching the backend's `Page[T]`.
///
/// All list endpoints (`/users`, `/devices`, `/notifications`) return
/// this shape under `data`.
@immutable
final class Page<T> {
  const Page({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasNext,
    required this.hasPrev,
  });

  final List<T> items;
  final int total;
  final int limit;
  final int offset;
  final bool hasNext;
  final bool hasPrev;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  /// 1-based index of the first item in the current page (0 when empty).
  int get firstIndex => isEmpty ? 0 : offset + 1;

  /// 1-based index of the last item in the current page (0 when empty).
  int get lastIndex => isEmpty ? 0 : offset + items.length;

  /// Transforms items while preserving pagination metadata.
  Page<R> map<R>(R Function(T item) transform) => Page<R>(
    items: items.map(transform).toList(growable: false),
    total: total,
    limit: limit,
    offset: offset,
    hasNext: hasNext,
    hasPrev: hasPrev,
  );

  /// Appends [next]'s items to this page (for "load more" flows).
  Page<T> append(Page<T> next) => Page<T>(
    items: [...items, ...next.items],
    total: next.total,
    limit: next.limit,
    offset: offset,
    hasNext: next.hasNext,
    hasPrev: hasPrev,
  );
}
