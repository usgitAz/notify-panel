import 'package:flutter_test/flutter_test.dart';
import 'package:notify_panel/core/network/page.dart';

void main() {
  group('Page<T>', () {
    test('firstIndex/lastIndex for empty page', () {
      const page = Page<int>(
        items: [],
        total: 0,
        limit: 20,
        offset: 0,
        hasNext: false,
        hasPrev: false,
      );
      expect(page.isEmpty, isTrue);
      expect(page.firstIndex, 0);
      expect(page.lastIndex, 0);
    });

    test('firstIndex/lastIndex for populated page', () {
      const page = Page<int>(
        items: [1, 2, 3],
        total: 42,
        limit: 20,
        offset: 20,
        hasNext: true,
        hasPrev: true,
      );
      expect(page.isNotEmpty, isTrue);
      expect(page.firstIndex, 21);
      expect(page.lastIndex, 23);
    });

    test('map transforms items and preserves metadata', () {
      const page = Page<int>(
        items: [1, 2, 3],
        total: 42,
        limit: 20,
        offset: 20,
        hasNext: true,
        hasPrev: true,
      );

      final mapped = page.map((i) => 'item-$i');

      expect(mapped.items, ['item-1', 'item-2', 'item-3']);
      expect(mapped.total, 42);
      expect(mapped.limit, 20);
      expect(mapped.offset, 20);
      expect(mapped.hasNext, isTrue);
      expect(mapped.hasPrev, isTrue);
    });

    test('append concatenates items and adopts next page metadata', () {
      const first = Page<int>(
        items: [1, 2],
        total: 100,
        limit: 20,
        offset: 0,
        hasNext: true,
        hasPrev: false,
      );
      const second = Page<int>(
        items: [3, 4],
        total: 100,
        limit: 20,
        offset: 20,
        hasNext: true,
        hasPrev: true,
      );

      final combined = first.append(second);

      expect(combined.items, [1, 2, 3, 4]);
      expect(combined.total, 100);
      expect(combined.limit, 20);
      expect(combined.offset, 0); // keeps original offset
      expect(combined.hasNext, isTrue);
      expect(combined.hasPrev, isFalse); // keeps original hasPrev
    });
  });
}
