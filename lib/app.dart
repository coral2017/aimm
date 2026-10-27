import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/control/presentation/control_page.dart';
import 'features/control/providers/mask_controller.dart';
import 'features/profile/presentation/profile_page.dart';

class SmartMaskApp extends StatelessWidget {
  const SmartMaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MaskController(),
      child: Consumer<MaskController>(
        builder: (context, controller, child) {
          return MaterialApp(
            title: 'AI-Smart Mask',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.activeTheme,
            locale: controller.currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainNavigationShell(),
          );
        },
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ControlPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBackground,
          border: Border(
            top: BorderSide(color: AppColors.navBorder, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tab 1: Control (遥控)
                _buildNavItem(
                  index: 0,
                  icon: Icons.tune_rounded,
                  label: context.tr('control'),
                ),

                // Tab 2: Profile (我的 - 1:1 Figma 0:155 矢量重绘)
                _buildNavItem(
                  index: 1,
                  customIcon: FigmaProfileIcon(
                    color: _currentIndex == 1 ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                  label: context.tr('profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    IconData? icon,
    Widget? customIcon,
    required String label,
  }) {
    final bool isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customIcon ??
                Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部导航 Profile 图标 - 1:1 提取自 Figma 设计稿 (节点 0:155)
class FigmaProfileIcon extends StatelessWidget {
  final Color color;
  final double size;

  const FigmaProfileIcon({
    super.key,
    required this.color,
    this.size = 24.0,
  });

  static final Path _path = _buildProfilePath();

  static Path _buildProfilePath() {
    final path = Path()..fillType = PathFillType.evenOdd;
    const d =
        "M15.0582 1.76861C14.9342 1.75621 14.8096 1.75 14.685 1.75H10.315"
        "C8.24389 1.75 6.56496 3.42893 6.56496 5.5C6.56496 5.62461 6.57117"
        " 5.74915 6.58357 5.87314L7.25372 12.5746L8.74628 12.4254L8.07613"
        " 5.72388C8.06869 5.64949 8.06496 5.57477 8.06496 5.5C8.06496"
        " 4.25736 9.07232 3.25 10.315 3.25H14.685C14.7598 3.25 14.8345"
        " 3.25373 14.9089 3.26117C16.1454 3.38481 17.0475 4.48741 16.9239"
        " 5.72388L16.4603 10.36C16.3671 11.292 15.7062 12.0688 14.8012"
        " 12.3101L3.16727 15.4125C2.01991 15.7185 1.30783 16.8634 1.54071"
        " 18.0278L2.0234 20.4413C2.23374 21.493 3.15717 22.25 4.22971"
        " 22.25H19.7703C20.8428 22.25 21.7663 21.493 21.9766 20.4413L22.4641"
        " 18.0035C22.694 16.8542 22.003 15.7208 20.876 15.3988L16.2209"
        " 14.0688L15.8088 15.5111L20.4639 16.8411C20.8396 16.9485 21.0699"
        " 17.3262 20.9933 17.7094L20.5057 20.1471C20.4356 20.4977 20.1278"
        " 20.75 19.7703 20.75H4.22971C3.8722 20.75 3.56438 20.4977 3.49427"
        " 20.1471L3.01158 17.7336C2.93395 17.3455 3.17131 16.9639 3.55377"
        " 16.8619L15.1877 13.7595C16.6961 13.3573 17.7975 12.0626 17.9528"
        " 10.5093L18.4164 5.87314C18.6225 3.81235 17.119 1.97469 15.0582"
        " 1.76861ZM14.8266 7.91302L14.2211 5.79396L12.7789 6.20604L13.3843"
        " 8.3251C13.4946 8.71119 13.2813 9.11567 12.9003 9.24265L12.7628"
        " 9.28849L13.2372 10.7115L13.3747 10.6657C14.5175 10.2847 15.1575"
        " 9.0713 14.8266 7.91302Z";
    _parseSvgPath(d, path);
    return path;
  }

  static void _parseSvgPath(String d, Path path) {
    final regex = RegExp(r'([a-zA-Z])|([+-]?(?:\d*\.\d+|\d+)(?:[eE][+-]?\d+)?)');
    final matches = regex.allMatches(d);
    String currentCmd = '';
    final args = <double>[];
    double currentX = 0;
    double currentY = 0;

    for (final m in matches) {
      final token = m.group(0)!;
      final isCmd = RegExp(r'^[a-zA-Z]$').hasMatch(token);

      if (isCmd) {
        currentCmd = token;
        if (currentCmd == 'Z' || currentCmd == 'z') {
          path.close();
        }
        args.clear();
      } else {
        args.add(double.parse(token));
        if (currentCmd == 'M' && args.length == 2) {
          path.moveTo(args[0], args[1]);
          currentX = args[0];
          currentY = args[1];
          currentCmd = 'L';
          args.clear();
        } else if (currentCmd == 'L' && args.length == 2) {
          path.lineTo(args[0], args[1]);
          currentX = args[0];
          currentY = args[1];
          args.clear();
        } else if (currentCmd == 'H' && args.length == 1) {
          path.lineTo(args[0], currentY);
          currentX = args[0];
          args.clear();
        } else if (currentCmd == 'V' && args.length == 1) {
          path.lineTo(currentX, args[0]);
          currentY = args[0];
          args.clear();
        } else if (currentCmd == 'C' && args.length == 6) {
          path.cubicTo(args[0], args[1], args[2], args[3], args[4], args[5]);
          currentX = args[4];
          currentY = args[5];
          args.clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FigmaProfilePainter(path: _path, color: color),
    );
  }
}

class _FigmaProfilePainter extends CustomPainter {
  final Path path;
  final Color color;

  _FigmaProfilePainter({required this.path, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.scale(size.width / 24.0, size.height / 24.0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FigmaProfilePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
