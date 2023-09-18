import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertil/routes/my_routes.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final goRouter = GoRouter(
      initialLocation: '/splash', // 초기 경로 설정
      navigatorKey: GlobalKey<NavigatorState>(),
      builder: (BuildContext context, GoRouterState state) {
        return MaterialApp.router(
          routerDelegate: state.routerDelegate,
          routeInformationParser: state.routeInformationParser,
        );
      },
    );

    return MaterialApp(
      title: 'BottomNavBar Example',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        body: SplashScreen(
          seconds: 2,
          navigateAfterSeconds: '/Login', // 시간이 지난 후 이동할 경로
          image: Image.asset('assets/main_logo.png'), // 이미지 파일 경로
          backgroundColor: Colors.white, // 배경색
          loaderColor: Colors.grey,
          photoSize: 100.0, // 이미지 크기
          loadingText: Text("Loading"), // 로딩 텍스트
        ),
      ),
      onGenerateRoute: goRouter.router.generator,
    );
  }
}
