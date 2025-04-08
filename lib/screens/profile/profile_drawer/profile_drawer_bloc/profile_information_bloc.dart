import 'package:flutter_sample_apps/middlewares/repositories/connection_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/user.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInformationBloc
    extends Bloc<ProfileInformationEvent, ProfileInformationState> {
  ProfileInformationBloc() : super(ProfileInformationInitialState());

  final imagePicker = ImagePicker();
  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  Map<String, dynamic> userEditFields = {};
  final ConnectionRepository _connectionRepository = ConnectionRepository();

  static Driver? _driver;
  Driver? get driver => _driver;

  @override
  Stream<ProfileInformationState> mapEventToState(
      ProfileInformationEvent event,) async* {
    if (event is GetProfileInformationEvent) {
      final isDeviceConnected = await _connectionRepository.hasConnection();
      if (isDeviceConnected) {
        if (_driver == null) {
          yield* getMainProfileInformationEventToState(event);
        } else {
          yield ProfileInformationLoaded();
          yield ProfileInformationInitialState();
        }
      }
      return;
    }
    if (event is UserEditEvent) {
      yield* editProfileInformationEventToState(event);
    }
    if (event is DriverLogOutEvent) {
      yield* driverLogOutEventToState(event);
    }

    if (event is DriverPhoneNumberChangedEvent) {
      yield* driverPhoneNumberChangedEvent(event);
    }
  }

  Stream<ProfileInformationState> driverLogOutEventToState(
      DriverLogOutEvent event,) async* {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
    await preferences.remove('phone');
    await preferences.remove('order_id');
    _driver = null;

    yield DriverLoggedOutState();
    yield ProfileInformationInitialState();
  }

  Stream<ProfileInformationState> getMainProfileInformationEventToState(
      GetProfileInformationEvent event,) async* {
    yield LoadingState();
    try {
      final queryResult = await _graphQlRepository.getDriverInfo();

      final data = queryResult.data;
      if (data != null) {
        _driver = Driver.fromMap(data['thisDriver'] as Map<String,dynamic>);
      }
      final driver = _driver;
      if (driver != null) {
        final driverAttachment = driver.attachment;
        if (driverAttachment != null) {
          final driverAttachmentDownloadLinks = driverAttachment.downloadLink;

          if (driverAttachmentDownloadLinks != null) {
            var driverAttachmentDownloadLink = '';
            for (final map in driverAttachmentDownloadLinks) {
              final key = map.keys.first;
              if (key == 'profileImage') {
                driverAttachmentDownloadLink = map[key] ?? '';
              }
            }

            final imageData = await NetworkAssetBundle(
                    Uri.parse(driverAttachmentDownloadLink),)
                .load('');
            driver.profileImageBytes = imageData.buffer.asUint8List();
          }
        }
      }
      yield ProfileInformationLoaded();
      yield ProfileInformationInitialState();
    } catch (e) {
      yield ProfileInformationLoadErrorState(errorMessage: e.toString());
    }
  }

  Stream<ProfileInformationState> driverPhoneNumberChangedEvent(
      DriverPhoneNumberChangedEvent event,) async* {
    yield LoadingState();
    final driver = _driver;
    if (event.changedPhoneNumber != '' && driver != null) {
      driver.phone = event.changedPhoneNumber;
    }

    yield ProfileInformationLoaded();
    yield ProfileInformationInitialState();
  }

  Stream<ProfileInformationState> editProfileInformationEventToState(
      UserEditEvent event,) async* {
    yield LoadingState();

    if (event.user.firstName != event.userBeforeEditing.firstName) {
      userEditFields['firstName'] = '"${event.user.firstName}"';
    }
    if (event.user.lastName != event.userBeforeEditing.lastName) {
      userEditFields['lastName'] = '"${event.user.lastName}"';
    }
    final birthdayISOString = event.user.birthDate;

    if (birthdayISOString != event.userBeforeEditing.birthDate &&
        birthdayISOString != null) {
      userEditFields['birthDate'] = '"$birthdayISOString"';
    }
    if (event.user.email != event.userBeforeEditing.email) {
      userEditFields['email'] = '"${event.user.email}"';
    }

    if (userEditFields.isNotEmpty) {
      try {
        final queryResult = await _graphQlRepository.editUserProfile(
            userEditedInfoMap: userEditFields,);

        final data = queryResult.data;
        if (data != null) {
          final user = User.fromJson(data['editUserProfile'] as Map<String,dynamic>);
          yield UserEditSuccessState(editedUser: user);
        }

        userEditFields = {};
      } catch (e) {
        yield UserEditErrorState();
      }
    }

    yield ProfileInformationInitialState();
  }
}
