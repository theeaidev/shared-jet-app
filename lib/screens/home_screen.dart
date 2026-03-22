import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devtodollars/services/auth_notifier.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Form controllers and state
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  bool _isRoundTrip = false;
  DateTime? _selectedDate;
  bool _isFlexibleDate = false;
  int _passengers = 1;
  double _budget = 5000;
  bool _onlyEmptyLegs = false;
  bool _nearbyAirports = false;
  String _preference = 'Negocio';

  bool _isSearching = false;
  bool _showResults = false;
  List<Map<String, dynamic>> _mockResults = [];

  void _performSearch() {
    setState(() {
      _isSearching = true;
      _showResults = false;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      
      String orig = _originController.text.isNotEmpty ? _originController.text : "Madrid";
      String dest = _destinationController.text.isNotEmpty ? _destinationController.text : "Ibiza";
      String dateStr = _selectedDate != null ? _formatDate(_selectedDate!) : "Pronto";
      
      setState(() {
        _isSearching = false;
        _showResults = true;
        _mockResults = [
          {
            "score": 98,
            "origin": orig,
            "destination": dest,
            "date": dateStr,
            "price": (_budget > 1000 ? _budget * 0.4 : 850).toInt(),
            "status": "Ruta en formación",
            "details": {
              "Ruta": "Coincidencia exacta con 2 pasajeros.",
              "Fechas": "Ventana compatible 100%.",
              "Asientos": "4 plazas disponibles (Jet Light).",
              "Precio estimado": "Alineado con presupuesto.",
              "Proximidad": "Uso de terminales ejecutivas céntricas.",
              "Afinidad": "Tipo de viaje '$_preference' muy compatible.",
              "Estado": "IA optimizando demanda activa.",
            }
          },
          {
            "score": 85,
            "origin": "$orig (Alternativo)",
            "destination": dest,
            "date": "$dateStr (+1 día)",
            "price": (_budget > 1000 ? _budget * 0.25 : 500).toInt(),
            "status": "Confirmado",
            "details": {
              "Ruta": "Aeropuerto origen cercano (45km).",
              "Fechas": "Flexibilidad aceptada por algoritmia.",
              "Asientos": "2 plazas remanentes.",
              "Precio estimado": "Oportunidad Empty Leg.",
              "Proximidad": "Compensa cercanía con menor coste.",
              "Afinidad": "Perfil mixto (ocio/negocio).",
              "Estado": "Vuelo ya confirmado y listo.",
            }
          }
        ];
      });
    });
  }

  void _resetSearch() {
    setState(() {
      _showResults = false;
      _mockResults = [];
    });
  }

  Widget _buildResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: _resetSearch,
            ),
            Expanded(
              child: Text(
                'Motor de Matching IA',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ]
        ),
        const SizedBox(height: 8),
        Text(
          'Agrupando viajeros afines con rutas compatibles...',
          style: GoogleFonts.lato(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ..._mockResults.map((result) {
          final score = result["score"] as int;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              value: score / 100,
                              color: score >= 90 ? Colors.green : Colors.orange,
                              backgroundColor: Colors.grey[200],
                              strokeWidth: 4,
                            ),
                          ),
                          Text('$score%', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 11)),
                        ]
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${result["origin"]} ➔ ${result["destination"]}", style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("${result["date"]} • ${result["status"]}", style: GoogleFonts.lato(fontSize: 13, color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text(
                        "\$${result["price"]}",
                        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ]
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Análisis de Algoritmia:", style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        ...(result["details"] as Map<String, String>).entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, size: 14, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text("${e.key}: ${e.value}", style: GoogleFonts.lato(fontSize: 13, color: Colors.black87)),
                              ),
                            ]
                          ),
                        )),
                      ]
                    )
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Solicitud de reserva enviada.")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: const Color(0xFFD4AF37),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text("UNIRSE AL VUELO", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                    )
                  )
                ]
              )
            )
          );
        }),
      ],
    );
  }

  final List<String> _preferences = [
    'Negocio',
    'Ocio',
    'Networking',
    'Máxima privacidad'
  ];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final authNotif = ref.watch(authProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "SHARE JET",
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.replaceNamed("payments"),
            child: Text("Payments", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: authNotif.signOut, 
            child: Text("Logout", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold))
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/luxury_jet_bg.png',
            fit: BoxFit.cover,
          ),
          // Blur Effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
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
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showResults) _buildResultsView()
                      else ...[
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flight_takeoff, color: Color(0xFFD4AF37), size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Búsqueda Avanzada',
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.black87,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Encuentre o comparta su vuelo ideal.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Trip Type (Ida / Ida y Vuelta)
                      Center(
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          fillColor: Colors.black87,
                          color: Colors.black54,
                          constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
                          isSelected: [!_isRoundTrip, _isRoundTrip],
                          onPressed: (int index) {
                            setState(() {
                              _isRoundTrip = index == 1;
                            });
                          },
                          children: [
                            Text("Ida", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                            Text("Ida y vuelta", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Origen y Destino
                      TextFormField(
                        controller: _originController,
                        decoration: InputDecoration(
                          labelText: 'Origen',
                          prefixIcon: const Icon(Icons.flight_takeoff, color: Color(0xFFD4AF37)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: 'Destino',
                          prefixIcon: const Icon(Icons.flight_land, color: Color(0xFFD4AF37)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fechas
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _presentDatePicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedDate == null ? 'Fecha exacta' : _formatDate(_selectedDate!),
                                        style: GoogleFonts.lato(
                                          color: _selectedDate == null ? Colors.black54 : Colors.black87,
                                          fontSize: 16,
                                          height: 1.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Flexible", style: GoogleFonts.lato(fontSize: 14)),
                              const SizedBox(width: 4),
                              Switch(
                                value: _isFlexibleDate,
                                activeTrackColor: const Color(0x88D4AF37),
                                activeThumbColor: const Color(0xFFD4AF37),
                                onChanged: (val) {
                                  setState(() {
                                    _isFlexibleDate = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Pasajeros y Presupuesto
                      DropdownButtonFormField<int>(
                        initialValue: _passengers,
                        decoration: InputDecoration(
                          labelText: 'Pasajeros',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFD4AF37)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: List.generate(14, (index) => index + 1).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _passengers = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            " Presupuesto estimado: \$${_budget.toInt()}",
                            style: GoogleFonts.lato(color: Colors.black54, fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            value: _budget,
                            min: 500,
                            max: 50000,
                            divisions: 99,
                            activeColor: const Color(0xFFD4AF37),
                            inactiveColor: Colors.grey[300],
                            label: "\$${_budget.toInt()}",
                            onChanged: (val) {
                              setState(() => _budget = val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Switches
                      SwitchListTile(
                        title: Text("Solo empty legs", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        subtitle: Text("Aproveche vuelos vacíos a menor coste.", style: GoogleFonts.lato(fontSize: 12)),
                        value: _onlyEmptyLegs,
                        activeTrackColor: const Color(0x88D4AF37),
                        activeThumbColor: const Color(0xFFD4AF37),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() => _onlyEmptyLegs = val);
                        },
                      ),
                      SwitchListTile(
                        title: Text("Aeropuertos cercanos", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        value: _nearbyAirports,
                        activeTrackColor: const Color(0x88D4AF37),
                        activeThumbColor: const Color(0xFFD4AF37),
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() => _nearbyAirports = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Preference
                      Text(
                        "Preferencia del viaje",
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _preferences.map((pref) {
                          return ChoiceChip(
                            label: Text(pref, style: GoogleFonts.lato(
                              color: _preference == pref ? Colors.white : Colors.black87,
                            )),
                            selected: _preference == pref,
                            selectedColor: Colors.black87,
                            backgroundColor: Colors.grey[200],
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() => _preference = pref);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: _isSearching ? null : _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isSearching
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)
                            )
                          : Text(
                              "BUSCAR VUELOS",
                              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                      ),
                      const SizedBox(height: 16),
                      ],
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
}
