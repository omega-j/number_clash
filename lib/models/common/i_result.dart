abstract class IResult<T> {
  // Indicates if the result is successful
  bool get isSuccessful;

  // Indicates if the result is a failure
  bool get isFailure;

  // Indicates if the result is successful and data is not null
  bool get isSuccessfulAndDataIsNotNull;

  // Indicates if the data is null
  bool get dataIsNull;

  // The message associated with the result
  String get message;

  // The data associated with the result, if any
  T? get data;

  // The timestamp of when the result was created
  DateTime get timestamp;
}
