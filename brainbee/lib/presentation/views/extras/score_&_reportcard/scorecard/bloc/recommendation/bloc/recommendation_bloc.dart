import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/model/recommendation_model/recommendation_model.dart';
import 'package:brainbee/presentation/views/extras/score_&_reportcard/scorecard/services/recommendation_service/recommendation_service.dart';
import 'package:equatable/equatable.dart';

part 'recommendation_event.dart';
part 'recommendation_state.dart';

class RecommendationBloc
    extends Bloc<RecommendationEvent, RecommendationState> {
  final RecommendationService service;

  RecommendationBloc({required this.service}) : super(RecommendationInitial()) {
    on<LoadRecommendations>(_onLoadRecommendations);
    on<RefreshRecommendations>(_onRefreshRecommendations);
  }

  Future<void> _onLoadRecommendations(
    LoadRecommendations event,
    Emitter<RecommendationState> emit,
  ) async {
    emit(RecommendationLoading());

    try {
      final data = await service.getRecommendations(event.studentId);

      if (data.topics.isEmpty &&
          data.flashcards.isEmpty &&
          data.quizzes.isEmpty) {
        emit(RecommendationEmpty());
      } else {
        emit(RecommendationLoaded(data));
      }
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }

  Future<void> _onRefreshRecommendations(
    RefreshRecommendations event,
    Emitter<RecommendationState> emit,
  ) async {
    final currentState = state;

    try {
      final data = await service.getRecommendations(event.studentId);

      if (data.topics.isEmpty &&
          data.flashcards.isEmpty &&
          data.quizzes.isEmpty) {
        emit(RecommendationEmpty());
      } else {
        emit(RecommendationLoaded(data));
      }
    } catch (e) {
      // If refresh fails, maintain current state if it was loaded
      if (currentState is RecommendationLoaded) {
        emit(currentState);
      } else {
        emit(RecommendationError(e.toString()));
      }
    }
  }
}
