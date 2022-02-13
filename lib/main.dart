import 'package:flutter/material.dart';
import 'package:gringe/data/models/gamehub_model.dart';
import 'package:gringe/router.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const GringeApp());
}

class GringeApp extends StatefulWidget {
  const GringeApp({Key? key}) : super(key: key);

  @override
  State<GringeApp> createState() => _GringeAppState();
}

class _GringeAppState extends State<GringeApp> {
  AppRouterDelegate routerDelegate = AppRouterDelegate();
  AppRouteInformationParser routeInformationParser = AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>.value(value: routerDelegate),
        ChangeNotifierProvider<GamehubModel>(
          create: (ctx) => GamehubModel(),
        ),
      ],
      child: MaterialApp.router(
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
      ),
    );
  }
}
