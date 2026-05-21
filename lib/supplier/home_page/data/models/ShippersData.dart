import 'ShippersData.dart';

/// data : [{"id":2,"name":"mahmoud","email":"mahmoud@yahoo.com","email_verified_at":null,"c_password":null,"api_token":"cKYqvfGuTYaICxOW4p07K0:APA91bF_r_9QsUFUx5-r-PYxGcoDZQBC19eIH1f-c0uLvsEGk4MTgxF4aeNwLT2XhCj1FRE_yxADo5ecHqEpy1HbGpyN6KNkaO8U8LaT9giRljB1xFPUEWA","mobile1":"01157292169","mobile2":"01157292169","logo_id":null,"verified":1,"id_image_id":null,"reg_longitude":31.1934064000000006444679456762969493865966796875,"reg_latitude":30.059127000000000151658241520635783672332763671875,"cur_longitude":31.1933681000000007088601705618202686309814453125,"cur_latitude":30.059107999999998384055288624949753284454345703125,"created_at":"2025-12-31 14:27:34","updated_at":"2026-01-11 12:52:53"},{"id":25,"name":"youssef","email":"youssef@gmail.com","email_verified_at":null,"c_password":null,"api_token":"euyfwRCcSDKntbysU7QG15:APA91bEDQL3PVnu6ey7NZAaihPLqfLla6JPf3QJMOJPvDnGIzUgsKElVwZptKXDyOCWAnDl8z3UnfzYH7kdpqB10kZafQ2dXf8HTJueZZFbr72ZTrYFMp4HDjqXww6sB7SUFnFr6E7R-","mobile1":"01141608518","mobile2":"01141608518","logo_id":63,"verified":1,"id_image_id":64,"reg_longitude":31.19356559999999944921000860631465911865234375,"reg_latitude":30.059204300000001097714630304835736751556396484375,"cur_longitude":31.193513100000000548561729374341666698455810546875,"cur_latitude":30.05928850000000096542862593196332454681396484375,"created_at":"2021-06-29 10:54:03","updated_at":"2022-02-27 11:30:03"},{"id":27,"name":"app","email":"app@gmail.com","email_verified_at":null,"c_password":null,"api_token":"c0Edgf2NRI6h0204Kh7aLF:APA91bH80OZD-1Rgxd5cwRNCdXKsbtQXOtog7iI3Uxz0grHnogohFip_mp0I7MrR4RcKIEbnL8eP5h7531avjWOri-DEBCz-dqXQBVUAl75oARQpu_ux2mCL0YpcijMrM48VlOCdaM-e","mobile1":"01141608518","mobile2":"01002745304","logo_id":null,"verified":1,"id_image_id":null,"reg_longitude":31.193420100000000871887095854617655277252197265625,"reg_latitude":30.05922199999999833153196959756314754486083984375,"cur_longitude":31.1934715000000011286829249002039432525634765625,"cur_latitude":30.059215800000000484715201309882104396820068359375,"created_at":"2021-07-04 09:31:18","updated_at":"2021-12-16 09:37:53"},{"id":33,"name":"Guest","email":"GuestShipper@ordervite.com","email_verified_at":null,"c_password":null,"api_token":"f_iOr2se_EH_ty6xcWjg2r:APA91bEsgyWnfiKTFLUJVNSqUi4GHSSJar40TyD5BXaPfvDEBaxA1FuPydUbr5iZ78TD8ZLHMrr8HuOq7zM728xsKmNLhNJ56dkUrQXD2IGDYrsz6bkKbp4","mobile1":"01067207435","mobile2":"01067207435","logo_id":71,"verified":1,"id_image_id":72,"reg_longitude":46.669124600000003511013346724212169647216796875,"reg_latitude":24.720905599999998258908817660994827747344970703125,"cur_longitude":31.193499599999999105648385011591017246246337890625,"cur_latitude":30.0591419000000001915395841933786869049072265625,"created_at":"2026-03-19 09:35:10","updated_at":"2026-05-13 09:58:12"}]

class ShippersData {
  ShippersData({
      this.data,});

  ShippersData.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ShippersData.fromJson(v));
      });
    }
  }
  List<ShippersData>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}