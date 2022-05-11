class UserModel{
  String? name;
  String? email;
  String? phone;
  double? lat;
  double? long;
  String? uId;
  bool? client;

  UserModel({
    this.phone,
    this.email,
    this.name,
    this.lat,
    this.long,
    this.uId,
    this.client,
});

  UserModel.fromJson(Map <String,dynamic>json){
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    lat = json['lat'];
    long = json['long'];
    uId = json['uId'];
    client = json['client'];
  }

  Map <String,dynamic>toMap(){
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'lat': lat,
      'long': long,
      'uId': uId,
      'client': client,
    };
  }
}