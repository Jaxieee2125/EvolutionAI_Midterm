import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_state.dart';

// Chuyển đổi AuthBloc → ChangeNotifier để GoRouter có thể listen
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription _sub;
  final AuthBloc bloc;

  AuthNotifier(this.bloc) {
    _sub = bloc.stream.listen((state) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => bloc.state.isAuthenticated;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
