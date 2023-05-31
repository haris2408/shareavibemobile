class Cafe {
  final String id;
  final String name;
  final bool isActive;
  final int currToken;
  final int nextToken;
  final String logo;

  Cafe({
    required this.id,
    required this.name,
    required this.isActive,
    required this.currToken,
    required this.nextToken,
    required this.logo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'currToken': currToken,
      'nextToken': nextToken,
      'logo': logo,
    };
  }

  factory Cafe.fromMap(Map<String, dynamic> map) {
    return Cafe(
      id: map['id'],
      name: map['name'],
      isActive: map['isActive'],
      currToken: map['currToken'],
      nextToken: map['nextToken'],
      logo: map['logo'],
    );
  }
}