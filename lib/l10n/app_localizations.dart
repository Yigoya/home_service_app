import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';

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
    Locale('am'),
    Locale('en'),
    Locale('om')
  ];

  /// No description provided for @ourBestTechnicians.
  ///
  /// In en, this message translates to:
  /// **'Our Best Technicians'**
  String get ourBestTechnicians;

  /// No description provided for @whatTheCustomerSays.
  ///
  /// In en, this message translates to:
  /// **'What the Customer Says'**
  String get whatTheCustomerSays;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @everythingAtYourFingertips.
  ///
  /// In en, this message translates to:
  /// **'All in one services, on demand'**
  String get everythingAtYourFingertips;

  /// No description provided for @searchForServices.
  ///
  /// In en, this message translates to:
  /// **'Search for services'**
  String get searchForServices;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @pleaseSelectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please Select Date and Time'**
  String get pleaseSelectDateAndTime;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @selectSchedulingDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Select a Scheduling Date and Time'**
  String get selectSchedulingDateAndTime;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose Date'**
  String get chooseDate;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose Time'**
  String get chooseTime;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @enterYourAnswerHere.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer here'**
  String get enterYourAnswerHere;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @selectYourSubCity.
  ///
  /// In en, this message translates to:
  /// **'Select your sub-city'**
  String get selectYourSubCity;

  /// No description provided for @selectYourWereda.
  ///
  /// In en, this message translates to:
  /// **'Select your wereda'**
  String get selectYourWereda;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @selectAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Select and continue'**
  String get selectAndContinue;

  /// No description provided for @pleaseSelectSubCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a sub-city'**
  String get pleaseSelectSubCity;

  /// No description provided for @pleaseSelectWereda.
  ///
  /// In en, this message translates to:
  /// **'Please select a wereda'**
  String get pleaseSelectWereda;

  /// No description provided for @pleaseDescribeJob.
  ///
  /// In en, this message translates to:
  /// **'Please describe the job'**
  String get pleaseDescribeJob;

  /// No description provided for @describeJobTask.
  ///
  /// In en, this message translates to:
  /// **'Explain the job task in simple language'**
  String get describeJobTask;

  /// No description provided for @bookService.
  ///
  /// In en, this message translates to:
  /// **'Book the Service'**
  String get bookService;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your booking has been successfully placed.'**
  String get bookingSuccess;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @denied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get denied;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @dispute.
  ///
  /// In en, this message translates to:
  /// **'Dispute'**
  String get dispute;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @rateAndReview.
  ///
  /// In en, this message translates to:
  /// **'Rate and Review'**
  String get rateAndReview;

  /// No description provided for @writeYourReview.
  ///
  /// In en, this message translates to:
  /// **'Write your review here'**
  String get writeYourReview;

  /// No description provided for @pleaseProvideRatingAndReview.
  ///
  /// In en, this message translates to:
  /// **'Please provide a rating and review'**
  String get pleaseProvideRatingAndReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @giveReview.
  ///
  /// In en, this message translates to:
  /// **'Give Review'**
  String get giveReview;

  /// No description provided for @businessHour.
  ///
  /// In en, this message translates to:
  /// **'Business Hour'**
  String get businessHour;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @noScheduleAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schedule available'**
  String get noScheduleAvailable;

  /// No description provided for @ratingsFor.
  ///
  /// In en, this message translates to:
  /// **'Ratings for'**
  String get ratingsFor;

  /// No description provided for @noOneRatedYet.
  ///
  /// In en, this message translates to:
  /// **'No one has rated yet'**
  String get noOneRatedYet;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @moreAbout.
  ///
  /// In en, this message translates to:
  /// **'More about'**
  String get moreAbout;

  /// No description provided for @scheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved'**
  String get scheduleSaved;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @writeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Write your message'**
  String get writeYourMessage;

  /// No description provided for @enterYourReason.
  ///
  /// In en, this message translates to:
  /// **'Enter your reason'**
  String get enterYourReason;

  /// No description provided for @stateYourDispute.
  ///
  /// In en, this message translates to:
  /// **'State your dispute'**
  String get stateYourDispute;

  /// No description provided for @describeYourDispute.
  ///
  /// In en, this message translates to:
  /// **'Describe your dispute'**
  String get describeYourDispute;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Please login to your account'**
  String get loginToYourAccount;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'Or Sign In With'**
  String get orSignInWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t you have an account?'**
  String get dontHaveAccount;

  /// No description provided for @registerAsTechnician.
  ///
  /// In en, this message translates to:
  /// **'Register as a Technician'**
  String get registerAsTechnician;

  /// No description provided for @completeYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Details'**
  String get completeYourDetails;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmailRequired;

  /// No description provided for @validPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get validPhoneRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @joinUs.
  ///
  /// In en, this message translates to:
  /// **'Join us to experience the best home services.'**
  String get joinUs;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @technicianRegistration.
  ///
  /// In en, this message translates to:
  /// **'Technician Registration'**
  String get technicianRegistration;

  /// No description provided for @fillDetailsToRegister.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the details below to register as a technician.'**
  String get fillDetailsToRegister;

  /// No description provided for @enterYourBio.
  ///
  /// In en, this message translates to:
  /// **'Please enter your bio'**
  String get enterYourBio;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'You are almost there!'**
  String get almostThere;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENTS'**
  String get documents;

  /// No description provided for @idCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCard;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @enterToken.
  ///
  /// In en, this message translates to:
  /// **'Enter Token'**
  String get enterToken;

  /// No description provided for @tokenPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your token here'**
  String get tokenPlaceholder;

  /// No description provided for @token.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get token;

  /// No description provided for @tokenCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Token cannot be empty'**
  String get tokenCannotBeEmpty;

  /// No description provided for @tokenTooShort.
  ///
  /// In en, this message translates to:
  /// **'Token must be at least 16 characters long'**
  String get tokenTooShort;

  /// No description provided for @invalidToken.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid token.'**
  String get invalidToken;

  /// No description provided for @tokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Token not found.'**
  String get tokenNotFound;

  /// No description provided for @ticketUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket uploaded successfully!'**
  String get ticketUploadedSuccessfully;

  /// No description provided for @failedToUploadTicket.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload ticket.'**
  String get failedToUploadTicket;

  /// No description provided for @technicianDetails.
  ///
  /// In en, this message translates to:
  /// **'Technician Details'**
  String get technicianDetails;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @uploadTicket.
  ///
  /// In en, this message translates to:
  /// **'Upload Ticket'**
  String get uploadTicket;

  /// No description provided for @submitTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get submitTicket;

  /// No description provided for @registrationFeeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Registration Fee Transfer\n500 birr'**
  String get registrationFeeTransfer;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// No description provided for @verificationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Verification in Progress'**
  String get verificationInProgress;

  /// No description provided for @verificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your patience. We are currently verifying your account.'**
  String get verificationMessage;

  /// No description provided for @accountActivated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully activated. You can now log in and start using the app.'**
  String get accountActivated;

  /// No description provided for @waitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Your Approval'**
  String get waitingForApproval;

  /// No description provided for @requestProcessing.
  ///
  /// In en, this message translates to:
  /// **'Your request is being processed. You will be notified once it has been approved.'**
  String get requestProcessing;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatus;

  /// No description provided for @homeServicePlatform.
  ///
  /// In en, this message translates to:
  /// **'Home Service Platform'**
  String get homeServicePlatform;

  /// No description provided for @figtree.
  ///
  /// In en, this message translates to:
  /// **'Figtree'**
  String get figtree;

  /// No description provided for @technician.
  ///
  /// In en, this message translates to:
  /// **'TECHNICIAN'**
  String get technician;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get password;

  /// No description provided for @booking.
  ///
  /// In en, this message translates to:
  /// **'booking'**
  String get booking;

  /// No description provided for @noDateProvided.
  ///
  /// In en, this message translates to:
  /// **'No date provided.'**
  String get noDateProvided;

  /// No description provided for @invalidDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format.'**
  String get invalidDateFormat;

  /// No description provided for @dateHasPassed.
  ///
  /// In en, this message translates to:
  /// **'The date has already passed.'**
  String get dateHasPassed;

  /// No description provided for @lessThanMinuteRemaining.
  ///
  /// In en, this message translates to:
  /// **'Less than a minute remaining'**
  String get lessThanMinuteRemaining;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them in settings.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Please grant permission to access location.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it in settings.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @unableToFetchAddress.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch address for the current location.'**
  String get unableToFetchAddress;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get error;

  /// No description provided for @errorFetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while fetching the location'**
  String get errorFetchingLocation;

  /// No description provided for @networkIssue.
  ///
  /// In en, this message translates to:
  /// **'Network issue occurred.'**
  String get networkIssue;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network Error: '**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred.'**
  String get serverError;

  /// No description provided for @serverErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Server Error: '**
  String get serverErrorMessage;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input.'**
  String get invalidInput;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation Error: '**
  String get validationError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorMessage;

  /// No description provided for @submittingContactForm.
  ///
  /// In en, this message translates to:
  /// **'Submitting Contact Form with data:'**
  String get submittingContactForm;

  /// No description provided for @formSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your form has been submitted successfully.'**
  String get formSubmittedSuccessfully;

  /// No description provided for @networkErrorHappened.
  ///
  /// In en, this message translates to:
  /// **'Network Error happened'**
  String get networkErrorHappened;

  /// No description provided for @submittingDisputeForm.
  ///
  /// In en, this message translates to:
  /// **'Submitting Dispute Form with data:'**
  String get submittingDisputeForm;

  /// No description provided for @signedUpSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signed up successfully'**
  String get signedUpSuccessfully;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurred;

  /// No description provided for @loggedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get loggedInSuccessfully;

  /// No description provided for @tanahAirServices.
  ///
  /// In en, this message translates to:
  /// **'What services does TanahAir Offer?'**
  String get tanahAirServices;

  /// No description provided for @tanahAirServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'TanahAir offers a service for creating website design, illustration, icon set, and more.'**
  String get tanahAirServiceDescription;

  /// No description provided for @whyChooseTanahAir.
  ///
  /// In en, this message translates to:
  /// **'Why should I choose a Design studio like TanahAir?'**
  String get whyChooseTanahAir;

  /// No description provided for @tanahAirAdvantage.
  ///
  /// In en, this message translates to:
  /// **'TanahAir provides the best service and solves customer problems with flexibility.'**
  String get tanahAirAdvantage;

  /// No description provided for @howTanahAirCreatesContent.
  ///
  /// In en, this message translates to:
  /// **'How does TanahAir create website content without knowing our Business plan?'**
  String get howTanahAirCreatesContent;

  /// No description provided for @tanahAirCollaboration.
  ///
  /// In en, this message translates to:
  /// **'We use collaborative tools and processes to align with the client’s vision.'**
  String get tanahAirCollaboration;

  /// No description provided for @discoverNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'Discover New Features'**
  String get discoverNewFeatures;

  /// No description provided for @exploreInnovativeTools.
  ///
  /// In en, this message translates to:
  /// **'Explore innovative tools designed to enhance your productivity'**
  String get exploreInnovativeTools;

  /// No description provided for @smartAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Smart Analytics'**
  String get smartAnalytics;

  /// No description provided for @realTimeInsights.
  ///
  /// In en, this message translates to:
  /// **'Real-time insights and data visualization for informed decisions'**
  String get realTimeInsights;

  /// No description provided for @secureAndPrivate.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get secureAndPrivate;

  /// No description provided for @enterpriseGradeSecurity.
  ///
  /// In en, this message translates to:
  /// **'Enterprise-grade security protecting your data 24/7'**
  String get enterpriseGradeSecurity;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @enterYourPhoneNumberPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumberPrompt;

  /// No description provided for @allFieldsMustBeFilled.
  ///
  /// In en, this message translates to:
  /// **'All fields must be filled'**
  String get allFieldsMustBeFilled;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @saveAllChanges.
  ///
  /// In en, this message translates to:
  /// **'Save All Changes'**
  String get saveAllChanges;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterYourNamePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourNamePrompt;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @phoneNumberIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequired;

  /// No description provided for @writeYourMessagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Write your message'**
  String get writeYourMessagePrompt;

  /// No description provided for @pleasePutYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Please put your message'**
  String get pleasePutYourMessage;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All As Read'**
  String get markAllAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications'**
  String get noNotifications;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @entityDetails.
  ///
  /// In en, this message translates to:
  /// **'Entity Details'**
  String get entityDetails;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @pleaseEnterYourReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter your reason'**
  String get pleaseEnterYourReason;

  /// No description provided for @stateYourDisputePrompt.
  ///
  /// In en, this message translates to:
  /// **'State your dispute'**
  String get stateYourDisputePrompt;

  /// No description provided for @describeYourDisputePrompt.
  ///
  /// In en, this message translates to:
  /// **'Describe your dispute'**
  String get describeYourDisputePrompt;

  /// No description provided for @pleaseDescribeYourIssue.
  ///
  /// In en, this message translates to:
  /// **'Please describe your issue'**
  String get pleaseDescribeYourIssue;

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @becomeATechnician.
  ///
  /// In en, this message translates to:
  /// **'Become a Technician'**
  String get becomeATechnician;

  /// No description provided for @loginSection.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginSection;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @savedAddress.
  ///
  /// In en, this message translates to:
  /// **'Saved Address'**
  String get savedAddress;

  /// No description provided for @accountSetting.
  ///
  /// In en, this message translates to:
  /// **'Account Setting'**
  String get accountSetting;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @freeCredit.
  ///
  /// In en, this message translates to:
  /// **'Free Credit'**
  String get freeCredit;

  /// No description provided for @onlineChat.
  ///
  /// In en, this message translates to:
  /// **'Online Chat'**
  String get onlineChat;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first to access this feature.'**
  String get pleaseLoginFirst;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get featureComingSoon;

  /// No description provided for @workingHardForFeature.
  ///
  /// In en, this message translates to:
  /// **'We are working hard to bring you this feature. Stay tuned for updates!'**
  String get workingHardForFeature;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @whatIsTaskLocation.
  ///
  /// In en, this message translates to:
  /// **'What is the task location'**
  String get whatIsTaskLocation;

  /// No description provided for @conti.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get conti;

  /// No description provided for @bookServicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Book Service'**
  String get bookServicePrompt;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @noTechniciansFound.
  ///
  /// In en, this message translates to:
  /// **'No Technicians Found'**
  String get noTechniciansFound;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No Reviews Yet'**
  String get noReviewsYet;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @weAreHereToServeYou.
  ///
  /// In en, this message translates to:
  /// **'We are here to serve you'**
  String get weAreHereToServeYou;

  /// No description provided for @serviceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Service Not Found'**
  String get serviceNotFound;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @servicesSection.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesSection;

  /// No description provided for @subcity.
  ///
  /// In en, this message translates to:
  /// **'subcity'**
  String get subcity;

  /// No description provided for @wereda.
  ///
  /// In en, this message translates to:
  /// **'wereda'**
  String get wereda;

  /// No description provided for @whatWouldYouLikeToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// No description provided for @registerAsCustomer.
  ///
  /// In en, this message translates to:
  /// **'Register as a Customer'**
  String get registerAsCustomer;

  /// No description provided for @registerAsTechnicianPrompt.
  ///
  /// In en, this message translates to:
  /// **'Register as a Technician'**
  String get registerAsTechnicianPrompt;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacyPolicy;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @registerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerPrompt;

  /// No description provided for @youNeedToLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to login first'**
  String get youNeedToLoginFirst;

  /// No description provided for @pleaseLoginFirstToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Please login first to be able to view more details'**
  String get pleaseLoginFirstToViewDetails;

  /// No description provided for @myScheduleSection.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get myScheduleSection;

  /// No description provided for @homeSection.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeSection;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSection;

  /// No description provided for @noBioAvailable.
  ///
  /// In en, this message translates to:
  /// **'No bio available'**
  String get noBioAvailable;

  /// No description provided for @seeMySchedule.
  ///
  /// In en, this message translates to:
  /// **'See my Schedule'**
  String get seeMySchedule;

  /// No description provided for @rateAndReviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'Rate and Review'**
  String get rateAndReviewPrompt;

  /// No description provided for @writeYourReviewHere.
  ///
  /// In en, this message translates to:
  /// **'Write your review here'**
  String get writeYourReviewHere;

  /// No description provided for @pleaseProvideRatingAndReviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please provide a rating and review'**
  String get pleaseProvideRatingAndReviewPrompt;

  /// No description provided for @submitReviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReviewPrompt;

  /// No description provided for @paymentSection.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentSection;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @pleaseEnterTheAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the amount'**
  String get pleaseEnterTheAmount;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @pleaseEnterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get pleaseEnterYourFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @pleaseEnterYourLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get pleaseEnterYourLastName;

  /// No description provided for @selectBank.
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get selectBank;

  /// No description provided for @pleaseSelectABank.
  ///
  /// In en, this message translates to:
  /// **'Please select a bank'**
  String get pleaseSelectABank;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @pleaseEnterYourAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your account number'**
  String get pleaseEnterYourAccountNumber;

  /// No description provided for @couldNotLaunchPaymentPage.
  ///
  /// In en, this message translates to:
  /// **'Could not launch payment page'**
  String get couldNotLaunchPaymentPage;

  /// No description provided for @failedToInitializePayment.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize payment'**
  String get failedToInitializePayment;

  /// No description provided for @verificationTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification token is required!'**
  String get verificationTokenRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long!'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @enterYourEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Email'**
  String get enterYourEmailPrompt;

  /// No description provided for @sendVerificationToken.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a verification token to reset your password.'**
  String get sendVerificationToken;

  /// No description provided for @sendToken.
  ///
  /// In en, this message translates to:
  /// **'Send Token'**
  String get sendToken;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @enterStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a strong password and confirm it below.'**
  String get enterStrongPassword;

  /// No description provided for @verificationTokenFromEmail.
  ///
  /// In en, this message translates to:
  /// **'Verification token from your email'**
  String get verificationTokenFromEmail;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordPrompt;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @backPrompt.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backPrompt;

  /// No description provided for @technicianIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Technician ID is missing'**
  String get technicianIdMissing;

  /// No description provided for @accountActivatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully activated. You can now log in and start using the app.'**
  String get accountActivatedMessage;

  /// No description provided for @logInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInPrompt;

  /// No description provided for @waitingForYourApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Your Approval'**
  String get waitingForYourApproval;

  /// No description provided for @requestBeingProcessed.
  ///
  /// In en, this message translates to:
  /// **'Your request is being processed. You will be notified once it has been approved.'**
  String get requestBeingProcessed;

  /// No description provided for @refreshStatusPrompt.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get refreshStatusPrompt;

  /// No description provided for @verificationInProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your patience. We are currently verifying your account.'**
  String get verificationInProgressMessage;

  /// No description provided for @weWillContactYou.
  ///
  /// In en, this message translates to:
  /// **'We will contact you once your verification is complete.'**
  String get weWillContactYou;

  /// No description provided for @completeYourDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Details'**
  String get completeYourDetailsPrompt;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseEnterAValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterAValidEmail;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @submitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitPrompt;

  /// No description provided for @openMailApp.
  ///
  /// In en, this message translates to:
  /// **'Open Mail App'**
  String get openMailApp;

  /// No description provided for @noMailAppsInstalled.
  ///
  /// In en, this message translates to:
  /// **'No mail apps installed'**
  String get noMailAppsInstalled;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'To continue, please verify your email by clicking the link we sent to your inbox.'**
  String get verifyEmailMessage;

  /// No description provided for @openGmail.
  ///
  /// In en, this message translates to:
  /// **'Open Gmail'**
  String get openGmail;

  /// No description provided for @resendEmailFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Resend email feature coming soon!'**
  String get resendEmailFeatureComingSoon;

  /// No description provided for @didntReceiveEmail.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Resend'**
  String get didntReceiveEmail;

  /// No description provided for @registrationFeeTransferMessage.
  ///
  /// In en, this message translates to:
  /// **'For registration fee transfer\n500 birr'**
  String get registrationFeeTransferMessage;

  /// No description provided for @uploadImagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImagePrompt;

  /// No description provided for @bookingSaved.
  ///
  /// In en, this message translates to:
  /// **'Booking Saved'**
  String get bookingSaved;

  /// No description provided for @editBooking.
  ///
  /// In en, this message translates to:
  /// **'Edit Booking'**
  String get editBooking;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Date'**
  String get scheduledDate;

  /// No description provided for @pleaseSelectADate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectADate;

  /// No description provided for @pleaseEnterACountry.
  ///
  /// In en, this message translates to:
  /// **'Please enter a country'**
  String get pleaseEnterACountry;

  /// No description provided for @saveBooking.
  ///
  /// In en, this message translates to:
  /// **'Save Booking'**
  String get saveBooking;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'coins'**
  String get coins;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful'**
  String get purchaseSuccessful;

  /// No description provided for @youHavePurchased.
  ///
  /// In en, this message translates to:
  /// **'You have purchased'**
  String get youHavePurchased;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @enterYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your message...'**
  String get enterYourMessage;

  /// No description provided for @addisAbaba.
  ///
  /// In en, this message translates to:
  /// **'Addis Ababa'**
  String get addisAbaba;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @haveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account'**
  String get haveAnAccount;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @emailOrPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone number'**
  String get emailOrPhoneNumber;

  /// No description provided for @selectServices.
  ///
  /// In en, this message translates to:
  /// **'Select Services'**
  String get selectServices;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @profileImage.
  ///
  /// In en, this message translates to:
  /// **'Profile Image'**
  String get profileImage;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;
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
      <String>['am', 'en', 'om'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
