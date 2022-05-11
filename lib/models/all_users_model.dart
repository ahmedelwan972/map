
class AllUsersModel{
  String? name;
  String? phone;
  String? uId;
  double? lat;
  double? long;
  bool? client;

  AllUsersModel.fromJson(Map<String,dynamic>json){
    name = json['name'];
    phone = json['phone'];
    uId = json['uId'];
    lat = json['lat'];
    long = json['long'];
    client = json['client'];
  }
}