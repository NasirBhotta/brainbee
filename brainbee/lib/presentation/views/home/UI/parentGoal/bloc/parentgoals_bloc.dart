import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/home/UI/parentGoal/models/parent_model.dart';
import 'package:brainbee/presentation/views/home/UI/parentGoal/services/parent_goal_service.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'parentgoals_event.dart';
part 'parentgoals_state.dart';

class ParentGoalsBloc extends Bloc<ParentGoalsEvent, ParentGoalsState> {
  final ParentGoalsApiService _apiService = ParentGoalsApiService();

  ParentGoalsBloc() : super(ParentGoalsInitial()) {
    on<FetchParentGoals>(_onFetchParentGoals);
    on<MarkParentGoalComplete>(_onMarkParentGoalComplete);
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  FutureOr<void> _onFetchParentGoals(
    FetchParentGoals event,
    Emitter<ParentGoalsState> emit,
  ) async {
    emit(ParentGoalsLoading());

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        emit(ParentGoalsError("Authentication token not found"));
        return;
      }

      final response = await _apiService.getStudentGoals(token);

      if (response.statusCode != 200) {
        emit(ParentGoalsError('Failed to fetch goals: ${response.body}'));
        return;
      }

      final responseData = jsonDecode(response.body);
      final goalsResponse = ParentGoalsResponse.fromJson(responseData);

      emit(ParentGoalsLoaded(goalsResponse.goals));
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        emit(
          ParentGoalsError(
            "Cannot connect to server. Please check your connection.",
          ),
        );
      } else if (e.toString().contains('TimeoutException')) {
        emit(
          ParentGoalsError(
            "Request timed out. Please check your internet connection.",
          ),
        );
      } else {
        emit(ParentGoalsError(e.toString()));
      }
    }
    return null;
  }

  FutureOr<void> _onMarkParentGoalComplete(
    MarkParentGoalComplete event,
    Emitter<ParentGoalsState> emit,
  ) async {
    emit(ParentGoalMarkingComplete());

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        emit(ParentGoalMarkCompleteError("Authentication token not found"));
        return;
      }

      final response = await _apiService.markGoalComplete(event.goalId, token);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        emit(
          ParentGoalMarkedComplete(
            responseData['message'] ?? 'Goal completed successfully',
          ),
        );
        // Refresh the goals list
        add(FetchParentGoals());
      } else if (response.statusCode == 400 &&
          responseData['message']?.contains('already been completed') == true) {
        emit(
          ParentGoalMarkCompleteError("This goal has already been completed"),
        );
        // Still refresh to show updated state
        add(FetchParentGoals());
      } else {
        emit(
          ParentGoalMarkCompleteError(
            responseData['message'] ?? 'Failed to mark goal as complete',
          ),
        );
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        emit(
          ParentGoalMarkCompleteError(
            "Cannot connect to server. Please check your connection.",
          ),
        );
      } else if (e.toString().contains('TimeoutException')) {
        emit(
          ParentGoalMarkCompleteError(
            "Request timed out. Please check your internet connection.",
          ),
        );
      } else {
        emit(ParentGoalMarkCompleteError(e.toString()));
      }
    }
    return null;
  }
}
