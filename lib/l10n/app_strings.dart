import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppStrings {
  AppStrings({
    required this.locale,
    required Map<String, String> values,
    required Map<String, String> fallback,
  }) : _values = values,
       _fallback = fallback;

  final Locale locale;
  final Map<String, String> _values;
  final Map<String, String> _fallback;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        AppStrings.fallback();
  }

  static AppStrings fallback() {
    return AppStrings(
      locale: const Locale('en'),
      values: const <String, String>{},
      fallback: const <String, String>{},
    );
  }

  static Future<AppStrings> load(Locale locale) async {
    final String languageCode = _normalizeLanguageCode(locale);
    // Always load English so missing keys still resolve to readable text.
    final Map<String, String> fallback = await _loadLanguageMap('en');
    final Map<String, String> values = languageCode == 'en'
        ? fallback
        : await _loadLanguageMap(languageCode);
    return AppStrings(
      locale: Locale(languageCode),
      values: values,
      fallback: fallback,
    );
  }

  static String _normalizeLanguageCode(Locale locale) {
    final String code = locale.languageCode.toLowerCase();
    for (final supported in supportedLocales) {
      if (supported.languageCode == code) {
        return code;
      }
    }
    return 'en';
  }

  static Future<Map<String, String>> _loadLanguageMap(
    String languageCode,
  ) async {
    final String normalized = languageCode.toLowerCase();
    final String assetPath = 'Languages/$normalized.json';
    try {
      final String raw = await rootBundle.loadString(assetPath);
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return const <String, String>{};
      final Map<String, dynamic> root = Map<String, dynamic>.from(decoded);
      final Object? appStringsNode = root['app_strings'];
      if (appStringsNode is! Map) return const <String, String>{};
      // JSON values are normalized to strings for lookup simplicity.
      return Map<String, dynamic>.from(appStringsNode).map(
        (key, value) => MapEntry(
          key.toString(),
          value?.toString() ?? '',
        ),
      );
    } catch (_) {
      return const <String, String>{};
    }
  }

  String _string(String key, {String? fallback}) {
    final String snakeKey = _toSnakeCase(key);
    final String? directValue = _values[key];
    final String? snakeValue = _values[snakeKey];
    final String? fallbackValue = _fallback[key] ?? _fallback[snakeKey];
    return _firstNonEmpty(
          <String?>[directValue, snakeValue, fallbackValue, fallback],
        ) ??
        key;
  }

  String _format(String template, Map<String, String> params) {
    var result = template;
    params.forEach((name, value) {
      result = result.replaceAll('{$name}', value);
    });
    return result;
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static String _toSnakeCase(String input) {
    if (input.isEmpty) return input;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final String char = input[i];
      final bool isUpper =
          char.toUpperCase() == char && char.toLowerCase() != char;
      if (isUpper && i > 0) {
        buffer.write('_');
      }
      buffer.write(isUpper ? char.toLowerCase() : char);
    }
    return buffer.toString();
  }

  String get refresh => _string('refresh', fallback: 'Refresh');
  String get saved => _string('saved', fallback: 'Settings saved.');
  String get saveFailed =>
      _string('saveFailed', fallback: 'Unable to save settings.');
  String get permissionGranted => _string(
        'permissionGranted',
        fallback: 'Notification permission granted.',
      );
  String get permissionDenied => _string(
        'permissionDenied',
        fallback: 'Notification permission was not granted.',
      );
  String get listenerOpened => _string(
        'listenerOpened',
        fallback: 'Opened Notification Listener settings.',
      );
  String get listenerUnavailable => _string(
        'listenerUnavailable',
        fallback: 'Unable to open Listener settings on this device.',
      );
  String get notificationsOpened => _string(
        'notificationsOpened',
        fallback: 'Opened app notification settings.',
      );
  String get notificationsUnavailable => _string(
        'notificationsUnavailable',
        fallback: 'Unable to open app notification settings.',
      );
  String get liveUpdatesOpened => _string(
        'liveUpdatesOpened',
        fallback: 'Opened Live Updates settings.',
      );
  String get liveUpdatesUnavailable => _string(
        'liveUpdatesUnavailable',
        fallback: 'Unable to open Live Updates settings on this device.',
      );
  String get githubOpenFailed =>
      _string('githubOpenFailed', fallback: 'Unable to open GitHub link.');
  String get dictionaryEmpty => _string(
        'dictionaryEmpty',
        fallback: 'Dictionary is empty or invalid.',
      );
  String get dictionaryDownloadFailed => _string(
        'dictionaryDownloadFailed',
        fallback: 'Failed to export dictionary.',
      );
  String get dictionarySaved => _string(
        'dictionarySaved',
        fallback: 'Dictionary saved to Downloads.',
      );
  String get dictionaryUploadDone => _string(
        'dictionaryUploadDone',
        fallback: 'Custom dictionary uploaded.',
      );
  String get dictionaryUpdateDone => _string(
        'dictionaryUpdateDone',
        fallback: 'Dictionary updated from GitHub.',
      );
  String get dictionaryInvalid =>
      _string('dictionaryInvalid', fallback: 'Invalid dictionary JSON.');
  String get dictionaryUploadFailed => _string(
        'dictionaryUploadFailed',
        fallback: 'Failed to upload dictionary.',
      );
  String get dictionaryUpdateFailed => _string(
        'dictionaryUpdateFailed',
        fallback: 'Failed to update dictionary from GitHub.',
      );
  String get dictionaryResetDone => _string(
        'dictionaryResetDone',
        fallback: 'Bundled dictionary restored.',
      );
  String get dictionaryResetFailed =>
      _string('dictionaryResetFailed', fallback: 'Failed to reset dictionary.');

  String get heroTitle => _string('heroTitle', fallback: 'LiveBridge');
  String get masterToggleLockedHint => _string(
        'masterToggleLockedHint',
        fallback:
            'Grant notification listener access and notifications permission first.',
      );
  String get githubUrl =>
      _string('githubUrl', fallback: 'github.com/appsfolder/livebridge');
  String get githubReleasesUrl => _string(
        'githubReleasesUrl',
        fallback: 'github.com/appsfolder/livebridge/releases',
      );
  String get downloadPageUrl =>
      _string('downloadPageUrl', fallback: 'appsfolder.github.io/livebridge');
  String get reportBug => _string('reportBug', fallback: 'Report a bug');
  String get bugReportCopied => _string(
        'bugReportCopied',
        fallback: 'Diagnostics copied to clipboard. Paste it into the issue.',
      );
  String get bugReportCopyFailed => _string(
        'bugReportCopyFailed',
        fallback: 'Failed to copy diagnostics.',
      );
  String get hideWarningBanner => _string('hideWarningBanner', fallback: 'Hide');
  String get backgroundWarningTitle => _string(
        'backgroundWarningTitle',
        fallback: 'Background mode warning',
      );
  String backgroundWarningBody(String deviceLabel) {
    final String template = _string(
      'backgroundWarningBody',
      fallback:
          'On {deviceLabel}, allow autostart and unrestricted background activity, otherwise Live Updates may stop appearing or freeze.',
    );
    return _format(template, {'deviceLabel': deviceLabel});
  }

  String get samsungWarningTitle => _string(
        'samsungWarningTitle',
        fallback: 'A better build is available for Samsung',
      );
  String get samsungWarningBody => _string(
        'samsungWarningBody',
        fallback:
            'There is a dedicated LiveBridge build for Samsung devices with improved Samsung-specific support. It is recommended over the regular build.',
      );
  String get samsungWarningAction =>
      _string('samsungWarningAction', fallback: 'Get Samsung build');

  String get accessTitle => _string('accessTitle', fallback: 'Permissions');
  String get accessSubtitle => _string(
        'accessSubtitle',
        fallback: 'Conversion reliability depends on these three permissions.',
      );
  String get listenerAccess => _string(
        'listenerAccess',
        fallback: 'Notification Listener access',
      );
  String get postNotifications => _string(
        'postNotifications',
        fallback: 'Post notifications permission',
      );
  String get liveUpdatesAccess => _string(
        'liveUpdatesAccess',
        fallback: 'Live Updates promotion',
      );
  String get open => _string('open', fallback: 'Open');
  String get request => _string('request', fallback: 'Request');
  String get grant => _string('grant', fallback: 'Grant');
  String get manage => _string('manage', fallback: 'Manage');
  String get settingsTitle => _string('settingsTitle', fallback: 'Settings');
  String get appLanguageTitle =>
      _string('app_language_title', fallback: 'App language');
  String get appLanguageDescription => _string(
        'app_language_description',
        fallback: 'changes the language used by LiveBridge UI',
      );
  String get appLanguagePickerTitle => _string(
        'app_language_picker_title',
        fallback: 'Choose app language',
      );
  String get appLanguageSystem =>
      _string('app_language_system', fallback: 'Auto');
  String get appLanguageEnglish => _string(
        'app_language_option_english',
        fallback: 'English',
      );
  String get appLanguageFrench => _string(
        'app_language_option_french',
        fallback: 'French',
      );
  String get keepAliveForegroundTitle => _string(
        'keepAliveForegroundTitle',
        fallback: 'Alt background mode',
      );
  String get keepAliveForegroundSubtitle => _string(
        'keepAliveForegroundSubtitle',
        fallback: 'Runs a persistent foreground service for better background stability.',
      );
  String get keepAliveForegroundInactiveSubtitle => _string(
        'keepAliveForegroundInactiveSubtitle',
        fallback: 'Enable the LiveBridge for this mode to take effect.',
      );
  String get networkSpeedTitle =>
      _string('networkSpeedTitle', fallback: 'Network speed');
  String get networkSpeedSubtitle => _string(
        'networkSpeedSubtitle',
        fallback:
            'Shows current download and upload as a separate Live Update in the status bar.',
      );
  String get networkSpeedInactiveSubtitle => _string(
        'networkSpeedInactiveSubtitle',
        fallback: 'Enable LiveBridge for the network speed monitor to start working.',
      );
  String get networkSpeedThresholdTitle => _string(
        'networkSpeedThresholdTitle',
        fallback: 'Minimum speed to show',
      );
  String get networkSpeedThresholdSubtitle => _string(
        'networkSpeedThresholdSubtitle',
        fallback:
            'The live element appears when combined download and upload reach this threshold.',
      );
  String get networkSpeedThresholdAlways =>
      _string('networkSpeedThresholdAlways', fallback: 'Always show');
  String get smartExternalDevicesIgnoreDebuggingTitle => _string(
        'smartExternalDevicesIgnoreDebuggingTitle',
        fallback: 'Ignore debugging',
      );
  String get smartExternalDevicesIgnoreDebuggingSubtitle => _string(
        'smartExternalDevicesIgnoreDebuggingSubtitle',
        fallback:
            'Skip Live updates for USB debugging, wireless debugging, ADB, and similar system notifications.',
      );
  String get syncDndTitle => _string('syncDndTitle', fallback: 'Sync DnD');
  String get syncDndSubtitle => _string(
        'syncDndSubtitle',
        fallback:
            'When Do Not Disturb is enabled on the phone, LiveBridge notifications are hidden.',
      );
  String get updateChecksTitle =>
      _string('updateChecksTitle', fallback: 'Update checking');
  String get updateChecksSubtitle => _string(
        'updateChecksSubtitle',
        fallback: 'Check updates on app start, and no more than once every 6 hours.',
      );
  String updateAvailableBanner(String version) {
    final String suffix = version.isNotEmpty ? ': $version' : '';
    final String template = _string(
      'updateAvailableBanner',
      fallback: 'Update available{versionSuffix}',
    );
    return _format(template, {
      'version': version,
      'versionSuffix': suffix,
    });
  }

  String get experimentalTitle =>
      _string('experimentalTitle', fallback: 'Experimental');
  String get notificationDedupTitle => _string(
        'notificationDedupTitle',
        fallback: 'Notification dedup',
      );
  String get notificationDedupSubtitle => _string(
        'notificationDedupSubtitle',
        fallback:
            'Dismisses original clearable notifications after LiveBridge mirrors an OTP or status update.',
      );
  String get notificationDedupModeLabel => _string(
        'notificationDedupModeLabel',
        fallback: 'Dedup mode',
      );
  String get notificationDedupModeOtpStatus => _string(
        'notificationDedupModeOtpStatus',
        fallback: 'OTP and statuses',
      );
  String get notificationDedupModeOtpOnly => _string(
        'notificationDedupModeOtpOnly',
        fallback: 'OTP only',
      );
  String get notificationDedupStatusesTitle => _string(
        'notificationDedupStatusesTitle',
        fallback: 'Also dedup statuses',
      );
  String get notificationDedupStatusesSubtitle => _string(
        'notificationDedupStatusesSubtitle',
        fallback: 'When disabled, dedup is applied only to OTP notifications.',
      );
  String get animatedIslandTitle =>
      _string('animatedIslandTitle', fallback: 'Animated island');
  String get animatedIslandSubtitle => _string(
        'animatedIslandSubtitle',
        fallback:
            'Rotates compact island text every 2-3 seconds for smart notifications (may be unstable).',
      );
  String get hyperBridgeTitle =>
      _string('hyperBridgeTitle', fallback: 'Xiaomi Hyper Island');
  String get hyperBridgeSubtitle => _string(
        'hyperBridgeSubtitle',
        fallback:
            'For Xiaomi Hyper OS 3.1 Global: injects HyperOS Focus parameters for native island behavior.',
      );
  String get aospCuttingTitle =>
      _string('aospCuttingTitle', fallback: 'AOSP cutting');
  String get aospCuttingSubtitle => _string(
        'aospCuttingSubtitle',
        fallback: 'Trim island text to 7 characters for cleaner rendering on AOSP ROMs.',
      );
  String get appPresentationSettings => _string(
        'appPresentationSettings',
        fallback: 'Per-app behavior',
      );
  String get appPresentationSubtitle => _string(
        'appPresentationSubtitle',
        fallback: 'Choose text and icon behavior separately for different applications.',
      );
  String get appPresentationScreenTitle => _string(
        'appPresentationScreenTitle',
        fallback: 'Per-app behavior',
      );
  String get appPresentationLoadFailed => _string(
        'appPresentationLoadFailed',
        fallback: 'Unable to load per-app settings.',
      );
  String get appPresentationSaveFailed => _string(
        'appPresentationSaveFailed',
        fallback: 'Unable to save per-app settings.',
      );
  String get appPresentationDownloadFailed => _string(
        'appPresentationDownloadFailed',
        fallback: 'Failed to save settings JSON.',
      );
  String get appPresentationSaved => _string(
        'appPresentationSaved',
        fallback: 'Settings saved to Downloads.',
      );
  String get appPresentationUploadDone => _string(
        'appPresentationUploadDone',
        fallback: 'Per-app settings imported.',
      );
  String get appPresentationUploadFailed => _string(
        'appPresentationUploadFailed',
        fallback: 'Failed to import settings JSON.',
      );
  String get appPresentationInvalidJson => _string(
        'appPresentationInvalidJson',
        fallback: 'Invalid per-app settings JSON.',
      );
  String get appPresentationDefaultSummary => _string(
        'appPresentationDefaultSummary',
        fallback: 'Default behavior',
      );
  String get appPresentationTextSourceLabel => _string(
        'appPresentationTextSourceLabel',
        fallback: 'Island text source',
      );
  String get appPresentationIconSourceLabel => _string(
        'appPresentationIconSourceLabel',
        fallback: 'Icon source',
      );
  String get appPresentationTextTitle => _string(
        'appPresentationTextTitle',
        fallback: 'Notification title',
      );
  String get appPresentationTextNotification => _string(
        'appPresentationTextNotification',
        fallback: 'Notification text',
      );
  String get appPresentationIconNotification => _string(
        'appPresentationIconNotification',
        fallback: 'Notification icon',
      );
  String get appPresentationIconApp => _string(
        'appPresentationIconApp',
        fallback: 'Application icon',
      );
  String get downloadSettings =>
      _string('downloadSettings', fallback: 'Download settings');
  String get uploadSettings =>
      _string('uploadSettings', fallback: 'Upload settings');
  String get defaultLabel => _string('defaultLabel', fallback: 'Default');
  String get resetToDefault =>
      _string('resetToDefault', fallback: 'Reset to default');
  String get save => _string('save', fallback: 'Save');
  String get downloadDictionary =>
      _string('downloadDictionary', fallback: 'Download dictionary');
  String get updateDictionary =>
      _string('updateDictionary', fallback: 'Update dictionary');
  String get uploadDictionary =>
      _string('uploadDictionary', fallback: 'Upload dictionary');
  String get resetDictionary =>
      _string('resetDictionary', fallback: 'Reset dictionary');
  String get pickApps => _string('pickApps', fallback: 'Pick applications');
  String get pickerTitle => _string(
        'pickerTitle',
        fallback: 'Choose apps for conversion',
      );
  String get otpPickerTitle => _string(
        'otpPickerTitle',
        fallback: 'Choose apps for code detection',
      );
  String get bypassPickerTitle => _string(
        'bypassPickerTitle',
        fallback: 'Choose apps for bypass',
      );
  String get notificationDedupPickerTitle => _string(
        'notificationDedupPickerTitle',
        fallback: 'Choose apps for notification dedup',
      );
  String get applySelection =>
      _string('applySelection', fallback: 'Apply selection');
  String get searchAppHint => _string(
        'searchAppHint',
        fallback: 'Search by app or package',
      );
  String get showSystemApps =>
      _string('showSystemApps', fallback: 'Show system applications');
  String get hideSystemApps =>
      _string('hideSystemApps', fallback: 'Hide system applications');
  String get appsLoadFailed => _string(
        'appsLoadFailed',
        fallback: 'Unable to load installed apps list.',
      );
  String get appsAccessTitle =>
      _string('appsAccessTitle', fallback: 'App list access');
  String get appsAccessMessage => _string(
        'appsAccessMessage',
        fallback: 'Allow LiveBridge to read installed apps so you can pick apps for rules?',
      );
  String get appsAccessSaveFailed => _string(
        'appsAccessSaveFailed',
        fallback: 'Unable to save access preference.',
      );
  String get cancel => _string('cancel', fallback: 'Cancel');
  String get allow => _string('allow', fallback: 'Allow');
  String selectedAppsCount(int value) {
    final String template = _string(
      'selectedAppsCount',
      fallback: 'Selected apps: {count}',
    );
    return _format(template, {'count': value.toString()});
  }

  String get noAppsSelected =>
      _string('noAppsSelected', fallback: 'No applications selected');

  String get rulesTitle =>
      _string('rulesTitle', fallback: 'Conversion behavior');
  String get rulesSubtitle => _string(
        'rulesSubtitle',
        fallback: 'Define what should be converted into Live Updates.',
      );
  String get modeLabel => _string('modeLabel', fallback: 'Application mode');
  String get modeAll => _string('modeAll', fallback: 'All applications');
  String get modeInclude => _string(
        'modeInclude',
        fallback: 'Only listed applications',
      );
  String get modeExclude => _string(
        'modeExclude',
        fallback: 'Exclude listed applications',
      );
  String get pickAppsHint => _string(
        'pickAppsHint',
        fallback: 'Selected app list is used only for include/exclude modes.',
      );
  String get bypassRulesTitle =>
      _string('bypassRulesTitle', fallback: 'Bypass apps');
  String get bypassRulesSubtitle => _string(
        'bypassRulesSubtitle',
        fallback: 'Listed apps are always converted to Live independently of settings.',
      );
  String get saveRules => _string('saveRules', fallback: 'Save');

  String get smartDetectionTitle => _string(
        'smartDetectionTitle',
        fallback: 'Smart status detection',
      );
  String get smartCardTitle =>
      _string('smart_conversion_title', fallback: 'Smart conversion');
  String get smartCardSubtitle => _string(
        'smartCardSubtitle',
        fallback: 'Converts text-only stage updates into one Live progress flow.',
      );
  String get smartDetectionSubtitle => _string(
        'smartDetectionSubtitle',
        fallback:
            'Converts text-only food/taxi/navigation status notifications into a single Live.',
      );
  String get smartMediaPlaybackTitle =>
      _string('smartMediaPlaybackTitle', fallback: 'Media Playback');
  String get smartMediaPlaybackSubtitle => _string(
        'smartMediaPlaybackSubtitle',
        fallback:
            'Converts media playback notifications into Live. On some OEMs this may duplicate native media UI.',
      );
  String get smartNavigationTitle => _string(
        'smartNavigationTitle',
        fallback: 'Navigation (maps)',
      );
  String get smartNavigationSubtitle => _string(
        'smartNavigationSubtitle',
        fallback: 'Navigation notification detection.',
      );
  String get smartWeatherTitle => _string('smartWeatherTitle', fallback: 'Weather');
  String get smartWeatherSubtitle => _string(
        'smartWeatherSubtitle',
        fallback: 'Weather notification detection (temperature in island).',
      );
  String get smartExternalDevicesTitle => _string(
        'smartExternalDevicesTitle',
        fallback: 'External devices',
      );
  String get smartExternalDevicesSubtitle => _string(
        'smartExternalDevicesSubtitle',
        fallback: 'Shows connected/connecting status and device name in island.',
      );
  String get smartVpnTitle =>
      _string('smartVpnTitle', fallback: 'VPN services');
  String get smartVpnSubtitle => _string(
        'smartVpnSubtitle',
        fallback: 'Shows incoming/outgoing traffic speed in *b/s format.',
      );
  String get smartNavigationDisabledSubtitle => _string(
        'smartNavigationDisabledSubtitle',
        fallback: 'Enable smart status detection first.',
      );
  String get smartDetectionDisabledSubtitle => _string(
        'smartDetectionDisabledSubtitle',
        fallback: 'Disabled while "Progress" mode is enabled.',
      );
  String get conflictingModesHint => _string(
        'conflictingModesHint',
        fallback:
            'Turn off "Progress" mode to enable food/taxi/navigation text status recognition.',
      );
  String get onlyProgressTitle => _string('onlyProgressTitle', fallback: 'Progress');
  String get onlyProgressSubtitle => _string(
        'onlyProgressSubtitle',
        fallback: 'When enabled, only notifications with a system progress bar are converted.',
      );
  String get textProgressTitle =>
      _string('textProgressTitle', fallback: 'Text progress');
  String get textProgressSubtitle => _string(
        'textProgressSubtitle',
        fallback:
            'If text contains % and it is not discount-related, treat it as progress and update island.',
      );

  String get blockedTitle => _string(
        'blockedTitle',
        fallback: 'AOSP is partially supported',
      );
  String get blockedSubtitle => _string(
        'blockedSubtitle',
        fallback:
            'LiveBridge is not designed for AOSP. You can continue, but i am not responsible for any bugs.',
      );
  String get blockedBypassAction => _string(
        'blockedBypassAction',
        fallback: 'Continue anyway',
      );
  String get blockedBypassSaveFailed => _string(
        'blockedBypassSaveFailed',
        fallback: 'Unable to save your choice.',
      );

  String get otpTitle =>
      _string('otpTitle', fallback: 'Verification codes');
  String get otpSubtitle => _string(
        'otpSubtitle',
        fallback: 'Shows the code in compact island.',
      );
  String get otpEnabledTitle => _string(
        'otpEnabledTitle',
        fallback: 'Detect verification codes',
      );
  String get otpEnabledSubtitle => _string(
        'otpEnabledSubtitle',
        fallback: 'Shows the numeric code in the compact island.',
      );
  String get otpAutoCopyTitle => _string(
        'otpAutoCopyTitle',
        fallback: 'Auto-copy code',
      );
  String get otpAutoCopySubtitle => _string(
        'otpAutoCopySubtitle',
        fallback: 'Code is copied to clipboard automatically.',
      );
  String get otpAutoCopyDisabledSubtitle => _string(
        'otpAutoCopyDisabledSubtitle',
        fallback: 'Enable code detection first.',
      );
  String get otpModeLabel =>
      _string('otpModeLabel', fallback: 'Code apps mode');
  String get saveOtpRules => _string('saveOtpRules', fallback: 'Save');
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode.toLowerCase(),
    );
  }

  @override
  Future<AppStrings> load(Locale locale) => AppStrings.load(locale);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
