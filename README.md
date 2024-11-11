# conversation_bubbles

[Android Conversation Bubbles](https://developer.android.com/develop/ui/views/notifications/bubbles) 
are floating contact points of applications. Bubbles are draggable on 
any part of the screen, can expand into an app's view and can be 
collapsed backed. They are available in Android 11+ devices.

![](./bubbles-demo.gif)

Bubbles are tightly coupled with the notification system. You create one
by adding a bubble metadata to a notification among other conversation
requirements by android.

This project is a simple Flutter plugin that allows you to create
conversation bubbles in your Flutter app. It exposes a `show` method
that takes necessary notification details alongside the "Person" data
required for the bubble to be shown.

You should ensure that your app has the necessary notification permissions
for bubbles to work.
