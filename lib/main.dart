import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'app_router.dart';

void main() {
  final repo = AuthRepository();
  runApp(MyApp(repo));
}

class MyApp extends StatelessWidget {
  final AuthRepository repo;
  const MyApp(this.repo, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => AuthBloc(repo))],
      child: MaterialApp.router(
        title: 'Evolution AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        routerConfig: appRouter,
      ),
    );
  }
}
