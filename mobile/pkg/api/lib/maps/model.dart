import 'package:api/common.dart';
import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String id;
  final String description;

  const Place(this.id, this.description);

  factory Place.fromMap(Map<String, dynamic> map) => Place(map['place_id'], map['description']);

  @override
  List<Object?> get props => [id, description];
}

class PlaceDetail extends Equatable {
  final String address;
  final double lat;
  final double lng;

  const PlaceDetail(this.address, this.lat, this.lng);

  factory PlaceDetail.fromMap(Map<String, dynamic> map) =>
      PlaceDetail(map['formatted_address'], map['geometry']['location']['lat'], map['geometry']['location']['lng']);

  @override
  List<Object?> get props => [address, lat, lng];
}

class Direction extends Equatable {
  const Direction({
    this.legs = const [],
    this.overviewPolyline = '',
  });

  final List<Leg> legs;
  final String overviewPolyline;

  factory Direction.fromMap(Map<String, dynamic> json) => Direction(
        legs: List<Leg>.from(json["legs"].map((x) => Leg.fromMap(x))),
        overviewPolyline: json["overview_polyline"]["points"],
      );

  @override
  List<Object?> get props => [
        legs,
        overviewPolyline,
      ];
}

class Leg extends Equatable {
  const Leg({
    this.distance = '',
    this.duration = '',
    this.end = const Address(),
    this.start = const Address(),
    this.steps = const [],
  });

  final String distance;
  final String duration;

  final Address end;
  final Address start;
  final List<Steps> steps;

  factory Leg.fromMap(Map<String, dynamic> json) => Leg(
        distance: json["distance"]["text"],
        duration: json["duration"]["text"],
        end: Address(name: json["end_address"], lngLat: [json["end_location"]["lng"], json["end_location"]["lat"]]),
        start: Address(name: json["start_address"], lngLat: [json["start_location"]["lng"], json["start_location"]["lat"]]),
        steps: List<Steps>.from(json["steps"].map((x) => Steps.fromMap(x))),
      );

  @override
  List<Object?> get props => [
        distance,
        duration,
        end,
        start,
        steps,
      ];
}

class Steps {
  Steps({
    this.endLocation = const Address(),
    this.startLocation = const Address(),
  });

  final Address endLocation;
  final Address startLocation;

  factory Steps.fromMap(Map<String, dynamic> json) => Steps(
        endLocation: Address(lngLat: [json["end_location"]["lng"], json["end_location"]["lat"]]),
        startLocation: Address(lngLat: [json["start_location"]["lng"], json["start_location"]["lat"]]),
      );
}
