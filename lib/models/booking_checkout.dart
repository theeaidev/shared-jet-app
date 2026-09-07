import 'dart:math';

class CheckoutFlightSeed {
  final String origin;
  final String destination;
  final String dateLabel;
  final bool isRoundTrip;
  final bool isFlexibleDate;
  final int passengers;
  final double budget;
  final bool onlyEmptyLegs;
  final bool nearbyAirports;
  final String travelPreference;
  final int score;
  final int basePrice;
  final String status;
  final Map<String, String> analysis;

  const CheckoutFlightSeed({
    required this.origin,
    required this.destination,
    required this.dateLabel,
    required this.isRoundTrip,
    required this.isFlexibleDate,
    required this.passengers,
    required this.budget,
    required this.onlyEmptyLegs,
    required this.nearbyAirports,
    required this.travelPreference,
    required this.score,
    required this.basePrice,
    required this.status,
    required this.analysis,
  });

  factory CheckoutFlightSeed.fromSearchResult({
    required Map<String, dynamic> result,
    required String origin,
    required String destination,
    required String dateLabel,
    required bool isRoundTrip,
    required bool isFlexibleDate,
    required int passengers,
    required double budget,
    required bool onlyEmptyLegs,
    required bool nearbyAirports,
    required String travelPreference,
  }) {
    final rawDetails = result['details'];
    final details = <String, String>{};
    if (rawDetails is Map) {
      rawDetails.forEach((key, value) {
        details[key.toString()] = value.toString();
      });
    }

    return CheckoutFlightSeed(
      origin: origin,
      destination: destination,
      dateLabel: dateLabel,
      isRoundTrip: isRoundTrip,
      isFlexibleDate: isFlexibleDate,
      passengers: passengers,
      budget: budget,
      onlyEmptyLegs: onlyEmptyLegs,
      nearbyAirports: nearbyAirports,
      travelPreference: travelPreference,
      score: (result['score'] as num?)?.toInt() ?? 0,
      basePrice: (result['price'] as num?)?.toInt() ?? 0,
      status: result['status']?.toString() ?? 'Pendiente',
      analysis: details,
    );
  }

  factory CheckoutFlightSeed.fromQueryParameters(Map<String, String> params) {
    return CheckoutFlightSeed(
      origin: params['origin'] ?? 'Madrid',
      destination: params['destination'] ?? 'Ibiza',
      dateLabel: params['date'] ?? 'Pronto',
      isRoundTrip: params['round_trip'] == 'true',
      isFlexibleDate: params['flexible_date'] == 'true',
      passengers: int.tryParse(params['passengers'] ?? '') ?? 1,
      budget: double.tryParse(params['budget'] ?? '') ?? 5000,
      onlyEmptyLegs: params['only_empty_legs'] == 'true',
      nearbyAirports: params['nearby_airports'] == 'true',
      travelPreference: params['preference'] ?? 'Negocio',
      score: int.tryParse(params['score'] ?? '') ?? 0,
      basePrice: int.tryParse(params['price'] ?? '') ?? 0,
      status: params['status'] ?? 'Ruta en formación',
      analysis: const {},
    );
  }

  factory CheckoutFlightSeed.fallback() {
    return const CheckoutFlightSeed(
      origin: 'Madrid',
      destination: 'Ibiza',
      dateLabel: 'Pronto',
      isRoundTrip: false,
      isFlexibleDate: false,
      passengers: 1,
      budget: 5000,
      onlyEmptyLegs: false,
      nearbyAirports: false,
      travelPreference: 'Negocio',
      score: 98,
      basePrice: 1800,
      status: 'Ruta en formación',
      analysis: {
        'Ruta': 'Coincidencia exacta con pasajeros compatibles.',
        'Fechas': 'Ventana de reserva abierta.',
        'Asientos': 'Plazas sujetas a hold temporal.',
      },
    );
  }

  Map<String, String> toQueryParameters() {
    return {
      'origin': origin,
      'destination': destination,
      'date': dateLabel,
      'round_trip': isRoundTrip.toString(),
      'flexible_date': isFlexibleDate.toString(),
      'passengers': passengers.toString(),
      'budget': budget.toStringAsFixed(0),
      'only_empty_legs': onlyEmptyLegs.toString(),
      'nearby_airports': nearbyAirports.toString(),
      'preference': travelPreference,
      'score': score.toString(),
      'price': basePrice.toString(),
      'status': status,
    };
  }

  int get serviceFee => max(75, (basePrice * 0.06).round());

  int get totalAmount => basePrice + serviceFee;

  CheckoutFlightSeed copyWith({
    String? origin,
    String? destination,
    String? dateLabel,
    bool? isRoundTrip,
    bool? isFlexibleDate,
    int? passengers,
    double? budget,
    bool? onlyEmptyLegs,
    bool? nearbyAirports,
    String? travelPreference,
    int? score,
    int? basePrice,
    String? status,
    Map<String, String>? analysis,
  }) {
    return CheckoutFlightSeed(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      dateLabel: dateLabel ?? this.dateLabel,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      isFlexibleDate: isFlexibleDate ?? this.isFlexibleDate,
      passengers: passengers ?? this.passengers,
      budget: budget ?? this.budget,
      onlyEmptyLegs: onlyEmptyLegs ?? this.onlyEmptyLegs,
      nearbyAirports: nearbyAirports ?? this.nearbyAirports,
      travelPreference: travelPreference ?? this.travelPreference,
      score: score ?? this.score,
      basePrice: basePrice ?? this.basePrice,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CheckoutFlightSeed &&
        other.origin == origin &&
        other.destination == destination &&
        other.dateLabel == dateLabel &&
        other.isRoundTrip == isRoundTrip &&
        other.isFlexibleDate == isFlexibleDate &&
        other.passengers == passengers &&
        other.budget == budget &&
        other.onlyEmptyLegs == onlyEmptyLegs &&
        other.nearbyAirports == nearbyAirports &&
        other.travelPreference == travelPreference &&
        other.score == score &&
        other.basePrice == basePrice &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(
        origin,
        destination,
        dateLabel,
        isRoundTrip,
        isFlexibleDate,
        passengers,
        budget,
        onlyEmptyLegs,
        nearbyAirports,
        travelPreference,
        score,
        basePrice,
        status,
      );
}

class PassengerDetails {
  final String fullName;
  final String email;
  final String phone;
  final String documentId;
  final String notes;

  const PassengerDetails({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.documentId,
    required this.notes,
  });

  factory PassengerDetails.empty() {
    return const PassengerDetails(
      fullName: '',
      email: '',
      phone: '',
      documentId: '',
      notes: '',
    );
  }

  bool get isValid =>
      fullName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      RegExp(r'^\S+@\S+\.\S+$').hasMatch(email.trim());

  PassengerDetails copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? documentId,
    String? notes,
  }) {
    return PassengerDetails(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      documentId: documentId ?? this.documentId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'document_id': documentId,
      'notes': notes,
    };
  }
}

class CheckoutPreferences {
  final String travelPurpose;
  final String seatPreference;
  final String cateringPreference;
  final String luggagePreference;
  final String privacyLevel;
  final String notes;

  const CheckoutPreferences({
    required this.travelPurpose,
    required this.seatPreference,
    required this.cateringPreference,
    required this.luggagePreference,
    required this.privacyLevel,
    required this.notes,
  });

  factory CheckoutPreferences.defaults() {
    return const CheckoutPreferences(
      travelPurpose: 'Negocio',
      seatPreference: 'Ventana',
      cateringPreference: 'Standard',
      luggagePreference: 'Cabina',
      privacyLevel: 'Discreta',
      notes: '',
    );
  }

  bool get isValid => travelPurpose.isNotEmpty && seatPreference.isNotEmpty;

  CheckoutPreferences copyWith({
    String? travelPurpose,
    String? seatPreference,
    String? cateringPreference,
    String? luggagePreference,
    String? privacyLevel,
    String? notes,
  }) {
    return CheckoutPreferences(
      travelPurpose: travelPurpose ?? this.travelPurpose,
      seatPreference: seatPreference ?? this.seatPreference,
      cateringPreference: cateringPreference ?? this.cateringPreference,
      luggagePreference: luggagePreference ?? this.luggagePreference,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travel_purpose': travelPurpose,
      'seat_preference': seatPreference,
      'catering_preference': cateringPreference,
      'luggage_preference': luggagePreference,
      'privacy_level': privacyLevel,
      'notes': notes,
    };
  }
}

class CheckoutDraft {
  final CheckoutFlightSeed flight;
  final PassengerDetails passenger;
  final CheckoutPreferences preferences;

  const CheckoutDraft({
    required this.flight,
    required this.passenger,
    required this.preferences,
  });

  int get baseAmount => flight.basePrice;

  int get serviceFee => flight.serviceFee;

  int get totalAmount => flight.totalAmount;

  Map<String, dynamic> toJson() {
    return {
      'flight': {
        ...flight.toQueryParameters(),
        'analysis': flight.analysis,
      },
      'passenger': passenger.toJson(),
      'preferences': preferences.toJson(),
      'price_breakdown': {
        'base_amount': baseAmount,
        'service_fee': serviceFee,
        'total_amount': totalAmount,
      },
    };
  }
}

class BookingHold {
  final String holdId;
  final String bookingId;
  final DateTime expiresAt;
  final String status;
  final int totalAmount;
  final String currency;

  const BookingHold({
    required this.holdId,
    required this.bookingId,
    required this.expiresAt,
    required this.status,
    required this.totalAmount,
    required this.currency,
  });

  factory BookingHold.fromJson(Map<String, dynamic> json, {int? fallbackAmount}) {
    final expiresAtRaw = json['expires_at'] ?? json['expiresAt'];
    final expiresAt = expiresAtRaw is String
        ? DateTime.tryParse(expiresAtRaw) ?? DateTime.now().add(const Duration(minutes: 10))
        : DateTime.now().add(const Duration(minutes: 10));
    final totalAmountRaw = json['total_amount'] ?? json['totalAmount'] ?? fallbackAmount ?? 0;
    final totalAmount = totalAmountRaw is num
        ? totalAmountRaw.toInt()
        : int.tryParse(totalAmountRaw.toString()) ?? (fallbackAmount ?? 0);

    return BookingHold(
      holdId: (json['hold_id'] ?? json['holdId'] ?? json['id'] ?? json['booking_intent_id'] ?? 'hold_${DateTime.now().millisecondsSinceEpoch}').toString(),
      bookingId: (json['booking_id'] ?? json['bookingId'] ?? json['booking_intent_id'] ?? json['id'] ?? 'booking_${DateTime.now().millisecondsSinceEpoch}').toString(),
      expiresAt: expiresAt,
      status: (json['status'] ?? 'active').toString(),
      totalAmount: totalAmount,
      currency: (json['currency'] ?? 'usd').toString(),
    );
  }

  factory BookingHold.mockFromDraft(CheckoutDraft draft) {
    final now = DateTime.now();
    return BookingHold(
      holdId: 'hold_${now.microsecondsSinceEpoch}',
      bookingId: 'booking_${now.microsecondsSinceEpoch}',
      expiresAt: now.add(const Duration(minutes: 10)),
      status: 'active',
      totalAmount: draft.totalAmount,
      currency: 'usd',
    );
  }

  bool get isActive =>
      status == 'active' && expiresAt.isAfter(DateTime.now());

  Duration remaining(Duration referenceOffset) {
    return expiresAt.difference(DateTime.now().add(referenceOffset));
  }

  Map<String, dynamic> toJson() {
    return {
      'hold_id': holdId,
      'booking_id': bookingId,
      'expires_at': expiresAt.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'currency': currency,
    };
  }
}
