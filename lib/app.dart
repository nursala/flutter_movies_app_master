// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled23/pages/home/bloc/home_bloc.dart';
import 'pages/home/home_page.dart';
import 'services/tmdb_service.dart'; // تأكد من استيراد الخدمة

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. توفير الخدمة - صحيح
    return RepositoryProvider(
      create: (context) => TmdbService(defaultLanguage: 'ar'),
      child: MaterialApp(
        title: 'movies App',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.orange,
          appBarTheme: const AppBarTheme(elevation: 0),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.orange,
          appBarTheme: const AppBarTheme(elevation: 0),
        ),
        home: BlocProvider(
            create: (context) => HomeBloc(
              context.read<TmdbService>(),
            ),
            child:  MovieHomePage()
        ),
      ),
    );
  }
}