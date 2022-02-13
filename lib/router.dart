import 'package:flutter/material.dart';
import 'package:gringe/ui/home_screen.dart';

class AppLink {
  const AppLink();
}

class AppRouteInformationParser extends RouteInformationParser<AppLink> {
  @override
  Future<AppLink> parseRouteInformation(RouteInformation routeInformation) async {
    return const AppLink();
  }
}

class AppRouterDelegate extends RouterDelegate<AppLink> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  AppLink appLink = const AppLink();

  @override
  Future<void> setNewRoutePath(AppLink configuration) async {
    appLink = configuration;
    notifyListeners();
  }

  bool update<T extends AppLink>(T Function(T appLink) update) {
    final appLink = this.appLink;
    if (appLink is T) {
      this.appLink = update(appLink);
      notifyListeners();
    } else {
      assert(false);
      return false;
    }
    return true;
  }

  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    List<Page> pages = [];
    print('evaluating');
    if (appLink is AppLink) {
      pages.add(
        MaterialPage(
          key: ValueKey('home-screen'),
          child: HomeScreen(),
        ),
      );
    }
    if (pages.isEmpty) {
      appLink = const AppLink();
      pages.add(MaterialPage(key: ValueKey('home-screen'), child: HomeScreen()));
    }
    return Navigator(
        pages: pages,
        key: navigatorKey,
        onPopPage: (route, result) {
          return route.didPop(result);
        });
  }
}
