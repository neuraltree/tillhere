/// Base class for all failures in the application
/// Following Clean Architecture principles for error handling
abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Failure &&
        other.message == message &&
        other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
  
  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Database-related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Encryption/Decryption failures
class CryptographyFailure extends Failure {
  const CryptographyFailure(super.message, {super.code});
}

/// JSON serialization/deserialization failures
class SerializationFailure extends Failure {
  const SerializationFailure(super.message, {super.code});
}

/// Network-related failures (for future use)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Cache-related failures (for future use)
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
