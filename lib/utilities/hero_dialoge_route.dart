import 'package:flutter/material.dart';

class HeroDialogeRoute<T> extends PageRoute<T> {
  HeroDialogeRoute({
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
  })  : _builder = builder,
        super(fullscreenDialog: fullscreenDialog);
  final WidgetBuilder _builder;
  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
  @override
  bool get maintainState => true;
  @override
  Color get barrierColor => Colors.black54;
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String? get barrierLabel => "Popup dialog open";
}
