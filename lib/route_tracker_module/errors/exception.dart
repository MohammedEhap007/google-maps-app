class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);

  @override
  String toString() => 'LocationPermissionException: $message';
}
