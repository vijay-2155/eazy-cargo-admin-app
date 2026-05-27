import '../../core/constants/app_constants.dart';

// ─────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────

class ConsignmentModel {
  final String id;
  final String name;
  final String clientName;
  final String clientContact;
  final String source;
  final String destination;
  final ConsignmentStatus status;
  final PriorityLevel priority;
  final String eta;
  final double progress;
  final List<String> truckIds;
  final String cargoType;
  final double weightTons;
  final String tripDate;

  const ConsignmentModel({
    required this.id,
    required this.name,
    required this.clientName,
    required this.clientContact,
    required this.source,
    required this.destination,
    required this.status,
    required this.priority,
    required this.eta,
    required this.progress,
    required this.truckIds,
    required this.cargoType,
    required this.weightTons,
    required this.tripDate,
  });
}

class TruckModel {
  final String id;
  final String regNumber;
  final TruckType type;
  final TruckStatus status;
  final TruckGroup group;
  final String? currentLocation;
  final String? assignedConsignment;
  final String? driverId;
  final double capacityTons;
  final String deviceId;
  final String gpsDevice;
  final double lat;
  final double lng;
  final double speed;
  final double heading;
  final int healthPercent;

  const TruckModel({
    required this.id,
    required this.regNumber,
    required this.type,
    required this.status,
    required this.group,
    this.currentLocation,
    this.assignedConsignment,
    this.driverId,
    required this.capacityTons,
    required this.deviceId,
    required this.gpsDevice,
    required this.lat,
    required this.lng,
    required this.speed,
    required this.heading,
    required this.healthPercent,
  });
}

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String licenseNumber;
  final String? assignedTruckId;
  final String? activeConsignmentId;
  final DriverStatus status;
  final int totalTrips;
  final double rating;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    this.assignedTruckId,
    this.activeConsignmentId,
    required this.status,
    required this.totalTrips,
    required this.rating,
  });
}

class LiveAlertModel {
  final String id;
  final AlertType type;
  final String title;
  final String subtitle;
  final String time;
  final AlertSeverity severity;

  const LiveAlertModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.severity,
  });
}

enum DriverStatus { available, onTrip, onLeave, offline }
enum AlertSeverity { low, medium, high, critical }

// ─────────────────────────────────────────────────────────────
// Mock Data Service
// ─────────────────────────────────────────────────────────────
class MockDataService {
  static final List<ConsignmentModel> consignments = [
    const ConsignmentModel(
      id: 'CONS-001',
      name: 'Vizag Port Export Batch #1',
      clientName: 'Reliance Industries Ltd.',
      clientContact: '+91 98765 43210',
      source: 'Visakhapatnam Port',
      destination: 'Kakinada Industrial Area',
      status: ConsignmentStatus.inTransit,
      priority: PriorityLevel.high,
      eta: '2h 30m',
      progress: 0.62,
      truckIds: ['TRK-001', 'TRK-002', 'TRK-003'],
      cargoType: 'Steel Coils',
      weightTons: 450.0,
      tripDate: '26 May 2026',
    ),
    const ConsignmentModel(
      id: 'CONS-002',
      name: 'Kakinada Chemical Bulk',
      clientName: 'ONGC Petroadditions',
      clientContact: '+91 91234 56789',
      source: 'Kakinada Port',
      destination: 'Vijayawada APIIC Zone',
      status: ConsignmentStatus.active,
      priority: PriorityLevel.critical,
      eta: '5h 15m',
      progress: 0.28,
      truckIds: ['TRK-004', 'TRK-005'],
      cargoType: 'Chemical Tanks',
      weightTons: 280.0,
      tripDate: '26 May 2026',
    ),
    const ConsignmentModel(
      id: 'CONS-003',
      name: 'AP Cement Delivery',
      clientName: 'Dalmia Cement',
      clientContact: '+91 80765 12345',
      source: 'Guntur Cement Plant',
      destination: 'Visakhapatnam Depot',
      status: ConsignmentStatus.delayed,
      priority: PriorityLevel.medium,
      eta: '8h 45m',
      progress: 0.15,
      truckIds: ['TRK-006'],
      cargoType: 'Cement Bags',
      weightTons: 120.0,
      tripDate: '26 May 2026',
    ),
    const ConsignmentModel(
      id: 'CONS-004',
      name: 'BHEL Equipment Transfer',
      clientName: 'BHEL Hyderabad',
      clientContact: '+91 78901 23456',
      source: 'Hyderabad BHEL Plant',
      destination: 'Vizag Power Station',
      status: ConsignmentStatus.pending,
      priority: PriorityLevel.high,
      eta: '12h 00m',
      progress: 0.0,
      truckIds: [],
      cargoType: 'Heavy Equipment',
      weightTons: 680.0,
      tripDate: '27 May 2026',
    ),
    const ConsignmentModel(
      id: 'CONS-005',
      name: 'FMCG Distribution Run',
      clientName: 'HUL Distribution',
      clientContact: '+91 70123 45678',
      source: 'Rajahmundry Warehouse',
      destination: 'Vizag Retail Points',
      status: ConsignmentStatus.completed,
      priority: PriorityLevel.low,
      eta: 'Delivered',
      progress: 1.0,
      truckIds: ['TRK-007', 'TRK-008'],
      cargoType: 'FMCG Goods',
      weightTons: 90.0,
      tripDate: '25 May 2026',
    ),
  ];

  static final List<TruckModel> trucks = [
    const TruckModel(
      id: 'TRK-001', regNumber: 'AP 09 AB 1234',
      type: TruckType.container, status: TruckStatus.assigned,
      group: TruckGroup.own, currentLocation: 'NH 16, near Tuni',
      assignedConsignment: 'CONS-001', driverId: 'DRV-001',
      capacityTons: 20.0, deviceId: 'DEV-4501', gpsDevice: 'Concox GT06',
      lat: 17.3617, lng: 82.5543, speed: 68.0, heading: 45.0, healthPercent: 92,
    ),
    const TruckModel(
      id: 'TRK-002', regNumber: 'AP 09 CD 5678',
      type: TruckType.flatbed, status: TruckStatus.assigned,
      group: TruckGroup.own, currentLocation: 'Anakapalli Bypass',
      assignedConsignment: 'CONS-001', driverId: 'DRV-002',
      capacityTons: 25.0, deviceId: 'DEV-4502', gpsDevice: 'Concox GT06',
      lat: 17.6910, lng: 83.0045, speed: 54.0, heading: 90.0, healthPercent: 88,
    ),
    const TruckModel(
      id: 'TRK-003', regNumber: 'TN 09 EF 9012',
      type: TruckType.container, status: TruckStatus.assigned,
      group: TruckGroup.lease, currentLocation: 'Visakhapatnam Port Gate',
      assignedConsignment: 'CONS-001', driverId: 'DRV-003',
      capacityTons: 20.0, deviceId: 'DEV-4503', gpsDevice: 'Teltonika FMB920',
      lat: 17.6868, lng: 83.2185, speed: 0.0, heading: 180.0, healthPercent: 76,
    ),
    const TruckModel(
      id: 'TRK-004', regNumber: 'AP 39 GH 3456',
      type: TruckType.tanker, status: TruckStatus.assigned,
      group: TruckGroup.own, currentLocation: 'Kakinada Port Road',
      assignedConsignment: 'CONS-002', driverId: 'DRV-004',
      capacityTons: 18.0, deviceId: 'DEV-4504', gpsDevice: 'Teltonika FMB920',
      lat: 16.9891, lng: 82.2475, speed: 42.0, heading: 270.0, healthPercent: 95,
    ),
    const TruckModel(
      id: 'TRK-005', regNumber: 'AP 39 IJ 7890',
      type: TruckType.tanker, status: TruckStatus.assigned,
      group: TruckGroup.rented, currentLocation: 'Peddapuram Junction',
      assignedConsignment: 'CONS-002', driverId: 'DRV-005',
      capacityTons: 18.0, deviceId: 'DEV-4505', gpsDevice: 'Concox GT06',
      lat: 17.0773, lng: 82.1327, speed: 61.0, heading: 315.0, healthPercent: 83,
    ),
    const TruckModel(
      id: 'TRK-006', regNumber: 'AP 07 KL 1357',
      type: TruckType.tipper, status: TruckStatus.maintenance,
      group: TruckGroup.own, currentLocation: 'Guntur Service Center',
      assignedConsignment: 'CONS-003', driverId: 'DRV-006',
      capacityTons: 15.0, deviceId: 'DEV-4506', gpsDevice: 'Concox AT4',
      lat: 16.3067, lng: 80.4365, speed: 0.0, heading: 0.0, healthPercent: 45,
    ),
    const TruckModel(
      id: 'TRK-007', regNumber: 'AP 05 MN 2468',
      type: TruckType.refrigerated, status: TruckStatus.available,
      group: TruckGroup.own, currentLocation: 'Rajahmundry Depot',
      capacityTons: 12.0, deviceId: 'DEV-4507', gpsDevice: 'Teltonika FMB920',
      lat: 17.0005, lng: 81.8040, speed: 0.0, heading: 0.0, healthPercent: 100,
    ),
    const TruckModel(
      id: 'TRK-008', regNumber: 'AP 05 OP 3579',
      type: TruckType.container, status: TruckStatus.available,
      group: TruckGroup.lease, currentLocation: 'Rajahmundry Depot',
      capacityTons: 20.0, deviceId: 'DEV-4508', gpsDevice: 'Concox GT06',
      lat: 17.0010, lng: 81.8050, speed: 0.0, heading: 0.0, healthPercent: 97,
    ),
  ];

  static final List<DriverModel> drivers = [
    const DriverModel(
      id: 'DRV-001', name: 'Ravi Kumar Reddy', phone: '+91 98765 11111',
      licenseNumber: 'AP2012003456', assignedTruckId: 'TRK-001',
      activeConsignmentId: 'CONS-001', status: DriverStatus.onTrip,
      totalTrips: 347, rating: 4.8,
    ),
    const DriverModel(
      id: 'DRV-002', name: 'Suresh Babu Naidu', phone: '+91 98765 22222',
      licenseNumber: 'AP2015007891', assignedTruckId: 'TRK-002',
      activeConsignmentId: 'CONS-001', status: DriverStatus.onTrip,
      totalTrips: 218, rating: 4.6,
    ),
    const DriverModel(
      id: 'DRV-003', name: 'Mohammed Rafiq', phone: '+91 98765 33333',
      licenseNumber: 'TN2018002341', assignedTruckId: 'TRK-003',
      activeConsignmentId: 'CONS-001', status: DriverStatus.onTrip,
      totalTrips: 156, rating: 4.5,
    ),
    const DriverModel(
      id: 'DRV-004', name: 'Venkata Rao Talluri', phone: '+91 98765 44444',
      licenseNumber: 'AP2010009876', assignedTruckId: 'TRK-004',
      activeConsignmentId: 'CONS-002', status: DriverStatus.onTrip,
      totalTrips: 421, rating: 4.9,
    ),
    const DriverModel(
      id: 'DRV-005', name: 'Prakash Goud', phone: '+91 98765 55555',
      licenseNumber: 'AP2016005432', assignedTruckId: 'TRK-005',
      activeConsignmentId: 'CONS-002', status: DriverStatus.onTrip,
      totalTrips: 189, rating: 4.4,
    ),
    const DriverModel(
      id: 'DRV-006', name: 'Srinivas Murthy', phone: '+91 98765 66666',
      licenseNumber: 'AP2009001234', assignedTruckId: 'TRK-006',
      status: DriverStatus.available, totalTrips: 512, rating: 4.7,
    ),
    const DriverModel(
      id: 'DRV-007', name: 'Kiran Kumar Patel', phone: '+91 98765 77777',
      licenseNumber: 'AP2020008765', status: DriverStatus.available,
      totalTrips: 98, rating: 4.3,
    ),
    const DriverModel(
      id: 'DRV-008', name: 'Bala Krishnaih', phone: '+91 98765 88888',
      licenseNumber: 'AP2014006543', status: DriverStatus.onLeave,
      totalTrips: 278, rating: 4.6,
    ),
  ];

  static final List<LiveAlertModel> liveAlerts = [
    const LiveAlertModel(
      id: 'ALT-001', type: AlertType.routeDeviation,
      title: 'TRK-003 — Route Deviation',
      subtitle: 'Vehicle deviated 2.4km near Anakapalli',
      time: '2m ago', severity: AlertSeverity.high,
    ),
    const LiveAlertModel(
      id: 'ALT-002', type: AlertType.delayedShipment,
      title: 'CONS-003 — Delayed by 3h',
      subtitle: 'AP Cement delivery behind schedule',
      time: '8m ago', severity: AlertSeverity.medium,
    ),
    const LiveAlertModel(
      id: 'ALT-003', type: AlertType.truckStopped,
      title: 'TRK-006 — Unplanned Stop',
      subtitle: 'Vehicle halted at Guntur for 45 min',
      time: '22m ago', severity: AlertSeverity.medium,
    ),
    const LiveAlertModel(
      id: 'ALT-004', type: AlertType.geofenceViolation,
      title: 'TRK-005 — Geofence Exit',
      subtitle: 'Entered restricted zone near Peddapuram',
      time: '35m ago', severity: AlertSeverity.critical,
    ),
    const LiveAlertModel(
      id: 'ALT-005', type: AlertType.etaWarning,
      title: 'CONS-002 — ETA Updated',
      subtitle: 'Now expected +2h later than planned',
      time: '1h ago', severity: AlertSeverity.low,
    ),
  ];
}
