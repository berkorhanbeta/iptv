class IptvModel {

  String? name;
  String? logo;
  String? groupTitle;
  String? referrer;
  String? url;

  IptvModel({this.name, this.logo, this.groupTitle, this.referrer, this.url});

  factory IptvModel.fromJson(Map<String, dynamic> json) {
    return IptvModel(
      name: json['name'],
      logo: json['logo'],
      groupTitle: json['groupTitle'],
      referrer: json['referrer'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'groupTitle': groupTitle,
      'referrer': referrer,
      'url': url,
    };
  }

}