import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devtodollars/services/auth_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  final String? price;
  final String? holdId;
  final String? bookingId;
  final String? expiresAt;
  final String? origin;
  final String? destination;
  final String? dateLabel;

  const PaymentsScreen({
    super.key,
    this.price,
    this.holdId,
    this.bookingId,
    this.expiresAt,
    this.origin,
    this.destination,
    this.dateLabel,
  });

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  bool _holdIsValid() {
    final holdId = widget.holdId;
    final expiresAt = DateTime.tryParse(widget.expiresAt ?? '');
    if (holdId == null || holdId.isEmpty) {
      return false;
    }
    if (expiresAt == null) {
      return true;
    }
    return expiresAt.isAfter(DateTime.now());
  }

  Future<void> _showInvalidHoldDialog(String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hold no válido'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.replaceNamed('home'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!_holdIsValid()) {
        await _showInvalidHoldDialog(
          'La reserva temporal no está disponible o ya expiró. Vuelve a crear un hold desde el checkout.',
        );
        return;
      }

      Uri? url;
      final authNotif = ref.read(authProvider.notifier);
      try {
        url = await authNotif.getUserStripeLink(
          price: widget.price,
          holdId: widget.holdId,
          bookingId: widget.bookingId,
        );
      } on FunctionException catch (e) {
        if (!mounted) return;
        var msg =
            e.details?["message"] ?? "Error retrieving stripe redirect url";
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Failed to open Stripe"),
            content: Text(msg),
            actions: [
              TextButton(onPressed: context.pop, child: const Text("Ok"))
            ],
          ),
        );
      }
      if (url != null) {
        launchUrl(url, webOnlyWindowName: "_self");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "You are being redirected to Stripe for payment.\nPlease wait a moment...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            if (widget.origin != null && widget.destination != null) ...[
              const SizedBox(height: 12),
              Text(
                '${widget.origin} → ${widget.destination}${widget.dateLabel != null ? ' • ${widget.dateLabel}' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
            if (widget.holdId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Hold: ${widget.holdId}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => context.replaceNamed('home'),
              child: const Text("Return to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
