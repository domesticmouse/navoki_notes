import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:navokinotes/blocs/home_bloc.dart';
import 'package:navokinotes/blocs/login_bloc.dart';
import 'package:navokinotes/blocs/notes_bloc.dart';
import 'package:navokinotes/callbacks/click_callback.dart';
import 'package:navokinotes/enums/note_actions.dart';
import 'package:navokinotes/screen/login_page.dart';
import 'package:navokinotes/screen/note_detail.dart';
import 'package:navokinotes/screen/note_list.dart';
import 'package:navokinotes/utils/app_constants.dart';
import 'package:navokinotes/utils/device.dart';
import 'package:navokinotes/utils/utils.dart';
import 'package:provider/provider.dart';

import '../services/shared_preferences_services.dart';

/// Home page UI
class HomePage extends StatefulWidget {
  final String token;

  const HomePage(this.token, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late HomeBloc homeBloc;
  bool isMobile = true;
  bool isNight = false;
  bool showNote = false;
  Timer? timer;
  late AnimationController _controller;
  late Animation<Color?> animation, animation2;
  Device? device;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      homeBloc.getNotes();
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    /// Change Background Color animation
    animation = ColorTween(
      begin: Colors.white,
      end: Colors.grey[800],
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    /// Change Text and Icon Color invert of [animation]
    animation2 = ColorTween(
      begin: Colors.grey[800],
      end: Colors.white,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    Utils.deviceHeight = MediaQuery.of(context).size.height;
    Utils.deviceWidth = MediaQuery.of(context).size.width;
    isMobile = Utils.deviceWidth! > Utils.deviceHeight! ? false : true;

    device = Device(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);

    homeBloc = Provider.of<HomeBloc>(context);

    return RefreshIndicator(
      onRefresh: () async {
        homeBloc.getNotes();
        await Future.delayed(const Duration(seconds: 2), () {});

        return;
      },
      child: buildScaffold(context),
    );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SizedBox(
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              isNight
                  ? Flexible(
                      child: Text(
                        'Navoki',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          color: animation2.value,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Blaster',
                          height: 1,
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/navoki_banner.png',
                      height: 40,
                      width: 100,
                    ),
              Text(
                ' Notes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: animation2.value,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          /// All Social Links
          PopupMenuButton<int>(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/navoki.png',
                height: 30,
                width: 30,
              ),
            ),
            onSelected: (int index) {
              Utils.launchURL(AppConstants.socialLinks[index]['link']);
            },
            itemBuilder: (BuildContext context) {
              return List.generate(
                  AppConstants.socialLinks.length,
                  (index) => PopupMenuItem<int>(
                        value: index,
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              AppConstants.socialLinks[index]['icon'],
                              height: 40,
                              width: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                AppConstants.socialLinks[index]['name']
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      )).toList();
            },
          ),

          /// Enable Night Mode
          isNight
              ? IconButton(
                  icon: Icon(Icons.brightness_7, color: animation2.value),
                  onPressed: () {
                    setState(() {
                      isNight = false;
                    });
                    _controller.reverse();
                  })
              : IconButton(
                  icon: Icon(Icons.brightness_3, color: animation2.value),
                  onPressed: () {
                    setState(() {
                      isNight = true;
                    });
                    _controller.forward();
                  }),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: animation2.value),
            onSelected: (String result) {
              Utils.loginToken = null;
              SharedPreferencesService.instance.clearSharedPreferences();
              //  homeBloc.localDataStorage.clear();
              homeBloc.notesList.clear();
              print('Logout Token ${Utils.loginToken}');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider<LoginBloc>(
                        create: (context) => LoginBloc(),
                        child: const LoginPage())),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Align(
              alignment: const Alignment(-1.1, 1.1),
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/images/pattern1.png',
                  height: 200,
                  width: 200,
                ),
              )),
          Align(
            alignment: const Alignment(-1.1, 1.1),
            child: Image.asset('assets/images/pattern1.png',
                height: 200, width: 150),
          ),
          Align(
              alignment: const Alignment(1.1, 1.0),
              child: Image.asset('assets/images/pattern2.png')),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<HomeBloc>(builder: (context, bloc, child) {
              if (homeBloc.errorMsg != null) {
                return getErrorView(homeBloc.errorMsg!);
              }

              return NoteList(onSelect: (note, param, refresh) {
                /// Callback to Open Single Note to Edit
                showAddNoteDialog(
                  onCancel: (data, param, refresh) {
                    timer = Timer(const Duration(seconds: 2), () {
                      /// Refresh List
                      homeBloc.getNotes();
                    });

                    ///Close Dialog and Update Note Content on background
                    onNoteCloses(param, refresh);
                  },
                );
              });
            }),
          ),
        ],
      ),

      /// Add new Note
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          homeBloc.notesBloc = NotesBloc.empty();

          /// Add new Note Dialog
          showAddNoteDialog(onCancel: (data, param, refresh) {
            timer = Timer(const Duration(seconds: 2), () {
              homeBloc.getNotes();
            });

            /// Save Note Content if notEmpty
            onNoteCloses(param, refresh);
          });
        },
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Error message UI
  Widget getErrorView(String message) {
    return SizedBox(
      height: Utils.deviceHeight,
      width: Utils.deviceWidth,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🤕',
              style: TextStyle(color: animation2.value, fontSize: 70),
            ),
            Text(
              message,
              style: TextStyle(color: animation2.value, fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog for Add/Edit Note
  void showAddNoteDialog({required ClickCallback onCancel}) {
    var data2, param2, refresh2;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Theme(
            data:
                ThemeData(iconTheme: const IconThemeData(color: Colors.white)),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                width: device!.deviceWidth / 2,
                height: device!.deviceHeight * 0.60,
                child: NoteDetail(
                  onCancel: (data, param, refresh) {
                    param2 = param;
                    refresh2 = refresh;
                    data2 = data;
                    if ((param == null || param == NoteActions.DELETE) &&
                        mounted) Navigator.of(context).pop();
                    /*   if (param != null && mounted)

                  else if (!refresh2 && mounted) Navigator.pop(this.context);*/
                  },
                ),
              ),
            ),
          );
        }).whenComplete(() {
      // onNoteCloses(param2, refresh2);
      onCancel(data2, param2, refresh2);
    });
  }

  /// On Note Closed with Back Press or Delete
  void onNoteCloses(param, refresh) {
    if (param == NoteActions.ADD) {
      homeBloc.appendList();
    } else if (param == NoteActions.DELETE) {
      homeBloc.deleteNote();
    }
  }
}
