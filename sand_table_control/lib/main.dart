import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'providers/sand_table_provider.dart';
import 'services/tcp_service.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TcpService()),
        ChangeNotifierProxyProvider<TcpService, SandTableProvider>(
          create: (context) => SandTableProvider(
            Provider.of<TcpService>(context, listen: false),
          ),
          update: (context, tcpService, previous) =>
              previous ?? SandTableProvider(tcpService),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // 常见设计稿尺寸，自适应分辨率
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: '沙盘控制',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: child,
          );
        },
        child: const HomePage(),
      ),
    );
  }
}
