# conversation_bubbles

Enables you to show Android Conversation Bubbles from your Flutter app.

[Android Conversation Bubbles](https://developer.android.com/develop/ui/views/notifications/bubbles)
are floating contact points of applications. Bubbles are draggable on
any part of the screen, can expand into an app's view, and can be
collapsed back. Many bubbles from different apps can be displayed at the
same time. They all display over other apps. Bubbles are available on devices running
Android 11+.

![Demo of Android Conversation Bubbles](./bubbles-demo.gif)

## Table of Contents

- [More About Conversation Bubbles](#more-about-conversation-bubbles)
- [Android Requirements](#android-requirements)
  - [1. Notification](#1-notification)
  - [2. An Activity for the Bubble](#2-an-activity-for-the-bubble)
  - [3. BubbleMetadata, Person, and Shortcut](#3-bubblemetadata-person-and-shortcut)
- [How To Use](#how-to-use)
  - [1. Android Setup](#1-android-setup)
    - [a. Add Notification Permission to AndroidManifest.xml file](#a-add-notification-permission-to-androidmanifestxml-file)
    - [b. Define a callback scheme/Uri for your app](#b-define-a-callback-schemeuri-for-your-app)
    - [c. Create an Activity for the Bubble](#c-create-an-activity-for-the-bubble)
    - [d. Add the Bubble Activity to the AndroidManifest.xml file](#d-add-the-bubble-activity-to-the-androidmanifestxml-file)
  - [2. Flutter Setup](#2-flutter-setup)
    - [a. Install this Package](#a-install-this-package)
    - [b. Handle Notification Permissions](#b-handle-notification-permissions)
    - [c. Initialize the Plugin](#c-initialize-the-plugin)
    - [d. Show Bubbles](#d-show-bubbles)
    - [e. Handle UI changes for App Open `intentUri`](#e-handle-ui-changes-for-app-open-intenturi)
    - [f. Handle `isInBubble` User Experience](#f-handle-isinbubble-user-experience)
- [Example](#example)

## More About Conversation Bubbles

To understand how to use this package, you need to first understand how the
Android OS expects you to integrate bubbles in Android apps.

Bubbles are integrated into the Android OS as part of the notification system.
A bubble is attached to notifications. In Kotlin, when you want to show a bubble, you
show a notification as usual but then you have to add bubble metadata and
fulfill [some conversation requirements](https://developer.android.com/develop/ui/views/notifications/bubbles#bubbles-appear)
set by Android. This will now make your notification to show in the system app
bar with the option to bubble.

When the user bubbles a notification, the system will call a dedicated activity
that you've set up to handle the bubble. Android expects us to handle our app's UI and
UX differences for users when they access our apps from within bubbles.

## Android Requirements

This package has handled a good amount of the Kotlin code you should write to
show bubbles. To use this package to show bubbles, you will make few changes to the
Android native side of your project together with some integrating Flutter code.

Before we delve into how you to integrate this package, let us look at the
technical Kotlin requirements for bubbles. Not for you to redo them, but for you
to understand what the package expects you to provide.

Following are the Java/Kotlin requirements for bubbles:

### 1. Notification

It all starts with a notification. You provide notification data as usual.
Such data include your `appIcon` (e.g. `@mipmap/ic_launcher`) and
`NotificationChannel` details (id, name, and optional description).
NotificationChannel is like notification groups for your app in Android Settings.

### 2. An Activity for the Bubble

When a user taps on a bubble, the system expands the bubble and show an
[activity](https://developer.android.com/guide/components/activities/intro-activities)
that you had set up to handle that bubble. Android requires that this activity should
be set as `embedded` and `resizeable` in the AndroidManifest.xml file. We will see how
to do this later.

### 3. BubbleMetadata, Person, and Shortcut.

These are classes in native Android that we attach to the notification to fulfill
the conversation requirements set by Android.

BubbleMetadata sets the bubble's height, the bubble's icon (user profile picture), whether the
bubble should not notify the system, the data the system should provide to your app if
in case the user taps on it (`intentUri`), etc.

`Person` class references the context of a bubble. It tells who the user is
chatting with in a conversation. The Android system provides this class.
`Person` contains the name, icon, contacts, etc. You usually will use the icon
attached to the provided `person` as the icon for the bubble. Android uses the `person`'s
name as the bubble's title.

`Dynamic Shortcuts` are also required to make our notifications to bubble. The
shortcuts are contextual links that show when users long-press on your app in
the app menu. Bubbles have to be linked to a shortcut.

As mentioned earlier, this `conversation_bubbles` flutter package handles these
native Android integrations. To use the package, you only provide the minimum required
to show a bubble.

## How To Use

To integrate this package, you will have to make changes to your project in
both the Android Native and the Flutter sides.

### 1. Android Setup

#### a. Add Notification Permission to AndroidManifest.xml file

In your project, go to `android/app/src/main/AndroidManifest.xml`.

After the opening `manifest` XML tag and before the opening
`application` XML tag, paste the following:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

You should have something like this:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <application ...>
```

That's generally the place where you put permissions your app uses. So if you
have any other permission declaration, it will be there too.

#### b. Define a callback scheme/Uri for your app

When a user taps a notification, Android opens your app.

Most, if not all the time, you need to know which exact notification the user
tapped. Because when your app is finally opened, you need to show your apps's
UI in context of the tapped notification.

For example, let's say you show chat notifications from different persons
(e.g. Cat, Dog, Sheep, etc.) When a user taps the notification of a particular
person (let's say Cat), you want to open into the Chat Screen of that particular
person.

For Android to tell you whose notification was opened, you need to have had
provided data to that notification when you initially showed it. For
conversations and bubbles, an `intentUri` suffices.

When showing the notification, you can set a [URI](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
in the [Intent](https://developer.android.com/guide/components/intents-filters)
that Android will use to open your app when the user taps the notification.
In turn, when Android eventually opens your app, it will provide you with
this `intent` alongside the originally provided `uri`.

Conventionally, you choose the host or domain name of the URI based on your
company's or app's name. You also have to set this URI in the AndroidManifest.xml
file so that the Android system can appropriately call your app on tap of
an involved bubble or notification.

This Flutter `conversation_bubbles` package has handled the process of adding the
`intentUri` to the notification data in the Kotlin side. You will provide the
`intentUri` to the `show` method when the time comes.

However, you have to add an `intent-filter` XML tag for your app's URI in the
MainActivity's `activity` tag in AndroidManifest file. This will allow the
Android system to appropriately open your app based on the retrieved `intentUri`.

Go to MainActivity's `activity` XML tag in AndroidManifest.xml file.

There should already be an existing `intent-filter` XML tag for
MainActivity with action as `MAIN` and category as `LAUNCHER` within the
`activity` tag.

This time, you will add a new `intent-filter` whose action will be `VIEW` and
category `BROWSABLE`. Next to the already declared `intent-filter` for
MAIN/LAUNCHER, add the following `intent-filter`.

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:host="example.com"
        android:pathPattern="/chat/*"
        android:scheme="https" />
</intent-filter>
```

Replace example.com with your chosen domain name. Replace the value of the
`android:pathPattern` attribute with what you intend using for the screen that
you will show in bubbles. The `/chat/*` can work for you if you are building
a chat-related application.

You should have something like this:

```xml
<activity
    android:name=".MainActivity"
    ...>
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:host="example.com"
            android:pathPattern="/chat/*"
            android:scheme="https" />
    </intent-filter>
</activity>
```

You could declare more `intent-filter`s based on your app's needs. The above
is simply the minimum needed to show bubbles.

#### c. Create an Activity for the Bubble

In your Flutter project, locate where your `MainActivity.kt` is found and
create a `BubbleActivity.kt` file along with (or in the same directory as)
`MainActivity.kt`. The file name "BubbleActivity" is conventional. You
could have different file names or multiple activities for bubbles for
various purposes.

Paste the following contents into this file.

```kt
package com.example // TODO: Set your package name

import io.flutter.embedding.android.FlutterActivity

class BubbleActivity: FlutterActivity()
```

Change the package name to what your app uses and delete the TODO.

#### d. Add the Bubble Activity to the AndroidManifest.xml file

In Android apps, all declared activity classes must be specified in the
`AndroidManifest.xml` file.

In this step, you will add the just created BubbleActivity to the
`AndroidManifest.xml` file. In addition, you will specify the `VIEW/BROWSABLE
intent-filter` for this BubbleActivity, just as with did with MainActivity
in step 1b above.

Go to `android/app/src/main/AndroidManifest.xml`.
After the closing `activity` XML tag of `MainActivity` and before
the closing `application` XML tag, paste the following code:

```xml
<activity
    android:name=".BubbleActivity"
    android:exported="true"
    android:documentLaunchMode="always"
    android:allowEmbedded="true"
    android:resizeableActivity="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:host="example.com"
            android:pathPattern="/chat/*"
            android:scheme="https" />
    </intent-filter>
</activity>
```

### 2. Flutter Setup

This section guides through how to actually use this Flutter `conversation_bubbles`
package to show bubbles in your Flutter app.

It assumes that you are good in Flutter and that you have a working Flutter project
or at least you've handle state management or similar concepts in your Flutter codebase.

#### a. Handle Notification Permissions

In your Flutter project, you will need to be sure that the user has granted
your application the permissions to show notifications before you proceed to
use this project to show bubbles.

You can use the [`permission_handler`](https://pub.dev/packages/permission_handler)
package to request for notification permissions.

If you don't do this, the bubbles will not show.

#### b. Install this Package

Add this package to your `pubspec.yaml` file. But this time, you are using the git
method as this package is not yet published to pub.dev.

Add the following to the `dependencies` section of your `pubspec.yaml` file.

```yaml
conversation_bubbles:
  git:
    url: https://github.com/keepdeploying/conversation_bubbles
```

Run `flutter pub get` to install the package.

#### c. Initialize the Plugin

To initialize this plugin, call the `.init` method with your `appIcon` and the
fully qualified class name of the BubbleActivity you created in step 1c above.

The `appIcon` should is what you already use in your Android app. It shows in
notifications. It is usually in the form of `@mipmap/ic_launcher`.

The fully qualified class name of the BubbleActivity comes with the package name
you had set in step 1c above. For example, if your package name is `com.example`,
the fully qualified class name of the BubbleActivity will be
`com.example.BubbleActivity`.

```dart
import 'package:conversation_bubbles/conversation_bubbles.dart';

final _conversationBubblesPlugin = ConversationBubbles();

_conversationBubblesPlugin.init(
  appIcon: '@mipmap/ic_launcher',
  fqBubbleActivity: 'com.example.BubbleActivity',
);
```

#### d. Show Bubbles

To show bubbles, call the `.show` method of the plugin. The method signature
for `.show` is as follows:

```dart
Future<void> show({
  required int notificationId,
  required String body,
  required String contentUri,
  required NotificationChannel channel,
  required Person person,
  bool? isFromUser,
  bool? shouldMinimize,
  String? appIcon,
  String? fqBubbleActivity,
});
```

| Parameter          | Description                                                                                                                                                                                                                                                                          |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `notificationId`   | The unique identifier for the notification. You should use the same `notificationId` when you want Android to show a notification in an already existing bubble.                                                                                                                     |
| `body`             | The message you want to show in the notification.                                                                                                                                                                                                                                    |
| `contentUri`       | The `intentUri` that you want Android to provide to your app when the user taps the notification. This is the constructed string equivalent of the URI parts you had set in the AndroidManifest.xml file.                                                                            |
| `channel`          | The notification channel you want to use. Remember that bubbles are attached to notifications. Provide the channel that will be used for the notification. This package exposes a `NotificationChannel` class.                                                                       |
| `person`           | The context of the bubble. It tells who the user is chatting with in a conversation. This is compulsory for Bubbles to show. This package exposes a `Person` class. The bubble's icon and name will be that of `person`.                                                             |
| `isFromUser`       | A boolean that tells if the message is from the user. If true, the bubble will simply show without triggering a notification. This is useful when you want a "Show Bubble" button in your app.                                                                                       |
| `shouldMinimize`   | A boolean that tells if your app should minimize when the bubble gets expanded. This is useful when `isFromUser` is true. So that if the user clicked on some "Show Bubble" button in your app, your app will minimize and the bubble will show and expand.                          |
| `appIcon`          | Same as the `appIcon` you provided when initializing the plugin. If you provide this, it will override the `appIcon` you provided when initializing the plugin; for that particular bubble's notification. Useful when you want to use a different appIcon.                          |
| `fqBubbleActivity` | Same as the `fqBubbleActivity` you provided when initializing the plugin. If you provide this, it will override the `fqBubbleActivity` you provided when initializing the plugin; for that particular bubble's notification. Useful when you want to use a different BubbleActivity. |

Here is an example of how to show a bubble. We will assume we are in Chat
application. We will show a bubble for a chat message from a person named Cat.
The icon for the bubble will be a picture of a cat that we have in our assets.
This package expects the icon to be in bytes.

```dart
final id = 1;
final bytesData = await rootBundle.load('assets/Cat.jpg');
final iconBytes = bytesData.buffer.asUint8List();

await _conversationBubblesPlugin.show(
  notificationId: id,
  body: 'Meow',
  contentUri: 'https://example.com/chat/$id',
  channel: const NotificationChannel(id: 'chat', name: 'Chat'),
  person: Person(id: '$id', name: 'Cat', icon: iconBytes),
);
```

#### e. Handle UI changes for App Open `intentUri`

Use the `getIntentUri` method of the plugin to get the `intentUri` that Android
provided to your app when the user tapped on a bubble. The method returns a
`Future<String?>`. You can parse the results and extract the parts you need.

```dart
final intentUri = await _conversationBubblesPlugin.getIntentUri();
if (intentUri != null) {
  final uri = Uri.tryParse(intentUri);
  if (uri != null) {
    final id = int.tryParse(uri.pathSegments.last);
    if (id != null) {
      // Show the chat screen for the user with id
    }
  }
}
```

This `intentUri` getter is useful when the user tapped on the notification
without opening the bubble. Android will open your app in full (and not in
a bubble) and will still provide the `intentUri` to your application. You
should just show the necessary UI. That's why handling `intentUri` on launch
of the Flutter app is separate from handling `isInBubble`.

#### f. Handle `isInBubble` User Experience

When the user taps on a bubble, the system will open your app. You have to
handle the UI changes that you want to make when the user opens your app from
a bubble.

This step is extremely important. You want bubbles to be localised to a given
screen in your app. You also want to prevent the user from accessing some
screens when they are in bubbles.

Use the `isInBubble` method of the plugin to know if the user is
opening your app from a bubble. The method returns a `Future<bool>`.

```dart
final isInBubble = await _conversationBubblesPlugin.isInBubble();

if (isInBubble) {
  // Handle UI changes for bubbles
}
```

## Example

You can find a complete example of how to use this package in the `example` directory.

The example is a simple chat application named "People". It is a chat with
animals that have different ways of replying you after 5 seconds.
It is built the same way as the ["People"](https://github.com/android/user-interface-samples/tree/main/People)
app that the Android Docs used to demonstrate bubbles.

The example uses [Isar](https://pub.dev/packages/isar) for data persistence.
It also keeps [singleton services](./example/lib/services/) as an abstraction
layer for the plugin.
