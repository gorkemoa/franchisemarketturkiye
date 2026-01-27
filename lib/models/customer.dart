class Customer {
  final String? id;
  final String? firstname;
  final String? lastname;
  final String? phone;
  final String? email;
  final String? city;
  final String? district;
  final String? neighbourhood;
  final String? street;
  final String? address;
  final String? newsletter;
  final String? status;
  final DateTime? dateAdded;

  Customer({
    this.id,
    this.firstname,
    this.lastname,
    this.phone,
    this.email,
    this.city,
    this.district,
    this.neighbourhood,
    this.street,
    this.address,
    this.newsletter,
    this.status,
    this.dateAdded,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      phone: json['phone'],
      email: json['email'],
      city: json['city'],
      district: json['district'],
      neighbourhood: json['neighbourhood'],
      street: json['street'],
      address: json['address'],
      newsletter: json['newsletter'],
      status: json['status'],
      dateAdded: json['date_added'] != null
          ? DateTime.parse(json['date_added'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'email': email,
      'city': city,
      'district': district,
      'neighbourhood': neighbourhood,
      'street': street,
      'address': address,
      'newsletter': newsletter,
      'status': status,
      'date_added': dateAdded?.toIso8601String(),
    };
  }
}
