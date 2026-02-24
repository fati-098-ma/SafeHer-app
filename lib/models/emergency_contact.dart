class EmergencyContact {
  final String name;
  final String phone;
  final String? email;
  final String? relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    this.email,
    this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      relationship: map['relationship'],
    );
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? email,
    String? relationship,
  }) {
    return EmergencyContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(name: $name, phone: $phone, email: $email, relationship: $relationship)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmergencyContact &&
        other.name == name &&
        other.phone == phone &&
        other.email == email &&
        other.relationship == relationship;
  }

  @override
  int get hashCode {
    return name.hashCode ^
    phone.hashCode ^
    email.hashCode ^
    relationship.hashCode;
  }
}