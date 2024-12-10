class Conciliation {
  final String filename;
  final String createdAt;
  final String s3Url;

  Conciliation({
    required this.filename,
    required this.createdAt,
    required this.s3Url,
  });

  factory Conciliation.fromJson(Map<String, dynamic> json) {
    return Conciliation(
      filename: json['filename'] ?? '',
      createdAt: json['createdAt'] ?? '',
      s3Url: json['s3Url'] ?? '',
    );
  }
}

class ConciliationResponse {
  final List<Conciliation> conciliations;

  ConciliationResponse({required this.conciliations});

  factory ConciliationResponse.fromJson(Map<String, dynamic> json) {
    var list = json['conciliations'] as List;
    List<Conciliation> conciliationList = list.map((i) => Conciliation.fromJson(i)).toList();

    return ConciliationResponse(
      conciliations: conciliationList,
    );
  }
}
