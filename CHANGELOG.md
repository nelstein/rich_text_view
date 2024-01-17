##[1.5.0]
- Support "-" character in URL pattern.

##[1.4.0]
- Add `onMore` callback when the content is expanded.

##[1.3.0]

- Updated `RTUtils.emailPattern` and `RTUtils.urlPattern` to use RFC 5322 Standard Regex
- disposed `suggestionController` correctly
- added `ItalicsParser` and `viewMoreLessStyle`
- Fixed (#31)[https://github.com/nelsonweze/rich_text_view/issues/31] and (#32)[https://github.com/nelsonweze/rich_text_view/issues/32]
- Added `borderColor` property to `SuggestionController`

##[1.2.1-dev-1]

- Fixed (#31)[https://github.com/nelsonweze/rich_text_view/issues/31] and (#32)[https://github.com/nelsonweze/rich_text_view/issues/32]
- Added `borderColor` property to `SuggestionController`

## [1.2.0]

- BREAKING: Removed `ParsedType`, renamed `MatchText` to `ParserType`
- `RichTextView.supportedTypes` now takes list of `ParserType` eg `MentionParser`, `HashTagParser`, `UrlParser` and so on. You can extend `ParserType` for a custom parser
- All onTap callbacks in `RichTextView` have been moved to thier individual parser class
- `ParserType.onTap` returns `Matched` which also contains the start and end indexes
- Check example codes for more

## [1.1.0]

- stable release
- minor fixes

## [1.1.0-dev-1]

- BREAKING: Added SuggestionController which now takes more customizations
- Removed dependency on Bloc package,
- Added id param to `Mention`

## [1.0.0]

- Stable release

## [1.0.0-dev-2]

- BREAKING: Separated RichTextEditor from RichTextView to avoid confusion with parameters.
- Added more text field parameters
- Added support to toggle between view more and view less

## [1.0.0-dev-1]

- BREAKING: `Suggestion` renamed to `Mention`
  `onSearchPeople` renamed to `onSearchMention`
  `onSuggestionSelected` renamed to `onMentionSelected`
  `showMoreText` renamed to `truncate`
- Added callbacks for when a mention or hashtag is selected during search
- Added option to use custom widgets for suggestion items

## [0.0.3]

- Fix bold style issue
- Fix issue when selectable is set to false

## [0.0.2]

- To use as a TextField, there's now RichTextView.editor
- Added screenshot to README.md
- fixed some bugs and improved example codes

## [0.0.1]

- Initial release to pub.dev
