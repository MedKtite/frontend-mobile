import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/reading_mini_state.dart';

/// Whether the "continue reading" mini bar shows, and for which book.
/// Written by the reader screen (set on leave, cleared on enter); the bar
/// itself clears it on swipe-dismiss. Null = no bar.
final readingMiniProvider =
    StateProvider<ReadingMiniSession?>((ref) => null);
