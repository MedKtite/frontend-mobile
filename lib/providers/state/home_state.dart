import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// Home tab state. The library is fetched from the backend:
///   • [loading] while the request is in flight,
///   • [empty] when the user has no books,
///   • [loaded] with whichever resume/resurface surfaces could be derived
///     (each section is nullable — a user may have books but no audiobook,
///     or no highlights yet),
///   • [error] on a failed fetch (retryable).
///
/// User identity (greeting/avatar) is NOT here — it comes from the
/// authenticated [User] via authProvider.
@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.loading() = HomeLoading;
  const factory HomeState.empty() = HomeEmpty;
  const factory HomeState.loaded({
    ContinueReading? continueReading,
    HomePassage? passage,
    ListeningItem? listening,
  }) = HomeLoaded;
  const factory HomeState.error(String message) = HomeError;
}

/// The "Continue reading" hero — the in-progress book to resume.
@freezed
class ContinueReading with _$ContinueReading {
  const factory ContinueReading({
    required String id, // book id — opens the reader on resume
    required String title,
    required String author,
    required Color coverBg,
    required Color coverFg,
    required double progress, // 0–100
  }) = _ContinueReading;
}

/// "Passage of the day" — one resurfaced highlight ([colorTag] drives the
/// marginal dot; the passage gets the gold underline).
@freezed
class HomePassage with _$HomePassage {
  const factory HomePassage({
    required String text,
    required String source,
    required String colorTag,
  }) = _HomePassage;
}

/// "Still listening to" — the in-progress audiobook.
@freezed
class ListeningItem with _$ListeningItem {
  const factory ListeningItem({
    required String title,
    required String author,
    required Color coverBg,
    required Color coverFg,
  }) = _ListeningItem;
}
