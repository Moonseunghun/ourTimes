import 'package:flutter/material.dart';
import 'package:fluttertil/screens/login_auth.dart';
import 'package:fluttertil/screens/syncfusionTotal.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertil/screens/syncfusion_flutter_charts.dart';
import 'package:fluttertil/screens/syncfusion_flutter_calendar.dart';


final List<GoRoute> appRoutes = [
  GoRoute(
    builder: (context, state) => LogIn(),
    name: 'Login',
    path: '/lib/screens/login_auth.dart',
  ),
  GoRoute(
    builder: (context, state) => MyAppHome(),
    name: 'Page 1',
    path: '/lib/screens/syncfusion_flutter_charts.dart',
  ),
  GoRoute(
    builder: (context, state) => CalendarApp(),
    name: 'Page 2',
    path: '/lib/screens/syncfusion_flutter_calendar.dart',
  ),
  GoRoute(
    builder: (context, state) => CombinedApp(),
    name: 'Page 3',
    path: '/lib/screens/syncfusionTotal.dart',
  ),
];
