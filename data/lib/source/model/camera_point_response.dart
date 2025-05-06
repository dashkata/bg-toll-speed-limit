import 'package:json_annotation/json_annotation.dart';

part 'camera_point_response.g.dart';

@JsonSerializable()
class CameraPointResponse {
  const CameraPointResponse({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.kilometerMark,
  });

  factory CameraPointResponse.fromJson(Map<String, dynamic> json) => _$CameraPointResponseFromJson(json);

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int kilometerMark;

  Map<String, dynamic> toJson() => _$CameraPointResponseToJson(this);
}
