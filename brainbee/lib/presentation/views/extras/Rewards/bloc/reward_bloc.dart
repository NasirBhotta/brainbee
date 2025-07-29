import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'reward_event.dart';
part 'reward_state.dart';

class RewardBloc extends Bloc<RewardEvent, RewardState> {
  RewardBloc() : super(RewardInitial()) {
    on<RewardEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
