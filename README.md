# ShareFly

Prototipo de app Flutter para un marketplace de vuelos privados compartidos, con foco en `empty legs`, rutas en formacion y reserva de plazas desde movil.

La idea del producto es resolver el problema central en pocos segundos: un usuario busca un trayecto, entiende si hay encaje real con vuelos existentes y puede reservar o proponer una ruta nueva sin friccion.

## Propuesta de valor

- Busqueda avanzada de vuelos compartidos con filtros que importan de verdad al usuario premium.
- Matching visible con score explicable, no solo una lista plana de resultados.
- Reserva de plazas con flujo claro, rapido y preparado para pagos.
- Notificaciones y waitlist para que el marketplace parezca vivo desde el primer dia.
- Perfil premium con preferencias y contexto suficiente para personalizar la experiencia.

## Experiencia principal

1. El usuario define origen, destino, fecha, flexibilidad y presupuesto.
2. La app devuelve vuelos compatibles, `empty legs` y rutas en formacion.
3. Cada resultado muestra un `match score` y explica por que aparece.
4. Si no existe un encaje exacto, el usuario puede proponer la ruta.
5. El usuario reserva una plaza, deja sus datos y recibe seguimiento del estado.

## Funcionalidades prioritarias

### 1. Busqueda avanzada de vuelos compartidos

- Origen y destino.
- Fecha exacta o flexible.
- Numero de pasajeros.
- Presupuesto estimado.
- Filtro `solo empty legs`.
- Ida o ida y vuelta.
- Aeropuertos cercanos.
- Preferencia de viaje: negocio, ocio, networking o maxima privacidad.

### 2. Motor de matching visible para el usuario

Cada resultado debe mostrar un score entendible y sus razones:

- Coincidencia de ruta.
- Compatibilidad de fechas o ventana flexible.
- Asientos disponibles.
- Precio estimado por asiento.
- Proximidad entre aeropuertos alternativos.
- Estado del vuelo: `forming`, `confirmed` o pendiente de operador.
- Afinidad con el tipo de viaje.

### 3. Crear solicitud cuando no existe vuelo exacto

- Proponer una ruta.
- Aceptar aeropuertos alternativos.
- Indicar flexibilidad horaria.
- Definir cuantas plazas necesita.
- Unirse a una ruta en formacion.
- Recibir avisos cuando aparezca un `empty leg` compatible.

### 4. Pantalla de detalle del vuelo

- Operador.
- Tipo de aeronave.
- Aeropuerto de salida y llegada.
- Hora estimada.
- Plazas restantes.
- Precio por asiento.
- Estado del vuelo.
- Ahorro estimado frente a charter privado.
- Reglas de cancelacion.
- Huella o eficiencia estimada por compartir.

### 5. Flujo de reserva de plaza

- Reserva de asiento.
- Hold temporal de plaza.
- Datos del pasajero.
- Preferencias de viaje.
- Revision del resumen.
- Pago `mock` o Stripe sandbox.
- Confirmacion y estado de la solicitud.

### 6. Notificaciones y waitlist

- Se abrio una plaza.
- Tu ruta ya tiene `3/4` pasajeros.
- Un operador ha confirmado disponibilidad.
- Aparecio un `empty leg` compatible.
- Hubo un cambio de precio.

### 7. Perfil de usuario premium

- Datos personales.
- Documento o KYC basico simulado.
- Preferencias de catering.
- Idioma.
- Preferencias de networking o privacidad.
- Historial de reservas.
- Metodos de pago guardados.

## MVP recomendado

Si hubiese que demostrar valor muy rapido, el foco seria:

1. Buscador potente.
2. Matching de `empty legs` y rutas en formacion con score explicable.
3. Flujo de reserva de plaza con notificaciones.

## Fuera de foco en la primera fase

- VTOL, drones y hubs urbanos.
- Dashboard completo para operadores.
- ACH real.
- Compliance profundo tipo PCI DSS documental.
- Integraciones GDS complejas.

La prioridad es demostrar que sabemos resolver el nucleo del producto: demanda real, agrupacion inteligente de viajeros y conversion a reserva.

## Stack del repositorio

- `flutter/`: app principal para web, mobile y desktop.
- `supabase/`: autenticacion, base de datos, funciones y backend del MVP.
- `nextjs/`: soporte web complementario para landing, paneles o flujos auxiliares.
- `docs/`: documentacion tecnica y notas de arquitectura.

Tecnologias ya presentes en el repo:

- Flutter.
- Riverpod.
- Go Router.
- Supabase.
- Stripe.
- Next.js.

## Desarrollo local

### Flutter

```bash
cd flutter
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

### Next.js

```bash
cd nextjs
pnpm install
pnpm dev
```

### Supabase local

```bash
cd nextjs
pnpm supabase:start
pnpm supabase:status
```

## Estado del proyecto

Este repositorio parte de un boilerplate SaaS y se esta adaptando a un caso de uso muy concreto: vuelos privados compartidos con matching, reserva y activacion de rutas segun demanda.

El objetivo no es solo enseñar pantallas bonitas, sino validar la logica de producto que mas valor aporta:

- descubrir oferta compatible en segundos;
- explicar por que un vuelo encaja;
- convertir interes en reserva;
- mantener vivo el marketplace mediante waitlist y notificaciones.
