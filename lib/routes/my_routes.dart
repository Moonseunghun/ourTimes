import 'package:flutter/material.dart';
import 'package:fluttertil/screens/login_auth.dart';
import 'package:fluttertil/screens/syncfusionTotal.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertil/screens/syncfusion_flutter_charts.dart';
import 'package:fluttertil/screens/syncfusion_flutter_calendar.dart';


final appRoutes = GoRouter(initialLocation: '/splash', routes: [
  GoRoute(
    builder: (context, state) => LogIn(),
    name: 'Login',
    path: '/Login',
  ),
  GoRoute(
    builder: (context, state) => MyAppHome(),
    name: 'Page 1',
    path: '/',
  ),
  GoRoute(
    builder: (context, state) => CalendarApp(),
    name: 'Page 2',
    path: '/calendar',
  ),
  GoRoute(
    builder: (context, state) => MyHomePage(),
    name: 'Page 3',
    path: '/combined',
  ),
]);
