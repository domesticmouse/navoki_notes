import 'package:flutter/material.dart';
import 'package:navokinotes/model/note_model.dart';
import 'package:navokinotes/screen/home_page.dart';
import 'package:navokinotes/services/shared_preferences_services.dart';
import 'package:navokinotes/utils/api.dart' as api;
import 'package:navokinotes/utils/local_data_storage.dart';
import 'package:navokinotes/utils/utils.dart';

import '../utils/app_constants.dart';

class LoginBloc extends ChangeNotifier {
  List<NoteModel> notesList = List.empty(growable: true);
  BuildContext? context;
  LocalDataStorage localDataStorage = LocalDataStorage();
  bool isLoading = false;
  bool isAnimating = true;

  void resetPassword(String email) {
    api.resetPassword(email).then((value) {
      Utils.showToast('An email link is sent to your email');
    }).catchError((onError) {});
  }

  void showLoginForm() {
    isAnimating = false;
    notifyListeners();
  }

  Future<String?> getToken() async {
    //  print( 'getToken1111');
    //  await localDataStorage.clear();
    //  Utils.loginToken = await localDataStorage.getToken();
    Utils.loginToken =
        SharedPreferencesService.instance.getStringData(AppConstants.API_TOKEN);
    print('getToken');
    print(Utils.loginToken);
    Utils.userId =
        SharedPreferencesService.instance.getStringData(AppConstants.LOCAL_ID);
    print(Utils.userId);
    if (Utils.loginToken != null) {
      bool? isValid = await api.signInWithToken(Utils.loginToken!);
      if (isValid) {
        openHomePage(Utils.loginToken!);
      } else {
        showLoginForm();
        return null;
      }
    }

    return Utils.loginToken;
    // return null;
  }

  signIn(String email, String password) {
    isLoading = true;
    notifyListeners();
    api.signInUser(email, password).then((token) {
      isLoading = false;
      SharedPreferencesService.instance
          .saveStringData(AppConstants.API_TOKEN, token);
      //   localDataStorage.saveUserId(Utils.userId!);
      SharedPreferencesService.instance
          .saveStringData(AppConstants.LOCAL_ID, Utils.userId!);
      api.addLoginTime();
      notifyListeners();
      /*  Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage(token)));*/

      openHomePage(token);
    }).catchError((onError) {
      isLoading = false;
      Utils.showToast(Utils.getErrorMessage(onError));
      notifyListeners();
    });
  }

  void openHomePage(String token) {
    Navigator.pushReplacement(
      context!,
      MaterialPageRoute(builder: (context) => HomePage(token)),
    );
  }

  void register(String email, String password) {
    isLoading = true;
    notifyListeners();
    api.registerUser(email, password).then((token) {
      isLoading = false;
      SharedPreferencesService.instance
          .saveStringData(AppConstants.API_TOKEN, token);
      //   localDataStorage.saveToken(token);
      //  localDataStorage.saveUserId(Utils.userId!);
      SharedPreferencesService.instance
          .saveStringData(AppConstants.LOCAL_ID, Utils.userId!);
      notifyListeners();

      api.addLoginTime();

      openHomePage(token);
    }).catchError((onError) {
      isLoading = false;
      Utils.showToast(Utils.getErrorMessage(onError));
      notifyListeners();
    });
  }
}
