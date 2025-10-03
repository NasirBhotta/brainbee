import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/extras/scorecard/model/bb_book_score.model.dart';
import 'package:brainbee/presentation/views/extras/scorecard/model/bb_spefic_book_score_model.dart';
import 'package:brainbee/presentation/views/extras/scorecard/repo/score_repo.dart';
import 'package:equatable/equatable.dart';

part 'book_score_event.dart';
part 'book_score_state.dart';

class BookScoreBloc extends Bloc<BookScoreEvent, BookScoreState> {
  final ScoreRepository repository;
  BookScoreBloc({required this.repository}) : super(BookScoreInitial()) {
    on<LoadOverallScore>(_onLoadOverallScore);
    on<RefreshOverallScore>(_onRefreshOverallScore);
    on<LoadBookScore>(_onLoadBookScore);
    on<RefreshBookScore>(_onRefreshBookScore);
  }

  Future<void> _onLoadOverallScore(
    LoadOverallScore event,
    Emitter<BookScoreState> emit,
  ) async {
    emit(OverallScoreLoading());
    try {
      final data = await repository.getOverallScore();

      // Check if no scores available
      if (data.subjectScores.isEmpty) {
        emit(OverallScoreEmpty());
      } else {
        emit(OverallScoreLoaded(data));
      }
    } catch (e) {
      emit(OverallScoreError(e.toString()));
    }
  }

  Future<void> _onRefreshOverallScore(
    RefreshOverallScore event,
    Emitter<BookScoreState> emit,
  ) async {
    // Don't show loading state during refresh
    try {
      final data = await repository.getOverallScore();

      if (data.subjectScores.isEmpty) {
        emit(OverallScoreEmpty());
      } else {
        emit(OverallScoreLoaded(data));
      }
    } catch (e) {
      emit(OverallScoreError(e.toString()));
    }
  }

  Future<void> _onLoadBookScore(
    LoadBookScore event,
    Emitter<BookScoreState> emit,
  ) async {
    emit(BookScoreLoading());
    try {
      final data = await repository.getBookScore(event.bookId);
      emit(BookScoreLoaded(data));
    } catch (e) {
      emit(BookScoreError(e.toString()));
    }
  }

  Future<void> _onRefreshBookScore(
    RefreshBookScore event,
    Emitter<BookScoreState> emit,
  ) async {
    try {
      final data = await repository.getBookScore(event.bookId);
      emit(BookScoreLoaded(data));
    } catch (e) {
      emit(BookScoreError(e.toString()));
    }
  }
}
