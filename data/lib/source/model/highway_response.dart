
import 'package:json_annotation/json_annotation.dart';

import 'camera_point_response.dart';

part 'highway_response.g.dart';

@JsonSerializable()
class HighwayResponse {
  const HighwayResponse({
    required this.id,
    required this.name,
    required this.code,
    required this.speedLimit,
    required this.cameraPoints,
  });

  factory HighwayResponse.fromJson(Map<String, dynamic> json) => _$HighwayResponseFromJson(json);

  final String id;
  final String name;
  final String code;
  final double speedLimit;
  final List<CameraPointResponse> cameraPoints;
  Map<String, dynamic> toJson() => _$HighwayResponseToJson(this);
}
