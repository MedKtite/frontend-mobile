import 'package:flutter_test/flutter_test.dart';
import 'package:marginalia/services/frontend/isbn_lookup_service.dart';

void main() {
  group('IsbnLookupService', () {
    test('cleanIsbn strips hyphens, spaces, and formatting', () {
      expect(IsbnLookupService.cleanIsbn('978-0-14-312774-1'), '9780143127741');
      expect(IsbnLookupService.cleanIsbn(' 0-19-852663-6 '), '0198526636');
      expect(IsbnLookupService.cleanIsbn('ISBN 978-1-933517-41-4'), '9781933517414');
      expect(IsbnLookupService.cleanIsbn('0-8044-2957-X'), '080442957X');
    });
  });
}
