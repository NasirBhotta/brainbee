import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bot_event.dart';
part 'bot_state.dart';

class BotBloc extends Bloc<BotEvent, BotState> {
  BotBloc() : super(BotInitial()) {
    on<BotEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
