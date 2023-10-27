import 'package:likeminds_feed_ss_fl/src/blocs/new_post/new_post_bloc.dart';

class BlocService {
  late final NewPostBloc newPostBlocProvider;

  BlocService() {
    newPostBlocProvider = NewPostBloc();
  }
}
