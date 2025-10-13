class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<ValidationError>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null 
          ? (json['errors'] as List).map((e) => ValidationError.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors?.map((e) => e.toJson()).toList(),
    };
  }
}

class ValidationError {
  final String type;
  final String value;
  final String msg;
  final String path;
  final String location;

  ValidationError({
    required this.type,
    required this.value,
    required this.msg,
    required this.path,
    required this.location,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) {
    return ValidationError(
      type: json['type'] ?? '',
      value: json['value'] ?? '',
      msg: json['msg'] ?? '',
      path: json['path'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'msg': msg,
      'path': path,
      'location': location,
    };
  }
}
