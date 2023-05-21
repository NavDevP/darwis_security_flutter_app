# Darwis Security
Malware security project with hash scanning, spam links scanning and otp alert for user on call.

# Api Configuration

1. Navigate to `lib/const/api_urls.dart`, here you will see multiple routes for api calls
2. Update constant `api` in the file by putting the api domain. For Ex: `http://0.0.0.0:3000/`
3. Now the api is setup and ready to run.


# Creating a Flutter APK in Android Studio

This guide will walk you through the steps to create a Flutter APK (Android Package) using Android Studio. An APK is the file format used to distribute and install applications on Android devices.

## Prerequisites (**Required**)

- Android Studio installed on your machine.
- Flutter SDK installed and configured.

## Steps

1. Open Android Studio and ensure that your Flutter project is loaded.
2. Select the target device you want to build the APK for by clicking on the target device drop-down menu in the toolbar. Choose either a physical device connected via USB or an emulator.

3. In the Android Studio toolbar, click on **Build** and then select **Flutter** followed by **Flutter Build APK**. This will start the build process.
4. Android Studio will generate the APK file and save it to the `build/app/outputs/flutter-apk` directory within your project folder. The APK file will have a name like `app-release.apk`.
5. Once the build process is complete, you can locate the generated APK file in the specified directory.

Congratulations! You have successfully created a Flutter APK using Android Studio.

## Additional Notes

- To create a release-ready APK for distribution, you should consider signing it with a keystore. Refer to the Flutter documentation for more information on signing and publishing apps.


For more information and advanced options, refer to the official Flutter documentation: [Building and deploying Flutter apps](https://flutter.dev/docs/deployment/android).