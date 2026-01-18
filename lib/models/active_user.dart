import 'package:zcatalyst_sdk/zcatalyst_sdk.dart';

class ActiveUserModel {
  final int? rowId;
  final int? creatorId;
  final String? customerOwner;
  final String? currency;
  final String? phone;
  final String? exchangeRate;
  final String? crmId;
  final String? deskId;
  final String? gender;
  final String? countryCode;
  final String? mailingStreet;
  final String? dob;
  final String? salutation;
  final bool? firstLogin;
  final String? reinviteTime;

  final String? profilePic;

  // fields from ZCatalystUser
  final String? zuid;
  final String? zaaid;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? emailId;
  final bool? isConfirmed;
  final String? status;
  final String? userType;
  final String? roleId;
  final String? roleName;
  final String? createdTime;
  final String? modifiedTime;

  ActiveUserModel({
    this.rowId,
    this.creatorId,
    this.customerOwner,
    this.currency,
    this.phone,
    this.exchangeRate,
    this.crmId,
    this.deskId,
    this.gender,
    this.countryCode,
    this.mailingStreet,
    this.dob,
    this.salutation,
    this.firstLogin,
    this.reinviteTime,

    this.profilePic,

    this.zuid,
    this.zaaid,
    this.userId,
    this.firstName,
    this.lastName,
    this.emailId,
    this.isConfirmed,
    this.status,
    this.userType,
    this.roleId,
    this.roleName,
    this.createdTime,
    this.modifiedTime,
  });

  ActiveUserModel copyWith({
    int? rowId,
    int? creatorId,
    String? customerOwner,
    String? currency,
    String? phone,
    String? exchangeRate,
    String? crmId,
    String? deskId,
    String? gender,
    String? countryCode,
    String? mailingStreet,
    String? dob,
    String? salutation,
    bool? firstLogin,
    String? reinviteTime,

    String? profilePic,

    // Catalyst fields
    String? zuid,
    String? zaaid,
    String? userId,
    String? firstName,
    String? lastName,
    String? emailId,
    bool? isConfirmed,
    String? status,
    String? userType,
    String? roleId,
    String? roleName,
    String? createdTime,
    String? modifiedTime,
  }) {
    return ActiveUserModel(
      //<return_value_field> : <parameter> ?? <instance_variable>
      rowId: rowId ?? this.rowId, //rowId (From parameter) ?? this.rowId (from object instance if parameter is not exist it will keep the old one.),
      creatorId: creatorId ?? this.creatorId,
      customerOwner: customerOwner ?? this.customerOwner,
      currency: currency ?? this.currency,
      phone: phone ?? this.phone,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      crmId: crmId ?? this.crmId,
      deskId: deskId ?? this.deskId,
      gender: gender ?? this.gender,
      countryCode: countryCode ?? this.countryCode,
      mailingStreet: mailingStreet ?? this.mailingStreet,
      dob: dob ?? this.dob,
      salutation: salutation ?? this.salutation,
      firstLogin: firstLogin ?? this.firstLogin,
      reinviteTime: reinviteTime ?? this.reinviteTime,

      profilePic: profilePic ?? this.profilePic,

      zuid: zuid ?? this.zuid,
      zaaid: zaaid ?? this.zaaid,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      emailId: emailId ?? this.emailId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      status: status ?? this.status,
      userType: userType ?? this.userType,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      createdTime: createdTime ?? this.createdTime,
      modifiedTime: modifiedTime ?? this.modifiedTime,
    );
  }

  // Factory method to create a ActiveUserModel from a ZCatalystUser
  //This method maps the fields from the ZCatalystUser to the ActiveUserModel.
  //It handles null values and ensures that the UserModel is created correctly.
  factory ActiveUserModel.fromCatalystUser(ZCatalystUser user) {
    return ActiveUserModel(
      zuid: user.zuid,
      zaaid: user.zaaid,
      userId: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      emailId: user.emailId,
      isConfirmed: user.isConfirmed,
      status: user.status,
      userType: user.userType,
      roleId: user.role?.id,
      roleName: user.role?.name,
      createdTime: user.createdTime,
      modifiedTime: user.modifiedTime,
    );
  }
}
