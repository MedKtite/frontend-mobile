import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/book.dart';

part 'reading_mini_state.freezed.dart';

/// The "continue reading" mini bar's payload — set when the reader screen is
/// left mid-book, cleared when it's reopened or the bar is swiped away.
/// Session-only by design: durable resume already lives on Home.
@freezed
class ReadingMiniSession with _$ReadingMiniSession {
  const factory ReadingMiniSession({
    required Book book,
    required double pct, // 0–100
    required String label, // "Page 128 of 342"
  }) = _ReadingMiniSession;
}
