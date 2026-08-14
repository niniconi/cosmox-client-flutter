import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @tip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tip;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get mine;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @globalSettings.
  ///
  /// In en, this message translates to:
  /// **'Global Settings'**
  String get globalSettings;

  /// No description provided for @globalDashboard.
  ///
  /// In en, this message translates to:
  /// **'Global Dashboard'**
  String get globalDashboard;

  /// No description provided for @subtitleSettings.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Settings'**
  String get subtitleSettings;

  /// No description provided for @playbackSettings.
  ///
  /// In en, this message translates to:
  /// **'Playback Settings'**
  String get playbackSettings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @networkSettings.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkSettings;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @userManager.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManager;

  /// No description provided for @pluginManager.
  ///
  /// In en, this message translates to:
  /// **'Plugins'**
  String get pluginManager;

  /// No description provided for @apiManager.
  ///
  /// In en, this message translates to:
  /// **'API Management'**
  String get apiManager;

  /// No description provided for @logManager.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logManager;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @metadataEditor.
  ///
  /// In en, this message translates to:
  /// **'Metadata Editor'**
  String get metadataEditor;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @nicknameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Nickname not set'**
  String get nicknameNotSet;

  /// No description provided for @underConstruction.
  ///
  /// In en, this message translates to:
  /// **'Under Construction'**
  String get underConstruction;

  /// No description provided for @thisFeatureIsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon'**
  String get thisFeatureIsComingSoon;

  /// No description provided for @thisFeatureIsUnderConstruction.
  ///
  /// In en, this message translates to:
  /// **'This feature is under construction'**
  String get thisFeatureIsUnderConstruction;

  /// No description provided for @unknownPlatform.
  ///
  /// In en, this message translates to:
  /// **'Unknown Platform'**
  String get unknownPlatform;

  /// No description provided for @serverVersion.
  ///
  /// In en, this message translates to:
  /// **'Server Version'**
  String get serverVersion;

  /// No description provided for @clientVersion.
  ///
  /// In en, this message translates to:
  /// **'Client Version'**
  String get clientVersion;

  /// No description provided for @operatingSystem.
  ///
  /// In en, this message translates to:
  /// **'OS'**
  String get operatingSystem;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @globalScan.
  ///
  /// In en, this message translates to:
  /// **'Global Scan'**
  String get globalScan;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search what you want...'**
  String get searchHint;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @deleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get deleteUserConfirm;

  /// No description provided for @restartServerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart the server?'**
  String get restartServerConfirm;

  /// No description provided for @stopServerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to shut down the server?'**
  String get stopServerConfirm;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordNotMatch;

  /// No description provided for @contactAdmin.
  ///
  /// In en, this message translates to:
  /// **'Please contact the administrator'**
  String get contactAdmin;

  /// No description provided for @cachePath.
  ///
  /// In en, this message translates to:
  /// **'Cache Path'**
  String get cachePath;

  /// No description provided for @logPath.
  ///
  /// In en, this message translates to:
  /// **'Log Path'**
  String get logPath;

  /// No description provided for @metadataPath.
  ///
  /// In en, this message translates to:
  /// **'Metadata Path'**
  String get metadataPath;

  /// No description provided for @notificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Notification Email'**
  String get notificationEmail;

  /// No description provided for @enableQuickConnect.
  ///
  /// In en, this message translates to:
  /// **'Enable Quick Connect on this server'**
  String get enableQuickConnect;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @startUse.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get startUse;

  /// No description provided for @createAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an admin account'**
  String get createAdminAccount;

  /// No description provided for @scanStarted.
  ///
  /// In en, this message translates to:
  /// **'Scan started'**
  String get scanStarted;

  /// No description provided for @addAvatar.
  ///
  /// In en, this message translates to:
  /// **'Add Avatar'**
  String get addAvatar;

  /// No description provided for @confirmSave.
  ///
  /// In en, this message translates to:
  /// **'Confirm save?'**
  String get confirmSave;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm?'**
  String get confirmAction;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamed;

  /// No description provided for @newUpdate.
  ///
  /// In en, this message translates to:
  /// **'New Update'**
  String get newUpdate;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @otherInfo.
  ///
  /// In en, this message translates to:
  /// **'Other Info'**
  String get otherInfo;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @addPlugin.
  ///
  /// In en, this message translates to:
  /// **'Add Plugin'**
  String get addPlugin;

  /// No description provided for @myComics.
  ///
  /// In en, this message translates to:
  /// **'My Comics'**
  String get myComics;

  /// No description provided for @introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// No description provided for @episodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @episodeList.
  ///
  /// In en, this message translates to:
  /// **'Episode List'**
  String get episodeList;

  /// No description provided for @reviewSection.
  ///
  /// In en, this message translates to:
  /// **'Review Section'**
  String get reviewSection;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// No description provided for @plotSummary.
  ///
  /// In en, this message translates to:
  /// **'Plot Summary'**
  String get plotSummary;

  /// No description provided for @coreTags.
  ///
  /// In en, this message translates to:
  /// **'Core Tags'**
  String get coreTags;

  /// No description provided for @castTab.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get castTab;

  /// No description provided for @staffTab.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTab;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @voiceActors.
  ///
  /// In en, this message translates to:
  /// **'Voice Actors'**
  String get voiceActors;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Invalid username'**
  String get invalidUsername;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password'**
  String get invalidPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @invalidPath.
  ///
  /// In en, this message translates to:
  /// **'Invalid path'**
  String get invalidPath;

  /// No description provided for @invalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid address'**
  String get invalidAddress;

  /// No description provided for @addressCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Address cannot be empty'**
  String get addressCannotBeEmpty;

  /// No description provided for @serverName.
  ///
  /// In en, this message translates to:
  /// **'Server Name'**
  String get serverName;

  /// No description provided for @serverNameHelp.
  ///
  /// In en, this message translates to:
  /// **'This name will be used to identify the server and will default to the server\'s hostname.'**
  String get serverNameHelp;

  /// No description provided for @cachePathHelp.
  ///
  /// In en, this message translates to:
  /// **'Specify a custom location for server cache files such as images. Leave blank to use the server default.'**
  String get cachePathHelp;

  /// No description provided for @metadataPathHelp.
  ///
  /// In en, this message translates to:
  /// **'Specify a custom location for downloaded artwork and metadata.'**
  String get metadataPathHelp;

  /// No description provided for @notifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Notification Email'**
  String get notifyEmail;

  /// No description provided for @token.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get token;

  /// No description provided for @pleaseInputToken.
  ///
  /// In en, this message translates to:
  /// **'Please input token'**
  String get pleaseInputToken;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue!'**
  String get signInToContinue;

  /// No description provided for @selectOtherServer.
  ///
  /// In en, this message translates to:
  /// **'Select other server'**
  String get selectOtherServer;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Browse Categories'**
  String get browseCategories;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for'**
  String get noResultsFor;

  /// No description provided for @backToSearch.
  ///
  /// In en, this message translates to:
  /// **'Back to search'**
  String get backToSearch;

  /// No description provided for @welcomeToUse.
  ///
  /// In en, this message translates to:
  /// **'Welcome to use'**
  String get welcomeToUse;

  /// No description provided for @exploreTheUniverse.
  ///
  /// In en, this message translates to:
  /// **'Explore the universe of content with ease and elegance.'**
  String get exploreTheUniverse;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language will be used in cosmox server'**
  String get chooseLanguage;

  /// No description provided for @versionCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Version copied to clipboard'**
  String get versionCopiedToClipboard;

  /// No description provided for @serverInformation.
  ///
  /// In en, this message translates to:
  /// **'Server Information'**
  String get serverInformation;

  /// No description provided for @unableToFetchServerInfo.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch server information'**
  String get unableToFetchServerInfo;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'About Content'**
  String get aboutContent;

  /// No description provided for @savePicture.
  ///
  /// In en, this message translates to:
  /// **'Save picture'**
  String get savePicture;

  /// No description provided for @routeScreen.
  ///
  /// In en, this message translates to:
  /// **'Route screen'**
  String get routeScreen;

  /// No description provided for @rightToLeft.
  ///
  /// In en, this message translates to:
  /// **'Right to left'**
  String get rightToLeft;

  /// No description provided for @leftToRight.
  ///
  /// In en, this message translates to:
  /// **'Left to right'**
  String get leftToRight;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get backgroundColor;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @familyControl.
  ///
  /// In en, this message translates to:
  /// **'Family control'**
  String get familyControl;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'New password confirm'**
  String get newPasswordConfirm;

  /// No description provided for @differentPassword.
  ///
  /// In en, this message translates to:
  /// **'Different password'**
  String get differentPassword;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous Page'**
  String get previousPage;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @areYouSureDeleteThisUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure delete this user?'**
  String get areYouSureDeleteThisUser;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @cacheStorage.
  ///
  /// In en, this message translates to:
  /// **'Cache & Storage'**
  String get cacheStorage;

  /// No description provided for @downloadPath.
  ///
  /// In en, this message translates to:
  /// **'Download Path'**
  String get downloadPath;

  /// No description provided for @cacheSize.
  ///
  /// In en, this message translates to:
  /// **'Cache Size'**
  String get cacheSize;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @defaultSubtitleLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Subtitle Language'**
  String get defaultSubtitleLanguage;

  /// No description provided for @defaultPlaybackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Default Playback Speed'**
  String get defaultPlaybackSpeed;

  /// No description provided for @hardwareDecoding.
  ///
  /// In en, this message translates to:
  /// **'Hardware Decoding'**
  String get hardwareDecoding;

  /// No description provided for @hardwareDecodingHint.
  ///
  /// In en, this message translates to:
  /// **'Use hardware acceleration when available'**
  String get hardwareDecodingHint;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @defaultAudioLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Audio Language'**
  String get defaultAudioLanguage;

  /// No description provided for @subtitleFontSize.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Font Size'**
  String get subtitleFontSize;

  /// No description provided for @autoPlayNextEpisode.
  ///
  /// In en, this message translates to:
  /// **'Auto-play Next Episode'**
  String get autoPlayNextEpisode;

  /// No description provided for @resumePlayback.
  ///
  /// In en, this message translates to:
  /// **'Resume Playback'**
  String get resumePlayback;

  /// No description provided for @downloadQuality.
  ///
  /// In en, this message translates to:
  /// **'Download Quality'**
  String get downloadQuality;

  /// No description provided for @wifiOnlyDownload.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Only Download'**
  String get wifiOnlyDownload;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @streamingBufferSize.
  ///
  /// In en, this message translates to:
  /// **'Streaming Buffer Size'**
  String get streamingBufferSize;

  /// No description provided for @httpsOnly.
  ///
  /// In en, this message translates to:
  /// **'HTTPS Only'**
  String get httpsOnly;

  /// No description provided for @proxySettings.
  ///
  /// In en, this message translates to:
  /// **'Proxy Settings'**
  String get proxySettings;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @subtitleBgOpacity.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Background Opacity'**
  String get subtitleBgOpacity;

  /// No description provided for @largeTextMode.
  ///
  /// In en, this message translates to:
  /// **'Large Text Mode'**
  String get largeTextMode;

  /// No description provided for @highContrastMode.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Mode'**
  String get highContrastMode;

  /// No description provided for @debugLogging.
  ///
  /// In en, this message translates to:
  /// **'Debug Logging'**
  String get debugLogging;

  /// No description provided for @enableAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Enable Analytics'**
  String get enableAnalytics;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @defaultLibraryView.
  ///
  /// In en, this message translates to:
  /// **'Default Library View'**
  String get defaultLibraryView;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @contentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Content Language'**
  String get contentLanguage;

  /// No description provided for @parentalControls.
  ///
  /// In en, this message translates to:
  /// **'Parental Controls'**
  String get parentalControls;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @bufferSmall.
  ///
  /// In en, this message translates to:
  /// **'2 MB'**
  String get bufferSmall;

  /// No description provided for @bufferMedium.
  ///
  /// In en, this message translates to:
  /// **'10 MB'**
  String get bufferMedium;

  /// No description provided for @bufferLarge.
  ///
  /// In en, this message translates to:
  /// **'50 MB'**
  String get bufferLarge;

  /// No description provided for @qualityOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get qualityOriginal;

  /// No description provided for @qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High (1080p)'**
  String get qualityHigh;

  /// No description provided for @qualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (720p)'**
  String get qualityMedium;

  /// No description provided for @qualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low (480p)'**
  String get qualityLow;

  /// No description provided for @audioLanguage.
  ///
  /// In en, this message translates to:
  /// **'Audio Language'**
  String get audioLanguage;

  /// No description provided for @subtitleTextColor.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Text Color'**
  String get subtitleTextColor;

  /// No description provided for @autoGenerateSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Auto-generate Subtitles'**
  String get autoGenerateSubtitles;

  /// No description provided for @backgroundPlayback.
  ///
  /// In en, this message translates to:
  /// **'Background Playback'**
  String get backgroundPlayback;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @pleaseSelectServer.
  ///
  /// In en, this message translates to:
  /// **'Please select your server'**
  String get pleaseSelectServer;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example:'**
  String get example;

  /// No description provided for @localHttpPort.
  ///
  /// In en, this message translates to:
  /// **'Local HTTP Port'**
  String get localHttpPort;

  /// No description provided for @httpPortHelp.
  ///
  /// In en, this message translates to:
  /// **'HTTP port for server connection'**
  String get httpPortHelp;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @adminAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Admin account created'**
  String get adminAccountCreated;

  /// No description provided for @addFirstLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add your first library'**
  String get addFirstLibrary;

  /// No description provided for @configureLanguageRegion.
  ///
  /// In en, this message translates to:
  /// **'Configure language & region'**
  String get configureLanguageRegion;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @setupAdminAccount.
  ///
  /// In en, this message translates to:
  /// **'Set up the administrator account for your server.'**
  String get setupAdminAccount;

  /// No description provided for @librarySetup.
  ///
  /// In en, this message translates to:
  /// **'Library Setup'**
  String get librarySetup;

  /// No description provided for @manageLibraries.
  ///
  /// In en, this message translates to:
  /// **'Manage your media libraries.'**
  String get manageLibraries;

  /// No description provided for @noPlugins.
  ///
  /// In en, this message translates to:
  /// **'No plugins'**
  String get noPlugins;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @pluginUrl.
  ///
  /// In en, this message translates to:
  /// **'Plugin URL'**
  String get pluginUrl;

  /// No description provided for @pluginInstalled.
  ///
  /// In en, this message translates to:
  /// **'Plugin installed'**
  String get pluginInstalled;

  /// No description provided for @confirmUninstallPlugin.
  ///
  /// In en, this message translates to:
  /// **'Uninstall plugin'**
  String get confirmUninstallPlugin;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
