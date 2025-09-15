/// Exception thrown when input validation fails
class ValidationException implements Exception {
  final String message;
  final String? field;
  final dynamic value;

  const ValidationException(this.message, {this.field, this.value});

  @override
  String toString() {
    if (field != null) {
      return 'ValidationException: $message (field: $field)';
    }
    return 'ValidationException: $message';
  }
}
