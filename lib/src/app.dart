part of '../main.dart';

class StillpointApp extends StatelessWidget {
  const StillpointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stillpoint',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: SpaColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SpaColors.deepSage,
          brightness: Brightness.light,
          primary: SpaColors.deepSage,
          secondary: SpaColors.taupe,
          tertiary: SpaColors.paleSage,
          surface: SpaColors.surface,
          error: SpaColors.error,
        ),
        fontFamily: 'Avenir',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w900),
          titleMedium: TextStyle(fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(height: 1.35),
        ),
      ),
      home: const StillpointHome(),
    );
  }
}
