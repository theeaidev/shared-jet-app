import 'dart:async';
import 'dart:ui';

import 'package:devtodollars/models/booking_checkout.dart';
import 'package:devtodollars/services/checkout_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final CheckoutFlightSeed seed;

  const CheckoutScreen({super.key, required this.seed});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _passengerFormKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _documentController;
  late final TextEditingController _notesController;

  late String _travelPurpose;
  late String _seatPreference;
  late String _cateringPreference;
  late String _luggagePreference;
  late String _privacyLevel;
  late final TextEditingController _preferenceNotesController;

  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  final List<String> _travelPurposes = const [
    'Negocio',
    'Ocio',
    'Networking',
    'Máxima privacidad',
  ];

  final List<String> _seatPreferences = const [
    'Ventana',
    'Pasillo',
    'Cualquiera',
  ];

  final List<String> _cateringOptions = const [
    'Standard',
    'Vegetariano',
    'Premium',
  ];

  final List<String> _luggageOptions = const [
    'Cabina',
    'Cabina + facturado',
    'Solo cabina',
  ];

  final List<String> _privacyOptions = const [
    'Discreta',
    'Compartida',
    'Máxima privacidad',
  ];

  @override
  void initState() {
    super.initState();
    final checkoutState = ref.read(checkoutProvider(widget.seed));
    final currentUserEmail = Supabase.instance.client.auth.currentUser?.email ?? '';

    _fullNameController = TextEditingController(text: checkoutState.passenger.fullName);
    _emailController = TextEditingController(
      text: checkoutState.passenger.email.isNotEmpty
          ? checkoutState.passenger.email
          : currentUserEmail,
    );
    _phoneController = TextEditingController(text: checkoutState.passenger.phone);
    _documentController = TextEditingController(text: checkoutState.passenger.documentId);
    _notesController = TextEditingController(text: checkoutState.passenger.notes);

    _travelPurpose = checkoutState.preferences.travelPurpose;
    _seatPreference = checkoutState.preferences.seatPreference;
    _cateringPreference = checkoutState.preferences.cateringPreference;
    _luggagePreference = checkoutState.preferences.luggagePreference;
    _privacyLevel = checkoutState.preferences.privacyLevel;
    _preferenceNotesController = TextEditingController(text: checkoutState.preferences.notes);

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    _notesController.dispose();
    _preferenceNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider(widget.seed));
    final controller = ref.read(checkoutProvider(widget.seed).notifier);
    final hold = checkoutState.hold;
    final remaining = hold == null ? Duration.zero : hold.expiresAt.difference(_now);
    final clampedRemaining = remaining.isNegative ? Duration.zero : remaining;
    final isHoldExpired = hold != null && !hold.isActive;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Checkout guiado',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/luxury_jet_bg.png',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 760),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(checkoutState),
                      const SizedBox(height: 20),
                      _buildStepProgress(checkoutState),
                      const SizedBox(height: 20),
                      if (checkoutState.errorMessage != null) ...[
                        _buildErrorBanner(checkoutState.errorMessage!),
                        const SizedBox(height: 16),
                      ],
                      if (checkoutState.isCreatingHold) ...[
                        const LinearProgressIndicator(minHeight: 3),
                        const SizedBox(height: 16),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildStepContent(
                          context: context,
                          checkoutState: checkoutState,
                          controller: controller,
                          hold: hold,
                          remaining: clampedRemaining,
                          isHoldExpired: isHoldExpired,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flight_takeoff, color: Color(0xFFD4AF37), size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${state.flight.origin} → ${state.flight.destination}',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${state.flight.score}%',
              style: GoogleFonts.lato(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${state.flight.dateLabel} • ${state.flight.status} • ${state.flight.travelPreference}',
          style: GoogleFonts.lato(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStepProgress(CheckoutState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (state.step.index + 1) / CheckoutStep.values.length,
          minHeight: 6,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
          borderRadius: BorderRadius.circular(100),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CheckoutStep.values.map((step) {
            final isActive = step.index <= state.step.index;
            final isCurrent = step == state.step;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Colors.black87
                    : isActive
                        ? const Color(0xFF2B2B2B)
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${step.index + 1}. ${step.label}',
                style: GoogleFonts.lato(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.lato(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent({
    required BuildContext context,
    required CheckoutState checkoutState,
    required CheckoutController controller,
    required BookingHold? hold,
    required Duration remaining,
    required bool isHoldExpired,
  }) {
    switch (checkoutState.step) {
      case CheckoutStep.passenger:
        return _buildPassengerStep(context, controller);
      case CheckoutStep.preferences:
        return _buildPreferencesStep(context, controller);
      case CheckoutStep.review:
        return _buildReviewStep(context, checkoutState, controller);
      case CheckoutStep.hold:
        return _buildHoldStep(
          context,
          checkoutState,
          controller,
          hold: hold,
          remaining: remaining,
          isHoldExpired: isHoldExpired,
        );
    }
  }

  Widget _buildPassengerStep(BuildContext context, CheckoutController controller) {
    return Form(
      key: _passengerFormKey,
      child: Column(
        key: const ValueKey('passenger_step'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '1. Datos del pasajero',
            style: GoogleFonts.playfairDisplay(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Necesitamos los datos mínimos para mantener la plaza y preparar el pago.',
            style: GoogleFonts.lato(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _fullNameController,
            decoration: _fieldDecoration(
              label: 'Nombre completo',
              icon: Icons.badge_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Introduce el nombre completo';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            decoration: _fieldDecoration(
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return 'Introduce un email';
              }
              if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(text)) {
                return 'Introduce un email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            decoration: _fieldDecoration(
              label: 'Teléfono',
              icon: Icons.phone_outlined,
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().length < 6) {
                return 'Introduce un teléfono válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _documentController,
            decoration: _fieldDecoration(
              label: 'Documento o pasaporte',
              icon: Icons.document_scanner_outlined,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: _fieldDecoration(
              label: 'Observaciones',
              icon: Icons.notes_outlined,
            ).copyWith(
              hintText: 'Dietas, acompañantes, movilidad, etc.',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black26),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (!_passengerFormKey.currentState!.validate()) {
                      return;
                    }
                    controller.updatePassenger(
                      fullName: _fullNameController.text.trim(),
                      email: _emailController.text.trim(),
                      phone: _phoneController.text.trim(),
                      documentId: _documentController.text.trim(),
                      notes: _notesController.text.trim(),
                    );
                    controller.goToStep(CheckoutStep.preferences);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep(BuildContext context, CheckoutController controller) {
    return Column(
      key: const ValueKey('preferences_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '2. Preferencias de viaje',
          style: GoogleFonts.playfairDisplay(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nos ayuda a afinar la propuesta y a ofrecerte una experiencia más coherente.',
          style: GoogleFonts.lato(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        _chipSection(
          title: 'Motivo del viaje',
          values: _travelPurposes,
          selected: _travelPurpose,
          onSelected: (value) => setState(() => _travelPurpose = value),
        ),
        const SizedBox(height: 18),
        _chipSection(
          title: 'Preferencia de asiento',
          values: _seatPreferences,
          selected: _seatPreference,
          onSelected: (value) => setState(() => _seatPreference = value),
        ),
        const SizedBox(height: 18),
        _dropdownField(
          label: 'Tipo de catering',
          value: _cateringPreference,
          items: _cateringOptions,
          onChanged: (value) => setState(() => _cateringPreference = value),
        ),
        const SizedBox(height: 18),
        _dropdownField(
          label: 'Equipaje',
          value: _luggagePreference,
          items: _luggageOptions,
          onChanged: (value) => setState(() => _luggagePreference = value),
        ),
        const SizedBox(height: 18),
        _chipSection(
          title: 'Nivel de privacidad',
          values: _privacyOptions,
          selected: _privacyLevel,
          onSelected: (value) => setState(() => _privacyLevel = value),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _preferenceNotesController,
          maxLines: 3,
          decoration: _fieldDecoration(
            label: 'Notas de preferencia',
            icon: Icons.tune_outlined,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.goToStep(CheckoutStep.passenger),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black26),
                ),
                child: const Text('Atrás'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (!_savePreferences(controller)) {
                    return;
                  }
                  controller.goToStep(CheckoutStep.review);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Revisar resumen',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStep(
    BuildContext context,
    CheckoutState checkoutState,
    CheckoutController controller,
  ) {
    final draft = CheckoutDraft(
      flight: checkoutState.flight,
      passenger: checkoutState.passenger,
      preferences: checkoutState.preferences,
    );

    return Column(
      key: const ValueKey('review_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '3. Revisión del resumen',
          style: GoogleFonts.playfairDisplay(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Antes de bloquear la plaza, revisa que el trayecto y las preferencias sean correctas.',
          style: GoogleFonts.lato(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        _summaryCard(
          title: 'Trayecto',
          children: [
            _summaryRow('Ruta', '${checkoutState.flight.origin} → ${checkoutState.flight.destination}'),
            _summaryRow('Fecha', checkoutState.flight.dateLabel),
            _summaryRow('Pasajeros', checkoutState.flight.passengers.toString()),
            _summaryRow('Preferencia', checkoutState.flight.travelPreference),
            _summaryRow('Estado', checkoutState.flight.status),
          ],
        ),
        const SizedBox(height: 16),
        _summaryCard(
          title: 'Pasajero',
          children: [
            _summaryRow('Nombre', checkoutState.passenger.fullName),
            _summaryRow('Email', checkoutState.passenger.email),
            _summaryRow('Teléfono', checkoutState.passenger.phone),
            if (checkoutState.passenger.documentId.trim().isNotEmpty)
              _summaryRow('Documento', checkoutState.passenger.documentId),
          ],
        ),
        const SizedBox(height: 16),
        _summaryCard(
          title: 'Preferencias',
          children: [
            _summaryRow('Motivo', checkoutState.preferences.travelPurpose),
            _summaryRow('Asiento', checkoutState.preferences.seatPreference),
            _summaryRow('Catering', checkoutState.preferences.cateringPreference),
            _summaryRow('Equipaje', checkoutState.preferences.luggagePreference),
            _summaryRow('Privacidad', checkoutState.preferences.privacyLevel),
          ],
        ),
        const SizedBox(height: 16),
        _summaryCard(
          title: 'Precio',
          children: [
            _summaryRow('Precio base', '\$${draft.baseAmount}'),
            _summaryRow('Servicio', '\$${draft.serviceFee}'),
            _summaryRow('Total estimado', '\$${draft.totalAmount}'),
          ],
        ),
        const SizedBox(height: 16),
        _summaryCard(
          title: 'Políticas',
          children: const [
            Text(
              'El hold temporal reserva tu plaza durante 10 minutos. Si expira, tendrás que volver a confirmarlo antes del pago.',
            ),
            SizedBox(height: 8),
            Text(
              'Las condiciones finales de cancelación y cambios dependen del operador y se muestran de nuevo en Stripe.',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.goToStep(CheckoutStep.preferences),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black26),
                ),
                child: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: checkoutState.isCreatingHold
                    ? null
                    : () async {
                        await controller.createHold();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  checkoutState.isCreatingHold
                      ? 'Bloqueando plaza...'
                      : 'Bloquear plaza y continuar',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHoldStep(
    BuildContext context,
    CheckoutState checkoutState,
    CheckoutController controller, {
    required BookingHold? hold,
    required Duration remaining,
    required bool isHoldExpired,
  }) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60).abs();

    return Column(
      key: const ValueKey('hold_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '4. Hold temporal y pago final',
          style: GoogleFonts.playfairDisplay(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu plaza está bloqueada. Ahora puedes ir a Stripe con la reserva asociada.',
          style: GoogleFonts.lato(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        _summaryCard(
          title: 'Hold activo',
          children: [
            _summaryRow('Hold ID', hold?.holdId ?? 'Pendiente'),
            _summaryRow('Booking ID', hold?.bookingId ?? 'Pendiente'),
            _summaryRow(
              'Expira en',
              isHoldExpired
                  ? 'Expirado'
                  : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            ),
            _summaryRow('Importe total', '\$${checkoutState.totalAmount}'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHoldExpired ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHoldExpired ? Colors.red.shade200 : Colors.green.shade200,
            ),
          ),
          child: Text(
            isHoldExpired
                ? 'El hold expiró. Vuelve a crear uno nuevo antes de pagar.'
                : 'La plaza está reservada durante unos minutos. Ve a pago antes de que se libere.',
            style: GoogleFonts.lato(
              color: isHoldExpired ? Colors.red.shade800 : Colors.green.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.goToStep(CheckoutStep.review),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black26),
                ),
                child: const Text('Volver'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isHoldExpired || hold == null
                    ? null
                    : () {
                        context.goNamed(
                          'payments',
                          queryParameters: {
                            'price': checkoutState.totalAmount.toString(),
                            'hold_id': hold.holdId,
                            'booking_id': hold.bookingId,
                            'expires_at': hold.expiresAt.toIso8601String(),
                            'origin': checkoutState.flight.origin,
                            'destination': checkoutState.flight.destination,
                            'date': checkoutState.flight.dateLabel,
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Ir a Stripe',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            await controller.createHold();
          },
          child: const Text('Renovar hold'),
        ),
      ],
    );
  }

  bool _savePreferences(CheckoutController controller) {
    controller.updatePreferences(
      travelPurpose: _travelPurpose,
      seatPreference: _seatPreference,
      cateringPreference: _cateringPreference,
      luggagePreference: _luggagePreference,
      privacyLevel: _privacyLevel,
      notes: _preferenceNotesController.text.trim(),
    );

    if (_travelPurpose.isEmpty || _seatPreference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa las preferencias antes de continuar.')),
      );
      return false;
    }
    return true;
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Widget _chipSection({
    required String title,
    required List<String> values,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) {
            return ChoiceChip(
              label: Text(
                value,
                style: GoogleFonts.lato(
                  color: selected == value ? Colors.white : Colors.black87,
                ),
              ),
              selected: selected == value,
              selectedColor: Colors.black87,
              backgroundColor: Colors.grey[200],
              onSelected: (isSelected) {
                if (isSelected) {
                  onSelected(value);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  Widget _summaryCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
