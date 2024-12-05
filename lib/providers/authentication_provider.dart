import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/utilities/constants.dart';
import 'package:flutter_chat_pro/utilities/global_method.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;
  int? _resendToken;
  Timer? _timer;
  int _secondsRemaning = 60;
  File? _finalFileImage;
  String _userImage = '';

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;
  int? get resendToken => _resendToken;
  int get secondsRemaning => _secondsRemaning;
  File? get finalFileImage => _finalFileImage;
  String get userImage => _userImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void setfinalFileImage(File? file) {
    _finalFileImage = file;
    notifyListeners();
  }

  void selectImage(
      {required bool fromCamera,
      required Function() onSuccess,
      required Function(String) onError}) async {
    _finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) => onError(message),
    );
    if (finalFileImage == null) return;
    // crop image
    await cropImage(
      filePath: _finalFileImage!.path,
      onSuccess: onSuccess,
    );

    onSuccess();
  }

  Future<void> cropImage(
      {required String filePath, required Function() onSuccess}) async {
    setfinalFileImage(File(filePath));
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
      compressQuality: 90,
    );

    if (croppedFile != null) {
      setfinalFileImage(File(croppedFile.path));
      onSuccess();
    }
  }

  void showBottomSheet({
    required BuildContext context,
    Function()? onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(
                  fromCamera: true,
                  onSuccess: () {
                    onSuccess!();
                    // pop bottom sheet
                    Navigator.pop(context);
                  },
                  onError: (String error) {
                    //show error
                    showSnackBar(context, error);
                  },
                );
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(
                  fromCamera: false,
                  onSuccess: () {
                    // pop bottom sheet
                    Navigator.pop(context);
                    onSuccess!();
                  },
                  onError: (String error) {
                    //show error
                    showSnackBar(context, error);
                  },
                );
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  // chech authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      // get user data from firestore
      await getUserDataFromFireStore();

      // save user data to shared preferences
      await saveUserDataToSharedPreferences();

      notifyListeners();

      isSignedIn = true;
    } else {
      isSignedIn = false;
    }

    return isSignedIn;
  }

  // chech if user exists
  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  // update user status
  Future<void> updateUserStatus({required bool value}) async {
    await _firestore
        .collection(Constants.users)
        .doc(_auth.currentUser!.uid)
        .update({Constants.isOnline: value});
  }

  // get user data from firestore
  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  // save user data to shared preferences
  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  // get data from shared preferences
  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  // sign in with phone number
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) async {
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        _isSuccessful = false;
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        _resendToken = resendToken;
        _isLoading = false;
        _secondsRemaning = 60;
        startTimer();
        notifyListeners();
        // navigate to otp screen
        Navigator.of(context).pushNamed(
          Constants.otpScreen,
          arguments: {
            Constants.verificationId: verificationId,
            Constants.phoneNumber: phoneNumber,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 120),
      forceResendingToken: resendToken,
    );
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaning > 0) {
        _secondsRemaning--;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  //resend code
  Future<void> resendCode({
    required BuildContext context,
    required phone,
  }) async {
    if (_secondsRemaning == 0 && _resendToken != null) {
      _isLoading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential).then((value) async {
            _uid = value.user!.uid;
            _phoneNumber = value.user!.phoneNumber;
            _isSuccessful = true;
            _isLoading = false;
            notifyListeners();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSuccessful = false;
          _isLoading = false;
          notifyListeners();
          showSnackBar(context, e.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          _resendToken = resendToken;
          _isLoading = false;
          notifyListeners();
          showSnackBar(context, 'Code resent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 120),
        forceResendingToken: resendToken,
      );
    } else {
      showSnackBar(
          context, 'Please wait $_secondsRemaning seconds to resend code');
    }
  }

  // verify otp code
  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError((e) {
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    });
  }

  // save user data to firestore
  void saveUserDataToFireStore({
    required UserModel userModel,
    // required File? fileImage,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_finalFileImage != null) {
        // upload image to storage
        String imageUrl = await storeFileToStorage(
            file: _finalFileImage!,
            reference: '${Constants.userImages}/${userModel.uid}');

        userModel.image = imageUrl;
      }

      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;
      _uid = userModel.uid;

      // save user data to firestore
      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());

      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  // get user stream
  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

  // get all users stream
  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  // send friend request
  Future<void> sendFriendRequest({
    required String friendID,
  }) async {
    try {
      // add our uid to friends request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });

      // add friend uid to our friend requests sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayUnion([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }

  Future<void> cancelFriendRequest({required String friendID}) async {
    try {
      // remove our uid from friends request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });

      // remove friend uid from our friend requests sent list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e.toString());
    }
  }

  Future<void> acceptFriendRequest({required String friendID}) async {
    // add our uid to friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([_uid]),
    });

    // add friend uid to our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([friendID]),
    });

    // remove our uid from friends request list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
    });

    // remove friend uid from our friend requests sent list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }

  // remove friend
  Future<void> removeFriend({required String friendID}) async {
    // remove our uid from friends list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([_uid]),
    });

    // remove friend uid from our friends list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }

  // get a list of friends
  Future<List<UserModel>> getFriendsList(
    String uid,
    List<String> groupMembersUIDs,
  ) async {
    List<UserModel> friendsList = [];

    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(uid).get();

    List<dynamic> friendsUIDs = documentSnapshot.get(Constants.friendsUIDs);

    for (String friendUID in friendsUIDs) {
      // if groupMembersUIDs list is not empty and contains the friendUID we skip this friend
      if (groupMembersUIDs.isNotEmpty && groupMembersUIDs.contains(friendUID)) {
        continue;
      }
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(Constants.users).doc(friendUID).get();
      UserModel friend =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      friendsList.add(friend);
    }

    return friendsList;
  }

  // get a list of friend requests
  Future<List<UserModel>> getFriendRequestsList({
    required String uid,
    required String groupId,
  }) async {
    List<UserModel> friendRequestsList = [];

    if (groupId.isNotEmpty) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(Constants.groups).doc(groupId).get();

      List<dynamic> requestsUIDs =
          documentSnapshot.get(Constants.awaitingApprovalUIDs);

      for (String friendRequestUID in requestsUIDs) {
        DocumentSnapshot documentSnapshot = await _firestore
            .collection(Constants.users)
            .doc(friendRequestUID)
            .get();
        UserModel friendRequest =
            UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
        friendRequestsList.add(friendRequest);
      }

      return friendRequestsList;
    }

    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(uid).get();

    List<dynamic> friendRequestsUIDs =
        documentSnapshot.get(Constants.friendRequestsUIDs);

    for (String friendRequestUID in friendRequestsUIDs) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(friendRequestUID)
          .get();
      UserModel friendRequest =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      friendRequestsList.add(friendRequest);
    }

    return friendRequestsList;
  }

  //update image
  Future<String> updateImage({
    required String id,
    required bool isGroup,
  }) async {
    // check if flie is not null
    if (_finalFileImage == null) {
      return 'Error';
    }
    ;
    _isLoading = true;
    try {
      //get the image path
      final String filePath = isGroup
          ? '${Constants.groupImages}/${id}'
          : '${Constants.userImages}/${id}';
      final String imageUrl = await storeFileToStorage(
        file: _finalFileImage!,
        reference: filePath,
      );
      if (isGroup) {
        await _updateGroupImage(id, imageUrl);

        _finalFileImage = null;
        _isLoading = false;
        notifyListeners();
        return imageUrl;
      } else {
        await _updateUserImage(imageUrl);
        _userModel!.image = imageUrl;
        _finalFileImage = null;
        _isLoading = false;
        await saveUserDataToSharedPreferences();
        notifyListeners();
        return imageUrl;
      }
    } catch (e) {
      print(e);
      _isLoading = false;
      notifyListeners();
      return "Error";
    }
  }

//update group image
  Future<void> _updateGroupImage(String id, String imageUrl) async {
    await _firestore.collection(Constants.groups).doc(id).update({
      Constants.groupImage: imageUrl,
    });
  }

  //update user image
  Future<void> _updateUserImage(String imageUrl) async {
    await _firestore.collection(Constants.users).doc(_userModel!.uid).update({
      Constants.image: imageUrl,
    });
  }

  String _newName = '';
  String _newDesc = '';

//set name
  void setName(String value) {
    _newName = value;
    notifyListeners();
  }

  //set desc
  void setDesc(String value) {
    _newDesc = value;
    notifyListeners();
  }

  //update name
  Future<String> updateName({
    required String oldName,
    required String id,
    required bool isGroup,
  }) async {
    if (_newName.isEmpty || _newName.length < 3 || _newName == oldName) {
      return 'Invalid Name';
    }
    if (isGroup) {
      await _updateGroupName(id, _newName);
      final nameToReturn = _newName;
      _newName = '';
      notifyListeners();
      return nameToReturn;
    } else {
      await _updateUserName(id, _newName);
      _userModel!.name = _newName;

      await saveUserDataToSharedPreferences();
      _newName = '';
      notifyListeners();
      return _userModel!.name;
    }
  }

  Future<String> updateStatus({
    required String oldDesc,
    required String id,
    required bool isGroup,
  }) async {
    if (_newDesc.isEmpty || _newDesc.length < 3 || _newDesc == oldDesc) {
      return 'Invalid Description';
    }

    // Nếu là nhóm
    if (isGroup) {
      await _updateGroupDesc(id, _newDesc);
      final descToReturn = _newDesc;
      _newDesc = '';
      notifyListeners();
      return descToReturn;
    } else {
      await _updateAboutMe(id, _newDesc);

      // Cập nhật mô hình người dùng cục bộ
      if (_userModel != null) {
        _userModel!.aboutMe = _newDesc;
      } else {}

      await saveUserDataToSharedPreferences();
      _newDesc = '';
      notifyListeners();
      return _userModel!.aboutMe;
    }
  }

  //update group name
  Future<void> _updateGroupName(String id, String newName) async {
    await _firestore.collection(Constants.groups).doc(id).update({
      Constants.groupName: newName,
    });
  }

  //update user name
  Future<void> _updateUserName(String id, String newName) async {
    await _firestore.collection(Constants.users).doc(id).update({
      Constants.name: newName,
    });
  }

  //update group desc
  Future<void> _updateGroupDesc(String id, String newDesc) async {
    await _firestore.collection(Constants.groups).doc(id).update({
      Constants.groupDescription: newDesc,
    });
  }

  //update user desc
  Future<void> _updateAboutMe(String id, String newDesc) async {
    await _firestore.collection(Constants.users).doc(id).update({
      Constants.aboutMe: newDesc,
    });
  }

  // generate FCM token
  Future<void> generateNewToken() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.token: token,
    });
  }

  Future logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }
}
