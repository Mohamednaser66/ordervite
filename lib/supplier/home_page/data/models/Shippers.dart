class Shipper {
  final int id;
  final String name;
  final String email;
  final dynamic emailVerifiedAt;
  final dynamic cPassword;
  final String apiToken;
  final String mobile1;
  final String mobile2;
  final dynamic logoId;
  final int verified;
  final dynamic idImageId;
  final double regLongitude;
  final double regLatitude;
  final double curLongitude;
  final double curLatitude;
  final String createdAt;
  final String updatedAt;

  Shipper({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.cPassword,
    required this.apiToken,
    required this.mobile1,
    required this.mobile2,
    required this.logoId,
    required this.verified,
    required this.idImageId,
    required this.regLongitude,
    required this.regLatitude,
    required this.curLongitude,
    required this.curLatitude,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shipper.fromJson(Map<String, dynamic> json) {
    return Shipper(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      cPassword: json['c_password'],
      apiToken: json['api_token'],
      mobile1: json['mobile1'],
      mobile2: json['mobile2'],
      logoId: json['logo_id'],
      verified: json['verified'],
      idImageId: json['id_image_id'],
      regLongitude: double.parse(json['reg_longitude'].toString()),
      regLatitude: double.parse(json['reg_latitude'].toString()),
      curLongitude: double.parse(json['cur_longitude'].toString()),
      curLatitude: double.parse(json['cur_latitude'].toString()),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

}