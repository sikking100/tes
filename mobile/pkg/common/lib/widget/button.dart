import 'package:flutter/material.dart';

class Buttons {
  static Widget primary(String title, {Key? key, void Function()? onPressed, bool? isLoading}) => Primary(
        title: title,
        onPressed: onPressed,
        key: key,
        isLoading: isLoading,
      );
  static Widget secondary(String title, {Key? key, void Function()? onPressed, bool? isLoading}) => Secondary(
        title: title,
        onPressed: onPressed,
        key: key,
        isLoading: isLoading,
      );
}

class Primary extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  final bool? isLoading;
  const Primary({super.key, required this.title, this.onPressed, this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      onPressed: isLoading == true ? null : onPressed,
      child: isLoading == true ? const FittedBox(child: CircularProgressIndicator.adaptive()) : Text(title),
    );
  }
}

class Secondary extends StatelessWidget {
  final String title;
  final void Function()? onPressed;
  final bool? isLoading;

  const Secondary({super.key, required this.title, this.onPressed, this.isLoading});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading == true ? null : onPressed,
      style: OutlinedButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: isLoading == true ? const BtnLoading() : Text(title),
    );
  }
}

class BtnLoading extends StatelessWidget {
  const BtnLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
