import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/services/media_service.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

part 'post_event.dart';
part 'post_state.dart';
part 'handler/new_post_event_handler.dart';
part 'handler/edit_post_event_handler.dart';
part 'handler/delete_post_event_handler.dart';
part 'handler/update_post_event_handler.dart';
part 'handler/toggle_pin_post_event_handler.dart';


class LMPostBloc extends Bloc<LMPostEvents, LMPostState> {
  LMPostBloc() : super(LMPostInitiate()) {
    on<CreateNewPost>(newPostEventHandler);
    on<EditPost>(editPostEventHandler);
    on<DeletePost>(deletePostEventHandler);
    on<UpdatePost>(updatePostEventHandler);
    on<TogglePinPost>(togglePinPostEventHandler);
  }
}
