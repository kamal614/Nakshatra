# Nakshatra

Nakshatra is a demo astrology consultation app built with Flutter for a technical interview assignment. It showcases the consumer journey, from exploring astrologers and creating a birth profile to trying simulated chat, voice and video consultations. Open the Profile tab to try registration and login.

## Run

With Flutter 3.29 or newer installed, run these commands in this folder.

```sh
flutter pub get
flutter run -d chrome
```

Use `flutter devices` and select an Android emulator or iOS simulator to preview the mobile layouts on a configured machine.

## Demo flows

- Enter any 10-digit demo mobile number and use OTP `123456`.
- Open an online astrologer's profile and request a chat, voice or video consultation.
- Choose **Simulate disconnection** in the session menu to preview reconnection.
- End a consultation and open **Sessions** to see its duration and status.

All account, directory and session behavior is simulated on the device. Edits and session history reset when the app restarts.
