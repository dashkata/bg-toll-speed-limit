/// Represents a highway with a collection of camera points
class Highway {
  const Highway({
    required this.id,
    required this.name,
    required this.code,
    required this.speedLimit,
  });
  final String id;
  final String name;
  final String code;
  final double speedLimit;
}
