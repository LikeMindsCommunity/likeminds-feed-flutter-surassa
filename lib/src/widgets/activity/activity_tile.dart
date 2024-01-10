import 'package:flutter/material.dart';

class SSActivityTileWidget extends StatefulWidget {
  const SSActivityTileWidget({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.onTap,
    this.boxDecoration,
  });
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final BoxDecoration? boxDecoration;

  @override
  State<SSActivityTileWidget> createState() => _SSActivityTileWidgetState();
}

class _SSActivityTileWidgetState extends State<SSActivityTileWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: widget.boxDecoration,
          child: Row(
            children: [
              widget.leading ?? const SizedBox.shrink(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.title ?? const SizedBox.shrink(),
                    widget.subtitle ?? const SizedBox.shrink(),
                  ],
                ),
              ),
              widget.trailing ?? const SizedBox.shrink(),
            ],
          ),
        ));
  }
}
