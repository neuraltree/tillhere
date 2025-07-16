import '../errors/failures.dart';

/// Result type for operations that can fail
/// Using a simple approach instead of dartz for this implementation
class Result<T> {
  final T? data;
  final Failure? failure;
  
  const Result.success(this.data) : failure = null;
  const Result.failure(this.failure) : data = null;
  
  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;
  
  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($data)';
    } else {
      return 'Result.failure($failure)';
    }
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Result<T> &&
        other.data == data &&
        other.failure == failure;
  }
  
  @override
  int get hashCode => data.hashCode ^ failure.hashCode;
}
