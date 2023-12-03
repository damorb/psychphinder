// ignore_for_file: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/global/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:psychphinder/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_saver/file_saver.dart';

class CreateImagePage extends StatefulWidget {
  final List episode;
  final int id;

  const CreateImagePage({Key? key, required this.episode, required this.id})
      : super(key: key);

  @override
  State<CreateImagePage> createState() => _CreateImageState();
}

class _CreateImageState extends State<CreateImagePage> {
  WidgetsToImageController controller = WidgetsToImageController();
  Uint8List? bytes;
  String mainLine = '';
  String beforeLine = '';
  String afterLine = '';
  bool beforeLineCheck = false;
  bool afterLineCheck = false;
  bool showPsychphinder = true;
  bool applyOffset = true;
  bool applyGradient = true;
  bool showBackgroundImage = true;
  int resolutionW = 0;
  int resolutionH = 0;
  String widgetTopRight = 'Episode name';
  String widgetTopLeft = 'Psych logo';
  String widgetBottomLeft = 'Season and episode';
  String widgetBottomRight = 'Time';
  String imageType = 'Post';
  double wallpaperOffset = 16;
  double wallpaperScale = 1.07;
  double psychLogoSize = 18;
  double infoSize = 8;
  double lineSize = 14;
  double secondarylineSize = 8;
  double boxSize = 110;
  double madeWithPsychphidnerSize = 3.5;
  double backgroundSize = 30.0;
  Color bgColor = Colors.green;
  Color lineColor = Colors.white;
  Color beforeLineColor = Colors.white;
  Color afterLineColor = Colors.white;
  Color topLeftColor = Colors.white;
  Color topRightColor = Colors.white;
  Color bottomLeftColor = Colors.white;
  Color bottomRightColor = Colors.white;
  Color psychphinderColor = Colors.white;
  Color backgroundImageColor = Colors.black.withOpacity(0.1);
  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    FToast fToast = FToast();
    fToast.init(navigatorKey.currentContext!);
    mainLine = widget.episode[widget.id].line;
    if (widget.id != 0) {
      beforeLine = widget.episode[widget.id - 1].line;
    } else {
      beforeLine = "";
    }

    if (widget.id != widget.episode.length - 1) {
      afterLine = widget.episode[widget.id + 1].line;
    } else {
      afterLine = "";
    }

    if (widget.episode[widget.id].season == 0) {
      widgetTopRight = "Movie name";
    }
    if (widget.episode[widget.id].season == 0) {
      widgetBottomLeft = "Movie";
    }

    getResolution().whenComplete(() => changeOffset());
    getColors();
    getBackgroundProperties();
    getShowMadeWithPsychphinder();
  }

  void update(String value, int selectedIndex) {
    if (selectedIndex == 0) {
      setState(() {
        widgetTopLeft = value;
      });
    } else if (selectedIndex == 1) {
      setState(() {
        widgetTopRight = value;
      });
    } else if (selectedIndex == 2) {
      setState(() {
        widgetBottomLeft = value;
      });
    } else if (selectedIndex == 3) {
      setState(() {
        widgetBottomRight = value;
      });
    }
  }

  void updateColor(Color color, int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        setState(() {
          topLeftColor = color;
        });
        break;
      case 1:
        setState(() {
          topRightColor = color;
        });
        break;
      case 2:
        setState(() {
          bottomLeftColor = color;
        });
        break;
      case 3:
        setState(() {
          bottomRightColor = color;
        });
        break;
      case 4:
        setState(() {
          beforeLineColor = color;
        });
        break;
      case 5:
        setState(() {
          lineColor = color;
        });
        break;
      case 6:
        setState(() {
          afterLineColor = color;
        });
        break;
      case 7:
        setState(() {
          bgColor = color;
        });
        break;
      case 8:
        setState(() {
          psychphinderColor = color;
        });
        break;
      case 9:
        setState(() {
          backgroundImageColor = color;
        });
        break;
    }
  }

  Widget topLeftWidget() {
    switch (widgetTopLeft) {
      case "Psych Logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: topLeftColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: topLeftColor,
          applyOffset: applyOffset,
          imageType: imageType,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: topLeftColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: topLeftColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: topLeftColor,
          imageType: imageType,
        );
    }
  }

  Widget topRightWidget() {
    switch (widgetTopRight) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: topRightColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: topRightColor,
          applyOffset: applyOffset,
          imageType: imageType,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: topRightColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: topRightColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: topRightColor,
          applyOffset: applyOffset,
          imageType: imageType,
          box: boxSize,
        );
    }
  }

  Widget bottomRightWidget() {
    switch (widgetBottomRight) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: bottomRightColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: bottomRightColor,
          applyOffset: applyOffset,
          imageType: imageType,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: bottomRightColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: bottomRightColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: bottomRightColor,
          imageType: imageType,
        );
    }
  }

  Widget bottomLeftWidget() {
    switch (widgetBottomLeft) {
      case "Psych logo":
        return PsychLogoWidget(
          size: psychLogoSize,
          textColor: bottomLeftColor,
          imageType: imageType,
        );
      case "Episode name" || "Movie name":
        return EpisodeNameWidget(
          name: widget.episode[widget.id].name,
          size: infoSize,
          textColor: bottomLeftColor,
          applyOffset: applyOffset,
          imageType: imageType,
          box: boxSize,
        );
      case "Season and episode" || "Movie":
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: bottomLeftColor,
          imageType: imageType,
        );
      case "Time":
        return TimeWidget(
          time: widget.episode[widget.id].time,
          size: infoSize,
          textColor: bottomLeftColor,
          imageType: imageType,
        );
      case "None":
        return const SizedBox();
      default:
        return SeasonAndEpisodeWidget(
          season: widget.episode[widget.id].season.toString(),
          episode: widget.episode[widget.id].episode.toString(),
          size: infoSize,
          textColor: bottomLeftColor,
          imageType: imageType,
        );
    }
  }

  _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(width: 12.0),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<void> getResolution() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        resolutionW = pref.getInt("ResolutionWidth") ??
            (MediaQuery.of(context).size.width *
                    MediaQuery.of(context).devicePixelRatio)
                .toInt();
        resolutionH = pref.getInt("ResolutionHeight") ??
            ((MediaQuery.of(context).size.height +
                        MediaQuery.of(context).padding.bottom +
                        MediaQuery.of(context).padding.top) *
                    MediaQuery.of(context).devicePixelRatio)
                .toInt();
      },
    );
    pref.setInt("ResolutionWidth", resolutionW);
    pref.setInt("ResolutionHeight", resolutionH);
  }

  Future<void> setResolutionHeight(int resolutionHeight) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("ResolutionHeight", resolutionHeight);
  }

  Future<void> setResolutionWidth(int resolutionWidth) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt("ResolutionWidth", resolutionWidth);
  }

  Future<void> setShowBackgoundImage(bool showBackgroundImage) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("showBackgroundImage", showBackgroundImage);
  }

  Future<void> setBackgroundImageSize(double size) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble("backgroundSize", backgroundSize);
  }

  Future<void> setApplyGradient(bool applyGradient) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("applyGradient", applyGradient);
  }

  Future<void> setShowMadeWithPsychphinder(
      bool showMadeWithPsychphinder) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("showMadeWithPsychphinder", showMadeWithPsychphinder);
  }

  Future<void> getShowMadeWithPsychphinder() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        showPsychphinder = pref.getBool("showMadeWithPsychphinder") ?? true;
      },
    );
  }

  Future<void> getBackgroundProperties() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        showBackgroundImage = pref.getBool("showBackgroundImage") ?? true;
        backgroundSize = pref.getDouble("backgroundSize") ?? 30.0;
        applyGradient = pref.getBool("applyGradient") ?? true;
      },
    );
  }

  Future<void> getColors() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(
      () {
        bottomRightColor = pref.getInt("bottomRightColor") == null
            ? Colors.white
            : Color(pref.getInt("bottomRightColor")!);
        bottomLeftColor = pref.getInt("bottomLeftColor") == null
            ? Colors.white
            : Color(pref.getInt("bottomLeftColor")!);
        topRightColor = pref.getInt("topRightColor") == null
            ? Colors.white
            : Color(pref.getInt("topRightColor")!);
        topLeftColor = pref.getInt("topLeftColor") == null
            ? Colors.white
            : Color(pref.getInt("topLeftColor")!);
        lineColor = pref.getInt("lineColor") == null
            ? Colors.white
            : Color(pref.getInt("lineColor")!);
        beforeLineColor = pref.getInt("beforeLineColor") == null
            ? Colors.white
            : Color(pref.getInt("beforeLineColor")!);
        afterLineColor = pref.getInt("afterLineColor") == null
            ? Colors.white
            : Color(pref.getInt("afterLineColor")!);
        bgColor = pref.getInt("bgColor") == null
            ? Colors.green
            : Color(pref.getInt("bgColor")!);
        psychphinderColor = pref.getInt("psychphinderColor") == null
            ? Colors.white
            : Color(pref.getInt("psychphinderColor")!);
        backgroundImageColor = pref.getInt("backgroundImageColor") == null
            ? Colors.black.withOpacity(0.1)
            : Color(pref.getInt("backgroundImageColor")!);
      },
    );
  }

  Future<void> setColors(String key, int value) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(key, value);
  }

  void reduceSizeBelow1080() {
    if (imageType == 'Wallpaper') {
      if (resolutionW < 1080) {
        double ratio = resolutionW / 1080;
        setState(() {
          psychLogoSize = 18 * ratio;
          infoSize = 8 * ratio;
          lineSize = 14 * ratio;
          secondarylineSize = 8 * ratio;
          boxSize = 70;
          madeWithPsychphidnerSize = 3.5 * ratio;
        });
      } else {
        setState(() {
          psychLogoSize = 18;
          infoSize = 8;
          lineSize = 14;
          secondarylineSize = 8;
          boxSize = 110;
          madeWithPsychphidnerSize = 3.5;
        });
      }
    } else {
      setState(() {
        psychLogoSize = 18;
        infoSize = 8;
        lineSize = 14;
        secondarylineSize = 8;
        boxSize = 110;
        madeWithPsychphidnerSize = 3.5;
      });
    }
  }

  Future<void> changeOffset() async {
    setState(() {
      if (resolutionW / resolutionH > 1) {
        applyOffset = false;
      } else {
        applyOffset = true;
      }

      if (applyOffset) {
        wallpaperOffset = 16;
        wallpaperScale = 1.07;
      } else {
        wallpaperOffset = 0;
        wallpaperScale = 1;
      }
    });
  }

  Color darkenColor(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lightenColor(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    reduceSizeBelow1080();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Share',
          style: TextStyle(
            fontSize: 25,
            color: Colors.green,
            fontFamily: 'PsychFont',
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: imageType == 'Wallpaper'
                ? (resolutionW >= resolutionH
                    ? MediaQuery.of(context).size.width * 0.7
                    : null)
                : MediaQuery.of(context).size.height * 0.5,
            height: imageType == 'Wallpaper'
                ? (resolutionH > resolutionW
                    ? MediaQuery.of(context).size.height * 0.5
                    : null)
                : null,
            child: FittedBox(
              child: Center(
                child: UnconstrainedBox(
                  child: SizedBox(
                    height: imageType == 'Post'
                        ? 1080 / 6
                        : (resolutionH) * wallpaperScale / 6,
                    width: imageType == 'Post'
                        ? 1080 / 6
                        : (resolutionW) * wallpaperScale / 6,
                    child: WidgetsToImage(
                      controller: controller,
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          gradient: applyGradient
                              ? LinearGradient(
                                  colors: [
                                    lightenColor(bgColor, 0.1),
                                    bgColor,
                                    darkenColor(bgColor, 0.1),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                        ),
                        child: Stack(
                          children: [
                            showBackgroundImage
                                ? GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: backgroundSize,
                                      mainAxisExtent: backgroundSize,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Image.asset(
                                        'assets/background/pineapple.png',
                                        color: backgroundImageColor,
                                      );
                                    },
                                  )
                                : Container(),
                            Positioned(
                              top: imageType == 'Post'
                                  ? (widgetTopLeft == 'Psych logo' ? -2 : 5)
                                  : (widgetTopLeft == 'Psych logo'
                                      ? (9 + wallpaperOffset)
                                      : (17 + wallpaperOffset)),
                              left: imageType == 'Post'
                                  ? 5
                                  : (5 + wallpaperOffset),
                              child: topLeftWidget(),
                            ),
                            Positioned(
                                top: imageType == 'Post'
                                    ? (widgetTopRight == 'Psych logo' ? -2 : 5)
                                    : (widgetTopRight == 'Psych logo'
                                        ? (9 + wallpaperOffset)
                                        : (17 + wallpaperOffset)),
                                right: imageType == 'Post'
                                    ? 5
                                    : (5 + wallpaperOffset),
                                child: topRightWidget()),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  beforeLineCheck
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 2, 8, 2),
                                          child: ConstrainedBox(
                                            constraints:
                                                imageType == 'Wallpaper'
                                                    ? applyOffset
                                                        ? const BoxConstraints(
                                                            maxWidth: 155)
                                                        : const BoxConstraints()
                                                    : const BoxConstraints(),
                                            child: TextWidget(
                                              text: beforeLine,
                                              size: imageType == 'Wallpaper'
                                                  ? secondarylineSize /
                                                      wallpaperScale
                                                  : secondarylineSize,
                                              textColor: beforeLineColor,
                                              imageType: imageType,
                                            ),
                                          ))
                                      : Container(),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                    child: ConstrainedBox(
                                      constraints: imageType == 'Wallpaper'
                                          ? applyOffset
                                              ? const BoxConstraints(
                                                  maxWidth: 155)
                                              : const BoxConstraints()
                                          : const BoxConstraints(),
                                      child: TextWidget(
                                        text: mainLine,
                                        size: imageType == 'Wallpaper'
                                            ? lineSize
                                            : lineSize,
                                        textColor: lineColor,
                                        imageType: imageType,
                                      ),
                                    ),
                                  ),
                                  afterLineCheck
                                      ? Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 2, 8, 2),
                                          child: ConstrainedBox(
                                            constraints:
                                                imageType == 'Wallpaper'
                                                    ? applyOffset
                                                        ? const BoxConstraints(
                                                            maxWidth: 155)
                                                        : const BoxConstraints()
                                                    : const BoxConstraints(),
                                            child: TextWidget(
                                              text: afterLine,
                                              size: imageType == 'Wallpaper'
                                                  ? secondarylineSize /
                                                      wallpaperScale
                                                  : secondarylineSize,
                                              textColor: afterLineColor,
                                              imageType: imageType,
                                            ),
                                          ))
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: imageType == 'Post'
                                  ? (widgetBottomLeft == 'Psych logo' ? 0 : 5)
                                  : (widgetBottomLeft == 'Psych logo'
                                      ? (5 + wallpaperOffset)
                                      : (10 + wallpaperOffset)),
                              left: imageType == 'Post'
                                  ? 5
                                  : (5 + wallpaperOffset),
                              child: bottomLeftWidget(),
                            ),
                            Positioned(
                              bottom: imageType == 'Post'
                                  ? (widgetBottomRight == 'Psych logo' ? 2 : 5)
                                  : (widgetBottomRight == 'Psych logo'
                                      ? (7 + wallpaperOffset)
                                      : (10 + wallpaperOffset)),
                              right: imageType == 'Post'
                                  ? 5
                                  : (5 + wallpaperOffset),
                              child: bottomRightWidget(),
                            ),
                            showPsychphinder
                                ? Positioned(
                                    bottom: imageType == 'Post'
                                        ? 1
                                        : (6 + wallpaperOffset),
                                    right: imageType == 'Post'
                                        ? 1
                                        : (1 + wallpaperOffset),
                                    child: Text(
                                      "Made with psychphinder",
                                      style: TextStyle(
                                        fontSize: madeWithPsychphidnerSize,
                                        fontFamily: 'PsychFont',
                                        color: psychphinderColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    typeSelection(),
                    customization(context),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            shareImage(),
                            !kIsWeb
                                ? (Platform.isAndroid
                                    ? const SizedBox(width: 15)
                                    : const SizedBox())
                                : const SizedBox(),
                            !kIsWeb
                                ? (Platform.isAndroid
                                    ? saveToGallery()
                                    : const SizedBox())
                                : const SizedBox(),
                          ],
                        ),
                        !kIsWeb
                            ? (Platform.isAndroid
                                ? const SizedBox(height: 15)
                                : const SizedBox())
                            : const SizedBox(),
                        !kIsWeb
                            ? (imageType == 'Wallpaper' && Platform.isAndroid
                                ? saveAsWallpaper(context)
                                : const SizedBox())
                            : const SizedBox(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding typeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            "Type",
            style: TextStyle(fontSize: 16),
          ),
          const Spacer(),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              iconSize: 30,
              iconEnabledColor: Colors.white,
              dropdownColor: Colors.green,
              decoration: InputDecoration(
                fillColor: Colors.green,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
              value: imageType,
              items: const [
                DropdownMenuItem(
                  value: 'Post',
                  child: Text(
                    'Post',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Wallpaper',
                  child: Text(
                    'Wallpaper',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  imageType = value!;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  ElevatedButton shareImage() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            !kIsWeb ? (Platform.isAndroid ? "Share" : "Save") : "Save",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            !kIsWeb
                ? (Platform.isAndroid
                    ? Icons.share_rounded
                    : Icons.save_rounded)
                : Icons.save_rounded,
            color: Colors.white,
          ),
        ],
      ),
      onPressed: () async {
        final bytes = await controller.capture();
        setState(() {
          this.bytes = bytes;
        });
        if (!kIsWeb) {
          if (Platform.isAndroid) {
            final cacheDir = await getTemporaryDirectory();
            final fileName = path.join(cacheDir.path, 'image.png');
            await File(fileName).writeAsBytes(bytes!);
            final result = await Share.shareXFiles([XFile(fileName)]);
            if (cacheDir.existsSync()) {
              cacheDir.deleteSync(recursive: true);
            }
            if (result.status == ShareResultStatus.success) {
              _showToast("Shared image!");
            }
          } else {
            String? outputFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Please select an output file:',
              fileName: 'image.png',
            );
            if (outputFile != null) {
              File(outputFile).writeAsBytes(bytes!);
              _showToast("Saved image!");
            }
          }
        } else {
          await FileSaver.instance
              .saveFile(name: 'psychphinder.png', bytes: bytes!);
          _showToast("Saved image!");
        }
      },
    );
  }

  ElevatedButton saveToGallery() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Save to gallery",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.save_rounded,
            color: Colors.white,
          ),
        ],
      ),
      onPressed: () async {
        final bytes = await controller.capture();
        setState(() {
          this.bytes = bytes;
        });
        if (!kIsWeb) {
          if (Platform.isAndroid) {
            final cacheDir = await getTemporaryDirectory();
            await Gal.putImageBytes(bytes!);
            if (cacheDir.existsSync()) {
              cacheDir.deleteSync(recursive: true);
            }
            _showToast("Saved image!");
          }
        }
      },
    );
  }

  ElevatedButton saveAsWallpaper(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Set as wallpaper",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.wallpaper,
            color: Colors.white,
          ),
        ],
      ),
      onPressed: () async {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: Colors.green,
            title: const Center(
              child: Text(
                'Set wallpaper in',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PsychFont',
                    fontWeight: FontWeight.bold),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      const Size(160, 30),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                    });
                    final cacheDir = await getTemporaryDirectory();
                    final fileName = path.join(cacheDir.path, 'wallpaper.png');
                    await File(fileName).writeAsBytes(bytes!);
                    int location = WallpaperManager.HOME_SCREEN;
                    bool result = await WallpaperManager.setWallpaperFromFile(
                        fileName, location);
                    if (result) {
                      _showToast("Set as wallpaper!");
                      if (cacheDir.existsSync()) {
                        cacheDir.deleteSync(recursive: true);
                      }
                    }
                  },
                  child: const Text(
                    "Home screen",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      const Size(160, 30),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                    });
                    final cacheDir = await getTemporaryDirectory();
                    final fileName = path.join(cacheDir.path, 'wallpaper.png');
                    await File(fileName).writeAsBytes(bytes!);
                    int location = WallpaperManager.LOCK_SCREEN;
                    bool result = await WallpaperManager.setWallpaperFromFile(
                        fileName, location);
                    if (result) {
                      _showToast("Set as wallpaper!");
                      if (cacheDir.existsSync()) {
                        cacheDir.deleteSync(recursive: true);
                      }
                    }
                  },
                  child: const Text(
                    "Lock screen",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      const Size(160, 30),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final bytes = await controller.capture();
                    setState(() {
                      this.bytes = bytes;
                    });
                    final cacheDir = await getTemporaryDirectory();
                    final fileName = path.join(cacheDir.path, 'wallpaper.png');
                    await File(fileName).writeAsBytes(bytes!);
                    int location = WallpaperManager.BOTH_SCREEN;
                    bool result = await WallpaperManager.setWallpaperFromFile(
                        fileName, location);
                    if (result) {
                      _showToast("Set as wallpaper!");
                      if (cacheDir.existsSync()) {
                        cacheDir.deleteSync(recursive: true);
                      }
                    }
                  },
                  child: const Text(
                    "Both",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ExpansionTile customization(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Customization',
      ),
      children: [
        imageType == 'Wallpaper'
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Resolution',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Width',
                          counterText: "",
                        ),
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onFieldSubmitted: (value) {
                          setState(() {
                            resolutionW = int.parse(value);
                            setResolutionWidth(resolutionW);
                            changeOffset();
                          });
                        },
                        initialValue: resolutionW.toString(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'x',
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Height',
                          counterText: "",
                        ),
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onFieldSubmitted: (value) {
                          setState(() {
                            resolutionH = int.parse(value);
                            setResolutionHeight(resolutionH);
                            changeOffset();
                          });
                        },
                        initialValue: resolutionH.toString(),
                      ),
                    )
                  ],
                ),
              )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Top left text',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  colorPickerWidget(context, topLeftColor, 0, "topLeftColor"),
                  dropdownButton(context, widgetTopLeft, 0),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Top right text',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  colorPickerWidget(context, topRightColor, 1, "topRightColor"),
                  dropdownButton(context, widgetTopRight, 1),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Line before',
                  ),
                  initialValue: beforeLine,
                  onChanged: (value) {
                    setState(() {
                      beforeLine = value;
                    });
                  },
                ),
              ),
              Checkbox(
                value: beforeLineCheck,
                onChanged: (value) {
                  setState(() {
                    beforeLineCheck = value!;
                  });
                },
              ),
              beforeLineCheck
                  ? colorPickerWidget(
                      context,
                      beforeLineColor,
                      4,
                      "beforeLineColor",
                      size: 12,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Line',
                  ),
                  initialValue: mainLine,
                  onChanged: (value) {
                    setState(() {
                      mainLine = value;
                    });
                  },
                ),
              ),
              colorPickerWidget(
                context,
                lineColor,
                5,
                "lineColor",
                size: 12,
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Line after',
                  ),
                  initialValue: afterLine,
                  onChanged: (value) {
                    setState(() {
                      afterLine = value;
                    });
                  },
                ),
              ),
              Checkbox(
                value: afterLineCheck,
                onChanged: (value) {
                  setState(() {
                    afterLineCheck = value!;
                  });
                },
              ),
              afterLineCheck
                  ? colorPickerWidget(
                      context,
                      afterLineColor,
                      6,
                      "afterLineColor",
                      size: 12,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Bottom left text',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  colorPickerWidget(
                      context, bottomLeftColor, 2, "bottomLeftColor"),
                  dropdownButton(context, widgetBottomLeft, 2),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Bottom right text',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  colorPickerWidget(
                      context, bottomRightColor, 3, "bottomRightColor"),
                  dropdownButton(context, widgetBottomRight, 3),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Background color",
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              colorPickerWidget(context, bgColor, 7, "bgColor"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Apply gradient to background",
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Switch(
                value: applyGradient,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    applyGradient = value;
                    setApplyGradient(applyGradient);
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Show background image",
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Switch(
                value: showBackgroundImage,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    showBackgroundImage = value;
                    setShowBackgoundImage(showBackgroundImage);
                  });
                },
              ),
            ],
          ),
        ),
        showBackgroundImage
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Background image color/size",
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        colorPickerWidget(context, backgroundImageColor, 9,
                            "backgroundImageColor",
                            showAlpha: true),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                        trackHeight: 20,
                      ),
                      child: Slider(
                        value: backgroundSize,
                        max: imageType == 'Post'
                            ? 1080 / 6
                            : resolutionW.toDouble() / 6,
                        min: 10,
                        divisions: 20,
                        onChanged: (double value) {
                          setState(() {
                            backgroundSize = value;
                          });
                        },
                        onChangeEnd: (double value) {
                          setBackgroundImageSize(value);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                "Show \"Made with psychphinder\"",
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              showPsychphinder
                  ? colorPickerWidget(
                      context, psychphinderColor, 8, "psychphinderColor")
                  : const SizedBox(),
              Switch(
                value: showPsychphinder,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    showPsychphinder = value;
                    setShowMadeWithPsychphinder(showPsychphinder);
                  });
                },
              ),
            ],
          ),
        ),
        imageType == 'Wallpaper'
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      "Apply offset fix",
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Switch(
                      value: applyOffset,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        setState(() {
                          applyOffset = value;
                          if (applyOffset) {
                            wallpaperOffset = 16;
                            wallpaperScale = 1.07;
                          } else {
                            wallpaperOffset = 0;
                            wallpaperScale = 1;
                          }
                        });
                      },
                    )
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Padding colorPickerWidget(
      BuildContext context, Color currentColor, int index, String key,
      {double size = 16, bool showAlpha = false}) {
    Color newColor = currentColor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () async {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                "Pick a color",
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: PopScope(
                      onPopInvoked: (didPop) {
                        setColors(key, newColor.value);
                        return;
                      },
                      child: HueRingPicker(
                        portraitOnly: true,
                        pickerColor: newColor,
                        displayThumbColor: true,
                        enableAlpha: showAlpha,
                        onColorChanged: (value) {
                          setState(() {
                            newColor = value;
                            updateColor(newColor, index);
                          });
                        },
                      )),
                ),
              ),
              actions: [
                ElevatedButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    setColors(key, newColor.value);
                    Navigator.of(context).pop();
                  },
                ),
                key != "bgColor" && key != "backgroundImageColor"
                    ? key == "beforeLineColor" ||
                            key == "lineColor" ||
                            key == "afterLineColor"
                        ? ElevatedButton(
                            child: const Text('Apply to all center text'),
                            onPressed: () {
                              updateColor(newColor, 4);
                              updateColor(newColor, 5);
                              updateColor(newColor, 6);
                              setColors("beforeLineColor", newColor.value);
                              setColors("lineColor", newColor.value);
                              setColors("afterLineColor", newColor.value);
                              Navigator.of(context).pop();
                            },
                          )
                        : ElevatedButton(
                            child: const Text('Apply to all border text'),
                            onPressed: () {
                              updateColor(newColor, 0);
                              updateColor(newColor, 1);
                              updateColor(newColor, 2);
                              updateColor(newColor, 3);
                              updateColor(newColor, 8);
                              setColors("topLeftColor", newColor.value);
                              setColors("topRightColor", newColor.value);
                              setColors("bottomLeftColor", newColor.value);
                              setColors("bottomRightColor", newColor.value);
                              setColors("psychphinderColor", newColor.value);
                              Navigator.of(context).pop();
                            },
                          )
                    : const SizedBox(),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: Size.fromRadius(size),
            maximumSize: Size.fromRadius(size),
            backgroundColor: newColor,
            shape: CircleBorder(
              side: BorderSide(
                  color: Provider.of<ThemeProvider>(context).currentThemeType ==
                          ThemeType.light
                      ? Colors.black
                      : Colors.white,
                  width: 2),
            )),
        child: CircleAvatar(
          backgroundColor: newColor,
          radius: size,
        ),
      ),
    );
  }

  SizedBox dropdownButton(BuildContext context, String current, int index) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        iconSize: 30,
        iconEnabledColor: Colors.white,
        dropdownColor: Colors.green,
        decoration: InputDecoration(
          fillColor: Colors.green,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.green),
          ),
        ),
        value: current,
        items: [
          const DropdownMenuItem(
            value: 'Psych logo',
            child: Text(
              'Psych logo',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DropdownMenuItem(
            value: widget.episode[widget.id].season != 0
                ? 'Episode name'
                : 'Movie name',
            child: Text(
              widget.episode[widget.id].season != 0
                  ? 'Episode name'
                  : 'Movie name',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DropdownMenuItem(
            value: widget.episode[widget.id].season != 0
                ? 'Season and episode'
                : 'Movie',
            child: Text(
              widget.episode[widget.id].season != 0
                  ? 'Season and episode'
                  : 'Movie',
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const DropdownMenuItem(
            value: 'Time',
            child: Text(
              'Time',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const DropdownMenuItem(
            value: 'None',
            child: Text(
              'None',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            update(value!, index);
          });
        },
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    required this.size,
    required this.textColor,
    required this.imageType,
  });

  final String text;
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: textColor,
        fontFamily: 'PsychFont',
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.time,
    required this.size,
    required this.textColor,
    required this.imageType,
  });
  final String time;
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextWidget(
        text: time[0] == '0' ? time.substring(2) : time,
        size: size,
        textColor: textColor,
        imageType: imageType,
      ),
    );
  }
}

class SeasonAndEpisodeWidget extends StatelessWidget {
  const SeasonAndEpisodeWidget({
    super.key,
    required this.season,
    required this.episode,
    required this.size,
    required this.textColor,
    required this.imageType,
  });
  final String season;
  final String episode;
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: TextWidget(
        text: season != "0" ? "Season $season, Episode $episode" : "Movie",
        size: size,
        textColor: textColor,
        imageType: imageType,
      ),
    );
  }
}

class EpisodeNameWidget extends StatelessWidget {
  const EpisodeNameWidget({
    super.key,
    required this.name,
    required this.size,
    required this.textColor,
    required this.applyOffset,
    required this.imageType,
    required this.box,
  });
  final String name;
  final double size;
  final Color textColor;
  final bool applyOffset;
  final String imageType;
  final double box;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
          constraints: imageType == 'Wallpaper'
              ? (applyOffset
                  ? BoxConstraints(maxWidth: box - 20)
                  : BoxConstraints(maxWidth: box))
              : BoxConstraints(maxWidth: box),
          child: TextWidget(
            text: name,
            size: size,
            textColor: textColor,
            imageType: imageType,
          )),
    );
  }
}

class PsychLogoWidget extends StatelessWidget {
  const PsychLogoWidget({
    super.key,
    required this.size,
    required this.textColor,
    required this.imageType,
  });
  final double size;
  final Color textColor;
  final String imageType;

  @override
  Widget build(BuildContext context) {
    return Text(
      "psych",
      style: TextStyle(
        fontSize: size,
        color: textColor,
        fontFamily: 'PsychFont',
        fontWeight: FontWeight.bold,
        letterSpacing: -1.6,
      ),
      textAlign: TextAlign.center,
    );
  }
}
