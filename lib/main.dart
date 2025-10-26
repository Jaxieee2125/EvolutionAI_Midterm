import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'app_router.dart';

void main() {
  final repo = AuthRepository();
  final authBloc = AuthBloc(repo);
  final router = createRouter(authBloc);
  runApp(MyApp(authBloc: authBloc, router: router));
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final router;
  const MyApp({super.key, required this.authBloc, required this.router});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: authBloc)],
      child: MaterialApp.router(
        title: 'Evolution AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        routerConfig: router, // dùng router tạo động
      ),
    );
  }
}
