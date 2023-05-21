class Api {
  static const String api = "http://0.0.0.0:3000/"; //Add your Api Domain here
  static Uri googleLogin = Uri.parse("${api}ws-mobile/api/v1/auth");
  static Uri refreshToken = Uri.parse("${api}ws-mobile/api/v1/auth/refresh");
  static String hashQuery = "${api}ws-mobile/api/v1/hash/query";
  static Uri checkJobStatus = Uri.parse("${api}ws-mobile/api/v1/hash/jobs/");
  static Uri uploadJobFile = Uri.parse("${api}ws-mobile/api/v1/hash/file/upload");
  // static String checkJobStatus = "https://skin-budgets-everything-wider.trycloudflare.com/status/";
  // static Uri uploadJobFile = Uri.parse("https://skin-budgets-everything-wider.trycloudflare.com/files/");
  static Uri linkScan = Uri.parse("${api}ws-mobile/api/v1/urls");

}

enum ResponseStatus {
  success(200),
  unAuthorized(401),
  invalidInput(422),
  rateLimit(429),
  internalError(500);

  const ResponseStatus(this.code);

  final int code;

  factory ResponseStatus.fromStatus(int code) {
    return values.firstWhere((e) => e.code == code);
  }
}

enum JobStatus {
  FILE_NOT_RECEIVED(1000),
  FILE_ANALYSIS_YET_TO_START(1001),
  FILE_ANALYSIS_INITIATED(1002),
  FILE_ANALYSIS_COMPLETED(1003),
  ERROR_OCCURRED(1500),
  FILE_HASH_MISMATCH(1501);

  const JobStatus(this.code);

  final int code;

  factory JobStatus.fromStatus(int code) {
    return values.firstWhere((e) => e.code == code);
  }
}