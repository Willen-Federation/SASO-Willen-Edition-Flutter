import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_details.freezed.dart';
part 'problem_details.g.dart';

/// RFC 7807 Problem Details with SASO-DOMAIN-NNNN extension.
/// Error code format: SASO-AUTH-1003, SASO-ITEM-2001, etc.
@freezed
abstract class ProblemDetails with _$ProblemDetails implements Exception {
  const factory ProblemDetails({
    required String type,
    required String title,
    required int status,
    String? detail,
    String? instance,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'code') String? sasoCode,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'traceId') String? traceId,
  }) = _ProblemDetails;

  factory ProblemDetails.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailsFromJson(json);

  const ProblemDetails._();

  SasoErrorDomain get domain {
    if (sasoCode == null) return SasoErrorDomain.unknown;
    final parts = sasoCode!.split('-');
    if (parts.length < 3) return SasoErrorDomain.unknown;
    return SasoErrorDomain.fromString(parts[1]);
  }

  @override
  String toString() => 'ProblemDetails($status, $sasoCode): $title — $detail';
}

enum SasoErrorDomain {
  auth,
  item,
  label,
  shelf,
  install,
  infra,
  draft,
  mobile,
  unknown;

  static SasoErrorDomain fromString(String s) => switch (s.toUpperCase()) {
    'AUTH' => SasoErrorDomain.auth,
    'ITEM' => SasoErrorDomain.item,
    'LABEL' => SasoErrorDomain.label,
    'SHELF' => SasoErrorDomain.shelf,
    'INSTALL' => SasoErrorDomain.install,
    'INFRA' => SasoErrorDomain.infra,
    'DRAFT' => SasoErrorDomain.draft,
    'MOBILE' => SasoErrorDomain.mobile,
    _ => SasoErrorDomain.unknown,
  };
}

extension SasoErrorScope on ProblemDetails {
  /// True when this is the `SASO-MOBILE-2008` scope-insufficient response.
  /// Mobile clients should surface a "re-pair this device" CTA in this case.
  bool get isScopeInsufficient =>
      sasoCode == 'SASO-MOBILE-2008' && status == 403;
}
