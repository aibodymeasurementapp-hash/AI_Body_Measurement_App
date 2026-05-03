class Measurement {
  final String id;
  final double height;
  final double shirtLength;
  final double waist;
  final double chest;
  final double shoulder;
  final double sleevesLength;
  final double inseam;
  final String additionalInstructions;
  final DateTime createdAt;

  Measurement({
    required this.id,
    required this.height,
    required this.shirtLength,
    required this.waist,
    required this.chest,
    required this.shoulder,
    required this.sleevesLength,
    required this.inseam,
    required this.additionalInstructions,
    required this.createdAt,
  });

  Measurement copyWith({
    String? id,
    double? height,
    double? shirtLength,
    double? waist,
    double? chest,
    double? shoulder,
    double? sleevesLength,
    double? inseam,
    String? additionalInstructions,
    DateTime? createdAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      height: height ?? this.height,
      shirtLength: shirtLength ?? this.shirtLength,
      waist: waist ?? this.waist,
      chest: chest ?? this.chest,
      shoulder: shoulder ?? this.shoulder,
      sleevesLength: sleevesLength ?? this.sleevesLength,
      inseam: inseam ?? this.inseam,
      additionalInstructions: additionalInstructions ?? this.additionalInstructions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MeasurementResult {
  final String id;
  final double shoulderWidth;
  final double chest;
  final double waist;
  final double leftArmLength;
  final double rightArmLength;
  final double leftLegLength;
  final double rightLegLength;
  final double height;
  final double upperBodyLength;
  final double lowerBodyLength;
  final DateTime createdAt;

  MeasurementResult({
    required this.id,
    required this.shoulderWidth,
    required this.chest,
    required this.waist,
    required this.leftArmLength,
    required this.rightArmLength,
    required this.leftLegLength,
    required this.rightLegLength,
    required this.height,
    required this.upperBodyLength,
    required this.lowerBodyLength,
    required this.createdAt,
  });
}