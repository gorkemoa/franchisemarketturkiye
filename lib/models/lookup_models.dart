class City {
  final String id;
  final String name;
  final String plate;

  City({required this.id, required this.name, required this.plate});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['id'], name: json['name'], plate: json['plate']);
  }
}

class District {
  final String id;
  final String name;
  final String cityId;

  District({required this.id, required this.name, required this.cityId});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      cityId: json['city_id'],
    );
  }
}
