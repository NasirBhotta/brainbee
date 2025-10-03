import 'package:bloc/bloc.dart';
import 'package:brainbee/presentation/views/extras/scorecard/model/bb_book_score.model.dart';
import 'package:equatable/equatable.dart';

part 'book_score_event.dart';
part 'book_score_state.dart';

class BookScoreBloc extends Bloc<BookScoreEvent, BookScoreState> {
  BookScoreBloc() : super(BookScoreInitial()) {
    on<BookScoreEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
