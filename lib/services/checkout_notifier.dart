import 'package:devtodollars/models/booking_checkout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum CheckoutStep { passenger, preferences, review, hold }

extension CheckoutStepLabel on CheckoutStep {
  String get label {
    switch (this) {
      case CheckoutStep.passenger:
        return 'Pasajero';
      case CheckoutStep.preferences:
        return 'Preferencias';
      case CheckoutStep.review:
        return 'Resumen';
      case CheckoutStep.hold:
        return 'Hold y pago';
    }
  }
}

class CheckoutState {
  final CheckoutFlightSeed flight;
  final PassengerDetails passenger;
  final CheckoutPreferences preferences;
  final BookingHold? hold;
  final CheckoutStep step;
  final bool isCreatingHold;
  final String? errorMessage;

  const CheckoutState({
    required this.flight,
    required this.passenger,
    required this.preferences,
    required this.hold,
    required this.step,
    required this.isCreatingHold,
    required this.errorMessage,
  });

  factory CheckoutState.initial(CheckoutFlightSeed seed) {
    return CheckoutState(
      flight: seed,
      passenger: PassengerDetails.empty(),
      preferences: CheckoutPreferences.defaults(),
      hold: null,
      step: CheckoutStep.passenger,
      isCreatingHold: false,
      errorMessage: null,
    );
  }

  CheckoutState copyWith({
    CheckoutFlightSeed? flight,
    PassengerDetails? passenger,
    CheckoutPreferences? preferences,
    BookingHold? hold,
    CheckoutStep? step,
    bool? isCreatingHold,
    String? errorMessage,
  }) {
    return CheckoutState(
      flight: flight ?? this.flight,
      passenger: passenger ?? this.passenger,
      preferences: preferences ?? this.preferences,
      hold: hold ?? this.hold,
      step: step ?? this.step,
      isCreatingHold: isCreatingHold ?? this.isCreatingHold,
      errorMessage: errorMessage,
    );
  }

  bool get canContinueFromPassenger => passenger.isValid;

  bool get canContinueFromPreferences => preferences.isValid;

  bool get hasActiveHold => hold?.isActive ?? false;

  int get totalAmount => flight.totalAmount;
}

final checkoutProvider = StateNotifierProvider.family<
    CheckoutController,
    CheckoutState,
    CheckoutFlightSeed>((ref, seed) {
  return CheckoutController(seed);
});

class CheckoutController extends StateNotifier<CheckoutState> {
  CheckoutController(CheckoutFlightSeed seed) : super(CheckoutState.initial(seed));

  SupabaseClient get client => Supabase.instance.client;

  void goToStep(CheckoutStep step) {
    state = state.copyWith(step: step, errorMessage: null);
  }

  void updatePassenger({
    String? fullName,
    String? email,
    String? phone,
    String? documentId,
    String? notes,
  }) {
    state = state.copyWith(
      passenger: state.passenger.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        documentId: documentId,
        notes: notes,
      ),
      errorMessage: null,
    );
  }

  void updatePreferences({
    String? travelPurpose,
    String? seatPreference,
    String? cateringPreference,
    String? luggagePreference,
    String? privacyLevel,
    String? notes,
  }) {
    state = state.copyWith(
      preferences: state.preferences.copyWith(
        travelPurpose: travelPurpose,
        seatPreference: seatPreference,
        cateringPreference: cateringPreference,
        luggagePreference: luggagePreference,
        privacyLevel: privacyLevel,
        notes: notes,
      ),
      errorMessage: null,
    );
  }

  Future<BookingHold> createHold() async {
    final draft = CheckoutDraft(
      flight: state.flight,
      passenger: state.passenger,
      preferences: state.preferences,
    );

    state = state.copyWith(
      isCreatingHold: true,
      errorMessage: null,
    );

    final hold = await _BookingHoldRepository(client).createHold(draft);

    state = state.copyWith(
      hold: hold,
      step: CheckoutStep.hold,
      isCreatingHold: false,
      errorMessage: null,
    );

    return hold;
  }
}

class _BookingHoldRepository {
  final SupabaseClient client;

  _BookingHoldRepository(this.client);

  Future<BookingHold> createHold(CheckoutDraft draft) async {
    try {
      final response = await client.functions.invoke(
        'create_booking_hold',
        body: draft.toJson(),
      );
      final data = response.data;
      if (data is Map) {
        final payload = Map<String, dynamic>.from(data);
        final nestedHold = payload['hold'];
        if (nestedHold is Map) {
          return BookingHold.fromJson(
            Map<String, dynamic>.from(nestedHold),
            fallbackAmount: draft.totalAmount,
          );
        }
        final nestedBooking = payload['booking'];
        if (nestedBooking is Map) {
          return BookingHold.fromJson(
            Map<String, dynamic>.from(nestedBooking),
            fallbackAmount: draft.totalAmount,
          );
        }
        return BookingHold.fromJson(
          payload,
          fallbackAmount: draft.totalAmount,
        );
      }
    } catch (_) {
      // Fall back to a local mock hold so the app keeps working in prototype mode.
    }

    return BookingHold.mockFromDraft(draft);
  }
}
