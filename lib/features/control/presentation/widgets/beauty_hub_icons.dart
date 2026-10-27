import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/mask_mode.dart';

class BeautyHubIcon extends StatelessWidget {
  final MaskModeType? mode;
  final int? modeId;
  final Color color;
  final double size;

  const BeautyHubIcon({
    super.key,
    this.mode,
    this.modeId,
    required this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMode = mode ??
        (modeId != null ? MaskModeType.fromId(modeId!) : MaskModeType.firming);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BeautyHubIconPainter(mode: effectiveMode, color: color),
      ),
    );
  }
}

class _BeautyHubIconPainter extends CustomPainter {
  final MaskModeType mode;
  final Color color;

  _BeautyHubIconPainter({required this.mode, required this.color});

  // Pre-compiled 1:1 exact vector path parsed directly from Figma (node 18:692)
  static final Path _revitalizingPath = _buildRevitalizingPath();
  // Pre-compiled 1:1 exact vector path parsed directly from Figma (node 0:71)
  static final Path _plumpingPath = _buildPlumpingPath();
  // Pre-compiled 1:1 exact vector path parsed directly from Figma (node 0:109)
  static final Path _liftingPath = _buildLiftingPath();

  static Path _buildRevitalizingPath() {
    final path = Path()..fillType = PathFillType.evenOdd;

    // 1. Eyes & mouth (subpixel curves)
    const dEyesAndMouth =
        "M17.7427 9.77857C17.4807 9.77857 17.2545 9.58231 17.2231 9.31579"
        "C17.1631 8.81945 16.8604 7.73218 16.3504 7.73216C15.8442 7.73216"
        " 15.5727 8.81106 15.5263 9.30347C15.499 9.59168 15.2471 9.80191"
        " 14.9553 9.77618C14.667 9.7492 14.4556 9.49347 14.4826 9.20543"
        "C14.5705 8.26889 15.0629 6.68395 16.3501 6.68395C17.629 6.68395"
        " 18.1549 8.26154 18.264 9.19342C18.2977 9.48086 18.092 9.74112"
        " 17.8043 9.77491C17.7836 9.77755 17.7631 9.77857 17.7427 9.77857ZM9.2369"
        " 7.73247C9.74689 7.73247 10.0496 8.82001 10.1096 9.31632C10.141"
        " 9.58255 10.3672 9.77857 10.6292 9.77857C10.6494 9.77857 10.6701"
        " 9.77755 10.6908 9.77518C10.9783 9.74139 11.184 9.48113 11.1505"
        " 9.19369C11.0414 8.26181 10.5155 6.68426 9.23692 6.68426C7.94948"
        " 6.68426 7.4571 8.26916 7.3693 9.20577C7.34202 9.49376 7.55375"
        " 9.74952 7.84203 9.77651C8.13002 9.8035 8.38549 9.59201 8.4128"
        " 9.30373C8.45913 8.81133 8.73094 7.73247 9.2369 7.73247ZM12.4307"
        " 16.7784C15.8727 16.7784 16.1586 14.2849 16.1615 14.2593C16.1896"
        " 13.9739 15.9827 13.722 15.6976 13.6903C15.4116 13.6599 15.1541"
        " 13.8645 15.119 14.1499C15.111 14.2143 14.8936 15.7299 12.4306"
        " 15.7299C9.978 15.7299 9.75239 14.2275 9.74269 14.151C9.7115"
        " 13.8655 9.45523 13.6573 9.1701 13.6863C8.88211 13.7149 8.67166"
        " 13.9712 8.69999 14.2594C8.70234 14.2843 8.98825 16.7784 12.4307 16.7784Z";

    // 2. Head perimeter arc
    const dHead =
        "M5.6345 15.6973C4.60381 14.316 3.99293 12.6058 3.99293 10.7557"
        "C3.99293 6.18105 7.72513 2.45934 12.313 2.45934C16.9008 2.45934"
        " 20.633 6.18103 20.633 10.7557C20.633 12.6058 20.0221 14.316"
        " 18.9915 15.6973C19.3806 15.7168 19.7483 15.8137 20.0803 15.9746"
        "C21.0906 14.4835 21.6809 12.6872 21.6809 10.7557C21.6809 5.60323"
        " 17.4784 1.41114 12.3127 1.41114C7.14711 1.41114 2.94474 5.603"
        " 2.94474 10.7555C2.94474 12.6869 3.53516 14.4833 4.5454 15.9744"
        "C4.87766 15.8137 5.2453 15.7165 5.6345 15.6973Z";

    // 3. Chin and the two hollow round hands
    const dChinAndHands =
        "M18.8498 15.6966C17.4083 15.6966 16.2158 16.7772 16.0413 18.169"
        "L16.0428 18.1682C16.0284 18.2841 16.0184 18.4015 16.0184 18.5215"
        "C16.0184 18.4021 16.0268 18.2846 16.0412 18.169C14.9189 18.7328"
        " 13.6529 19.0522 12.3127 19.0522C10.9726 19.0522 9.70666 18.7328"
        " 8.58435 18.169C8.59887 18.2846 8.6072 18.4021 8.6072 18.5215"
        "C8.6072 18.4017 8.59725 18.2844 8.5828 18.1682L8.58433 18.169"
        "C8.40978 16.7772 7.21726 15.6966 5.77593 15.6966C4.21487 15.6966"
        " 2.94466 16.9638 2.94466 18.5215C2.94466 20.0792 4.21485 21.3465"
        " 5.77593 21.3465C7.07065 21.3465 8.16457 20.4743 8.5004 19.2882"
        "L8.49946 19.2877C8.55034 19.107 8.58346 18.9217 8.59834 18.7345"
        "C8.58431 18.9219 8.55151 19.1073 8.50042 19.2881C9.66608 19.8084"
        " 10.9555 20.1001 12.3129 20.1001C13.6703 20.1001 14.9596 19.8084"
        " 16.1253 19.2882C16.4611 20.4744 17.555 21.3464 18.8498 21.3464"
        "C20.4109 21.3464 21.6811 20.0792 21.6811 18.5215C21.6811 16.9638"
        " 20.4109 15.6966 18.8498 15.6966ZM16.1253 19.2882L16.1264 19.2877"
        "C16.0762 19.1094 16.0421 18.9242 16.0273 18.7338C16.0412 18.9214"
        " 16.0741 19.1072 16.1253 19.2882ZM5.77597 20.2982C4.79272 20.2982"
        " 3.99293 19.5009 3.99293 18.5213C3.99293 17.5417 4.79272 16.7445"
        " 5.77597 16.7445C6.75922 16.7445 7.55899 17.542 7.55899 18.5215"
        "C7.55899 19.5011 6.75893 20.2982 5.77597 20.2982ZM17.0666 18.5213"
        "C17.0666 19.5009 17.8667 20.2982 18.8498 20.2982C19.8332 20.2982"
        " 20.633 19.5011 20.633 18.5215C20.633 17.542 19.8332 16.7445"
        " 18.8498 16.7445C17.8667 16.7445 17.0666 17.5417 17.0666 18.5213Z";

    _parseSvgPath(dEyesAndMouth, path);
    _parseSvgPath(dHead, path);
    _parseSvgPath(dChinAndHands, path);
    return path;
  }

  static Path _buildPlumpingPath() {
    final path = Path()..fillType = PathFillType.evenOdd;
    const dPlumping =
        "M11.3025 19.8815C11.5295 19.9052 11.7591 19.9173 11.9911 19.9173"
        "C12.223 19.9173 12.4527 19.9052 12.6796 19.8815V22.5162"
        "C12.6796 22.896 12.3714 23.2045 11.9911 23.2045V23.2045"
        "C11.6105 23.2045 11.3025 22.896 11.3025 22.5162V19.8815ZM11.3025"
        " 19.8815C7.25727 19.4586 4.07257 15.3456 4.07257 10.3509"
        "C4.07257 5.07659 7.62462 0.785602 11.9911 0.785602"
        "C16.3573 0.785602 19.9096 5.07659 19.9096 10.3509"
        "C19.9096 15.3456 16.7247 19.4586 12.6796 19.8815V19.4436"
        "C12.6796 19.0633 12.3714 18.7553 11.9911 18.7553"
        "C11.6105 18.7553 11.3025 19.0633 11.3025 19.4436V19.8815ZM9.02958"
        " 10.8394C8.89167 10.8395 8.75938 10.7848 8.66187 10.6873"
        "C8.45859 10.4837 8.45859 10.1549 8.66187 9.9513L11.7605 6.85266"
        "C11.9635 6.64964 12.2929 6.64964 12.4962 6.85266"
        "C12.6995 7.05619 12.6995 7.38509 12.4962 7.58862L9.39757 10.6873"
        "C9.29997 10.7848 9.16758 10.8396 9.02958 10.8394ZM10.2921 14.3971"
        "C10.1542 14.3972 10.0219 14.3425 9.92438 14.2449"
        "C9.72084 14.0414 9.72084 13.712 9.92438 13.5084L14.5847 8.84843"
        "C14.7877 8.64544 15.1173 8.64544 15.3203 8.84843"
        "C15.5236 9.05198 15.5236 9.38086 15.3203 9.58439L10.6598 14.2449"
        "C10.5623 14.3425 10.43 14.3972 10.2921 14.3971ZM11.9911 2.16267"
        "C8.38413 2.16267 5.44969 5.83603 5.44969 10.3509"
        "C5.44969 14.8663 8.38413 18.5402 11.9911 18.5402"
        "C15.5981 18.5402 18.5325 14.8663 18.5325 10.3509"
        "C18.5325 5.83603 15.5981 2.16267 11.9911 2.16267Z";
    _parseSvgPath(dPlumping, path);
    return path;
  }

  static Path _buildLiftingPath() {
    final path = Path()..fillType = PathFillType.evenOdd;
    const dLifting =
        "M12.4682 5.64061C11.1174 5.17053 9.7618 4.69881 8.37 4.39453"
        "C5.81621 3.83585 3.38243 4.42794 1.0772 5.55099"
        "C0.957343 5.60927 0.862685 5.71534 0.768077 5.82135"
        "C0.724226 5.87049 0.680385 5.91961 0.634051 5.96396V6.40465"
        "C1.04098 6.86524 1.4678 6.87164 2.02813 6.60154"
        "C4.01094 5.64552 6.11377 5.20128 8.29331 5.74148"
        "C9.6699 6.08202 11.0141 6.55495 12.3544 7.02649"
        "C12.5388 7.09135 12.723 7.15618 12.9073 7.22064"
        "C15.0627 7.97408 17.2607 8.34156 19.529 7.903"
        "C20.8911 7.63929 22.2398 7.28177 23.3597 6.40465V5.96325"
        "C23.2806 5.9062 23.2038 5.84395 23.127 5.78169"
        "C22.9597 5.64613 22.7925 5.51056 22.6012 5.42873"
        "C21.9895 5.16755 21.3634 4.93498 20.7383 4.70277"
        "C20.5877 4.64681 20.4371 4.59087 20.2868 4.53456"
        "C19.649 4.29644 19.2357 4.39809 19.0709 4.82101"
        "C18.9119 5.22829 19.1278 5.52611 19.7548 5.77133"
        "C19.9446 5.84546 20.1327 5.92191 20.321 5.99841"
        "C20.4089 6.03414 20.4969 6.06988 20.585 6.10541L20.6106 6.27742"
        "C20.3761 6.32595 20.1422 6.38168 19.9082 6.43741"
        "C19.3952 6.55962 18.8819 6.68191 18.3615 6.72877"
        "C16.5988 6.88799 14.9185 6.48426 13.2624 5.91563"
        "C12.9977 5.82487 12.7331 5.73277 12.4682 5.64061ZM11.0523"
        " 10.5891L11.4302 10.7305L12.1851 11.0163C13.4428 11.4904"
        " 14.7083 11.9403 16.0598 12.1329C17.5987 12.3533 19.0986"
        " 12.258 20.5872 11.6034C20.4854 11.5645 20.3839 11.525"
        " 20.2824 11.4855L20.2823 11.4855C20.0495 11.3949 19.8167"
        " 11.3043 19.5809 11.2217C19.1342 11.0653 18.9104 10.7561"
        " 19.0823 10.3275C19.2513 9.90601 19.6362 9.80294 20.073"
        " 9.96856C20.2601 10.0399 20.4474 10.1108 20.6347 10.1817L20.6356"
        " 10.1821C21.3629 10.4576 22.0903 10.7331 22.8079 11.0298"
        "C22.9521 11.0895 23.0717 11.2057 23.1912 11.3219C23.2466"
        " 11.3756 23.3019 11.4294 23.3597 11.4776V11.8088C23.2965"
        " 11.8598 23.2356 11.9154 23.1747 11.971L23.1747 11.971L23.1746"
        " 11.9711C23.0439 12.0904 22.9129 12.2099 22.7589 12.285"
        "C19.5262 13.868 16.2267 13.9284 12.8683 12.6802C11.7925"
        " 12.2792 10.7085 11.9005 9.61707 11.5444C7.00647 10.695"
        " 4.47114 10.9871 1.99404 12.0604C1.22705 12.3931 1.10419"
        " 12.3668 0.634051 11.8088V11.4776C0.838139 11.3672 1.03914"
        " 11.249 1.24014 11.1308C1.67842 10.873 2.11671 10.6153"
        " 2.58704 10.4384C5.42064 9.37363 8.25354 9.5499 11.0523"
        " 10.5891ZM11.1866 16.1091C12.7582 16.6685 14.3469 17.2108"
        " 15.9696 17.5996C17.5355 17.9749 19.1121 17.7418 20.7491"
        " 17.1454C20.5991 17.0852 20.4595 17.0287 20.3268 16.9751L20.3267"
        " 16.9751C20.0324 16.8561 19.7727 16.7512 19.5113 16.6493"
        "C19.1136 16.495 18.9367 16.2043 19.0752 15.8205C19.2208"
        " 15.4154 19.5539 15.2661 19.9857 15.4239L20.2218 15.5101"
        "C21.097 15.8295 21.9725 16.149 22.8391 16.4901"
        "C22.9735 16.5427 23.0871 16.6444 23.2009 16.7462"
        "C23.2531 16.7929 23.3054 16.8397 23.3597 16.8817V17.3224"
        "C23.2108 17.4108 23.0647 17.5056 22.9186 17.6003"
        "C22.5993 17.8075 22.2801 18.0146 21.9322 18.154"
        "C19.8486 18.9892 17.6854 19.4079 15.4576 18.8627"
        "C14.018 18.5101 12.5842 18.0822 11.2121 17.5364"
        "C8.07528 16.2868 4.98814 16.1205 1.89959 17.6288"
        "C1.38258 17.8804 0.953631 17.8242 0.634051 17.3231V16.8824"
        "C0.852075 16.785 1.06868 16.6827 1.28457 16.5782L1.93154"
        " 16.2647C2.47128 16.006 3.01669 15.7629 3.58626 15.5994"
        "C6.1642 14.8602 8.69313 15.2227 11.1866 16.1091Z";
    _parseSvgPath(dLifting, path);
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
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;

    switch (mode) {
      // 焕活 (Rejuvenating) - 6 small circles surrounding central ring
      case MaskModeType.rejuvenating:
        final r = w * 0.12;
        final orbitR = w * 0.32;
        for (int i = 0; i < 6; i++) {
          final angle = i * (math.pi / 3);
          final ox = cx + orbitR * math.cos(angle);
          final oy = cy + orbitR * math.sin(angle);
          canvas.drawCircle(Offset(ox, oy), r, paint);
        }
        break;

      // 紧致 (Firming) - 1:1 对齐 Figma 原设计稿：顶部水平基准线 + 居中垂直悬挂圆弧吊钩 + 5 条深层放射能量波
      case MaskModeType.firming:
        // 1. 顶部水平表皮基准线 (Skin surface)
        canvas.drawLine(
          Offset(w * 0.16, h * 0.22),
          Offset(w * 0.84, h * 0.22),
          paint,
        );

        // 2. 居中垂直悬挂的优美吊钩 (Hanging electrode hook)
        final cyLoop = h * 0.52;
        final r = w * 0.185;
        final hookPath = Path()
          // 从顶部横线正中垂直落笔至圆环顶部切点
          ..moveTo(cx, h * 0.22)
          ..lineTo(cx, cyLoop - r)
          // 从正上方(12点钟)顺滑向左绕经底部至右上(1点半方向收口)
          ..arcTo(
            Rect.fromCircle(center: Offset(cx, cyLoop), radius: r),
            -math.pi / 2,
            -math.pi * 5 / 3, // 逆时针扫过 300 度，留出右上 60 度优雅开口
            false,
          );
        canvas.drawPath(hookPath, paint);

        // 3. 下方 5 根辐射状微电流/射频深层能量波 (5 Radiant downward rays)
        final center = Offset(cx, cyLoop);
        final rInner = r + w * 0.08;
        final rOuter = r + w * 0.18;
        const angles = [150.0, 120.0, 90.0, 60.0, 30.0];
        for (final deg in angles) {
          final rad = deg * math.pi / 180;
          final p1 = Offset(center.dx + rInner * math.cos(rad), center.dy + rInner * math.sin(rad));
          final p2 = Offset(center.dx + rOuter * math.cos(rad), center.dy + rOuter * math.sin(rad));
          canvas.drawLine(p1, p2, paint);
        }
        break;

      // 提拉 (Lifting) - 1:1 Pixel-Perfect Figma vector path (Figma node 0:109)
      case MaskModeType.lifting:
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.scale(w / 24.0, h / 24.0);
        canvas.drawPath(_liftingPath, fillPaint);
        canvas.restore();
        break;

      // 瞬透 (Intensive Care) - 方案 B：星芒瞬穿滴（Sparkle Osmosis），方案 A 注释保留
      case MaskModeType.intensiveCare:
        /*
        // [方案 A: 穿透晶滴 (Infusion Droplet) - 注释备选]
        // 1. 顶部优雅凝露水滴（Teardrop）
        final dropPathA = Path();
        dropPathA.moveTo(cx, h * 0.10);
        dropPathA.cubicTo(
          cx - w * 0.05, h * 0.22,
          cx - w * 0.23, h * 0.36,
          cx - w * 0.23, h * 0.46,
        );
        dropPathA.cubicTo(
          cx - w * 0.23, h * 0.58,
          cx - w * 0.12, h * 0.60,
          cx, h * 0.60,
        );
        dropPathA.cubicTo(
          cx + w * 0.12, h * 0.60,
          cx + w * 0.23, h * 0.58,
          cx + w * 0.23, h * 0.46,
        );
        dropPathA.cubicTo(
          cx + w * 0.23, h * 0.36,
          cx + w * 0.05, h * 0.22,
          cx, h * 0.10,
        );
        canvas.drawPath(dropPathA, paint);

        // 2. 表层渗透微弧（Upper Stratum Ripple）
        final wave1 = Path();
        wave1.moveTo(w * 0.18, h * 0.71);
        wave1.quadraticBezierTo(cx, h * 0.77, w * 0.82, h * 0.71);
        canvas.drawPath(wave1, paint);

        // 3. 深层微澜波纹（Deep Dermis Ripple）
        final wave2 = Path();
        wave2.moveTo(w * 0.32, h * 0.85);
        wave2.quadraticBezierTo(cx, h * 0.91, w * 0.68, h * 0.85);
        canvas.drawPath(wave2, paint);
        */

        // [方案 B: 星芒瞬穿滴 (Sparkle Osmosis)]
        // 1. 纯净凝露水滴外廓（比例舒展饱满，覆盖 0.08h ~ 0.76h）
        final dropPath = Path();
        dropPath.moveTo(cx, h * 0.08);
        dropPath.cubicTo(
          cx - w * 0.06, h * 0.22,
          cx - w * 0.26, h * 0.40,
          cx - w * 0.26, h * 0.55,
        );
        dropPath.cubicTo(
          cx - w * 0.26, h * 0.70,
          cx - w * 0.13, h * 0.76,
          cx, h * 0.76,
        );
        dropPath.cubicTo(
          cx + w * 0.13, h * 0.76,
          cx + w * 0.26, h * 0.70,
          cx + w * 0.26, h * 0.55,
        );
        dropPath.cubicTo(
          cx + w * 0.26, h * 0.40,
          cx + w * 0.06, h * 0.22,
          cx, h * 0.08,
        );
        canvas.drawPath(dropPath, paint);

        // 2. 水滴核心嵌入精致高奢的四角星芒（Sparkle Star: 呈现瞬间穿透与微电流闪耀质感）
        final starCenterY = h * 0.50;
        final starPath = Path();
        final starRVert = h * 0.16;
        final starRHoriz = w * 0.12;
        // 顶部星尖
        starPath.moveTo(cx, starCenterY - starRVert);
        // 右凹弧至右星尖
        starPath.quadraticBezierTo(cx + w * 0.025, starCenterY - h * 0.025, cx + starRHoriz, starCenterY);
        // 下凹弧至底星尖
        starPath.quadraticBezierTo(cx + w * 0.025, starCenterY + h * 0.025, cx, starCenterY + starRVert);
        // 左凹弧至左星尖
        starPath.quadraticBezierTo(cx - w * 0.025, starCenterY + h * 0.025, cx - starRHoriz, starCenterY);
        // 上凹弧回到顶星尖
        starPath.quadraticBezierTo(cx - w * 0.025, starCenterY - h * 0.025, cx, starCenterY - starRVert);
        canvas.drawPath(starPath, paint);

        // 3. 水滴下方穿透向下的微电流导入射线（Downward Infusion Ray）
        canvas.drawLine(
          Offset(cx, h * 0.83),
          Offset(cx, h * 0.93),
          paint,
        );
        break;

      // 活肌 (Revitalizing) - 1:1 Pixel-Perfect Figma vector path (Figma 18:692)
      case MaskModeType.revitalizing:
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.scale(w / 24.0, h / 24.0);
        canvas.drawPath(_revitalizingPath, fillPaint);
        canvas.restore();
        break;

      // 澎弹 (Plumping) - 1:1 Pixel-Perfect Figma vector path (Figma node 0:71)
      case MaskModeType.plumping:
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.scale(w / 24.0, h / 24.0);
        canvas.drawPath(_plumpingPath, fillPaint);
        canvas.restore();
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BeautyHubIconPainter oldDelegate) {
    return oldDelegate.mode != mode || oldDelegate.color != color;
  }
}
