import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'models.dart';

/// Creates a [RichText] widget that supports emails, mentions, hashtags and more.
///
/// When [viewLessText] is specified, toggling between view more and view less will be supported.
///
/// For displaying a rich text editor, see the [RichTextEditor] class
///
class RichTextView extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle linkStyle;
  final TextDirection? textDirection;
  final bool softWrap;
  final double textScaleFactor;
  final int? maxLines;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final bool selectable;
  final GestureTapCallback? onTap;
  final Function()? onMore;
  final bool truncate;

  /// the view more text if `truncate` is true
  final String viewMoreText;

  /// the view more and view less text's style
  final TextStyle? viewMoreLessStyle;

  /// if included, will show a view less text
  final String? viewLessText;
  final List<ParserType> supportedTypes;
  final RegexOptions regexOptions;
  final TextAlign textAlign;

  /// Whether to show "Show more" or "Show less" link at the end
  /// of the text. Tapping on the button will toggle the text
  /// between truncated and expanded text.
  final bool toggleTruncate;

  RichTextView({
    Key? key,
    required this.text,
    required this.supportedTypes,
    required this.truncate,
    required this.linkStyle,
    this.style,
    this.toggleTruncate = false,
    this.regexOptions = const RegexOptions(),
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.softWrap = true,
    this.textScaleFactor = 1.0,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.maxLines,
    this.onTap,
    this.onMore,
    this.viewMoreText = 'more',
    this.viewLessText,
    this.viewMoreLessStyle,
    this.selectable = false,
  }) : super(key: key);

  @override
  State<RichTextView> createState() => _RichTextViewState();
}

class _RichTextViewState extends State<RichTextView> {
  late bool _expanded;
  late int? _maxLines;
  late TextStyle linkStyle;

  @override
  void initState() {
    super.initState();
    _expanded = !widget.truncate;
    _maxLines = widget.truncate ? (widget.maxLines ?? 2) : widget.maxLines;
    linkStyle = widget.linkStyle;
  }

  @override
  Widget build(BuildContext context) {
    var _style = widget.style ?? Theme.of(context).textTheme.bodyMedium;
    var link = _expanded && widget.viewLessText == null
        ? TextSpan()
        : TextSpan(
            children: [
              TextSpan(
                  text: _expanded ? widget.viewLessText : widget.viewMoreText,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (!_expanded && widget.onMore != null) {
                        widget.onMore!();
                      } else {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      }
                    }),
            ],
            style: widget.viewMoreLessStyle ?? linkStyle,
          );

    List<InlineSpan> parseText(String txt) {
      var newString = txt;

      var _mapping = <String, ParserType>{};

      for (var type in widget.supportedTypes) {
        _mapping[type.pattern!] = type;
      }

      final pattern = '(${_mapping.keys.toList().join('|')})';

      var widgets = <InlineSpan>[];

      newString.splitMapJoin(
        RegExp(
          pattern,
          multiLine: widget.regexOptions.multiLine,
          caseSensitive: widget.regexOptions.caseSensitive,
          dotAll: widget.regexOptions.dotAll,
          unicode: widget.regexOptions.unicode,
        ),
        onMatch: (Match match) {
          final matchText = match[0];

          final mapping = _mapping[matchText!] ??
              _mapping[_mapping.keys.firstWhere((element) {
                final reg = RegExp(
                  element,
                  multiLine: widget.regexOptions.multiLine,
                  caseSensitive: widget.regexOptions.caseSensitive,
                  dotAll: widget.regexOptions.dotAll,
                  unicode: widget.regexOptions.unicode,
                );
                return reg.hasMatch(matchText);
              }, orElse: () {
                return '';
              })];

          InlineSpan span;

          if (mapping != null) {
            if (mapping.renderText != null) {
              var result = mapping.renderText!(str: matchText);

              result.start = match.start;
              result.end = match.end;

              span = TextSpan(
                text: '${result.display}',
                style: mapping.style ?? linkStyle,
                recognizer: mapping.onTap == null
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () => mapping.onTap!(result)),
              );
            } else {
              var matched = Matched(
                  display: matchText,
                  value: matchText,
                  start: match.start,
                  end: match.end);
              span = TextSpan(
                text: '$matchText',
                style: mapping.style ?? linkStyle,
                recognizer: mapping.onTap == null
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () => mapping.onTap!(matched)),
              );
            }
          } else {
            span = TextSpan(
              text: '$matchText',
              style: _style,
            );
          }
          widgets.add(span);
          return '';
        },
        onNonMatch: (String text) {
          widgets.add(TextSpan(
            text: '$text',
            style: _style,
          ));

          return '';
        },
      );
      return widgets;
    }

    final content = TextSpan(children: parseText(widget.text), style: _style);

    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final maxWidth = constraints.maxWidth;

        var textPainter = TextPainter(
          text: link,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          maxLines: _maxLines,
        );

        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;

        final ellipsis = '…';
        textPainter.text = TextSpan(text: ellipsis, style: _style);
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final ellipsisSize = textPainter.size;

        textPainter.text = content;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        var textSpan;
        if (textPainter.didExceedMaxLines) {
          final pos = textPainter.getPositionForOffset(Offset(
            // "Show more"/"Show less" will be appended to the end of the text
            // if `toggleTruncate` is true. Otherwise, ellipsis will be appended.
            // Therefore, we need to subtract the width of the appended text
            // from the total width of the text.
            textSize.width -
                (widget.toggleTruncate ? linkSize.width : ellipsisSize.width),
            textSize.height,
          ));
          final endIndex = textPainter.getOffsetBefore(pos.offset);

          final textChildren = _expanded
              ? parseText(widget.text)
              : parseText(widget.text.substring(0, max(endIndex!, 0)) + '…');

          final lastTextSpan = textChildren
              .lastWhereOrNull((child) => child is TextSpan) as TextSpan?;

          final _text = TextSpan(
            children: textChildren,
            style: widget.style,
          );

          final textEndsWithNewLine =
              lastTextSpan?.text?.endsWith('\n') ?? false;

          textSpan = TextSpan(
            children: [
              _text,
              if (widget.toggleTruncate) ...[
                if (!textEndsWithNewLine)
                  TextSpan(
                    text: ' ',
                    style: widget.style,
                  ),
                link,
              ],
            ],
          );
        } else {
          textSpan = content;
        }

        if (widget.selectable) {
          return SelectableText.rich(
            textSpan,
            strutStyle: widget.strutStyle,
            textWidthBasis: widget.textWidthBasis,
            textAlign: widget.textAlign,
            textDirection: widget.textDirection,
            onTap: widget.onTap,
          );
        }

        return RichText(
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          textScaleFactor: widget.textScaleFactor,
          text: textSpan,
          textWidthBasis: widget.textWidthBasis,
        );
      },
    );

    return result;
  }
}
