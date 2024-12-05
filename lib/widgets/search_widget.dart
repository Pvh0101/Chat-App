import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String placeholder;

  const SearchWidget({
    super.key,
    required this.onChanged,
    this.placeholder = 'Search',
  });

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: CupertinoSearchTextField(
        style: TextStyle(
            fontSize: 16, color: Theme.of(context).textTheme.bodyMedium!.color),
        placeholder: placeholder,
        onChanged: onChanged,
        focusNode: focusNode,
        onSubmitted: (value) {
          focusNode.unfocus(); // Dismiss the keyboard
        },
      ),
    );
  }
}
