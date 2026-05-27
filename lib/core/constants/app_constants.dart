class AppConstants {
  // App Info
  static const String appName = 'EazeMyCargo';
  static const String appTagline = 'Move Cargo Smarter. Faster. Greener.';
  static const String appSubtitle = 'AI-Powered Fleet Tracking & Cargo Intelligence';
  static const String companyName = 'EazeMy Technologies Pvt. Ltd.';

  // Route names
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeConsignments = '/consignments';
  static const String routeConsignmentCreate = '/consignments/create';
  static const String routeConsignmentMonitor = '/consignments/monitor';
  static const String routeConsignmentEdit = '/consignments/edit';
  static const String routeConsignmentDetail = '/consignments/detail';
  static const String routeTrucks = '/trucks';
  static const String routeTruckCreate = '/trucks/create';
  static const String routeTruckEdit = '/trucks/edit';
  static const String routeDrivers = '/drivers';
  static const String routeDriverCreate = '/drivers/create';
  static const String routeAnalytics = '/analytics';
  static const String routeGeofence = '/geofence';
  static const String routeNotifications = '/notifications';

  // Mock data counts
  static const int mockVehicleCount = 128;
  static const int mockDeliveriesToday = 354;
  static const int mockOnTimePercent = 92;
  static const String mockDistanceCovered = '12,540 km';
  static const int mockActiveAlerts = 7;
  static const int mockDelayedShipments = 12;
  static const int mockTotalTrucks = 64;

  // Visakhapatnam corridor coords
  static const double vizagLat = 17.6868;
  static const double vizagLng = 83.2185;
  static const double kakinadaLat = 16.9891;
  static const double kakinadaLng = 82.2475;

  // Animation durations
  static const Duration splashDuration = Duration(milliseconds: 3500);
  static const Duration transitionDuration = Duration(milliseconds: 350);
  static const Duration pulseInterval = Duration(seconds: 2);
  static const Duration counterDuration = Duration(milliseconds: 800);
}

// ─────────────────────────────────────────────────────────────
// Consignment Status
// ─────────────────────────────────────────────────────────────
enum ConsignmentStatus {
  pending,
  active,
  inTransit,
  delayed,
  completed;

  String get label {
    switch (this) {
      case ConsignmentStatus.pending: return 'Pending';
      case ConsignmentStatus.active: return 'Active';
      case ConsignmentStatus.inTransit: return 'In Transit';
      case ConsignmentStatus.delayed: return 'Delayed';
      case ConsignmentStatus.completed: return 'Completed';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Priority Level
// ─────────────────────────────────────────────────────────────
enum PriorityLevel {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case PriorityLevel.low: return 'Low';
      case PriorityLevel.medium: return 'Medium';
      case PriorityLevel.high: return 'High';
      case PriorityLevel.critical: return 'Critical';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Truck Status & Type
// ─────────────────────────────────────────────────────────────
enum TruckStatus { available, assigned, maintenance, offline }
enum TruckGroup { own, lease, rented }
enum TruckType { container, flatbed, tanker, refrigerated, tipper }

// ─────────────────────────────────────────────────────────────
// Alert types
// ─────────────────────────────────────────────────────────────
enum AlertType {
  routeDeviation,
  truckStopped,
  delayedShipment,
  geofenceViolation,
  etaWarning,
  incident;

  String get label {
    switch (this) {
      case AlertType.routeDeviation: return 'Route Deviation';
      case AlertType.truckStopped: return 'Truck Stopped';
      case AlertType.delayedShipment: return 'Delayed Shipment';
      case AlertType.geofenceViolation: return 'Geofence Violation';
      case AlertType.etaWarning: return 'ETA Warning';
      case AlertType.incident: return 'Incident';
    }
  }
}
