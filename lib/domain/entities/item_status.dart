import 'package:json_annotation/json_annotation.dart';

/// Operational lifecycle status for an Item.
///
/// Mirrors the 9-value enum defined in the backend's
/// `config/openapi.yaml#/components/schemas/ItemResource.status`. Any value
/// can transition to any other value — there are no server-side ordering
/// rules.
enum ItemStatus {
  @JsonValue('active')
  active,
  @JsonValue('archived')
  archived,
  @JsonValue('discontinued')
  discontinued,
  @JsonValue('pending')
  pending,
  @JsonValue('in_storage')
  inStorage,
  @JsonValue('in_use')
  inUse,
  @JsonValue('for_sale')
  forSale,
  @JsonValue('reserved')
  reserved,
  @JsonValue('shipped')
  shipped;

  /// Snake-case wire value sent on PATCH bodies and received on GET responses.
  String get jsonValue => switch (this) {
    ItemStatus.active => 'active',
    ItemStatus.archived => 'archived',
    ItemStatus.discontinued => 'discontinued',
    ItemStatus.pending => 'pending',
    ItemStatus.inStorage => 'in_storage',
    ItemStatus.inUse => 'in_use',
    ItemStatus.forSale => 'for_sale',
    ItemStatus.reserved => 'reserved',
    ItemStatus.shipped => 'shipped',
  };

  /// Forward-compatible decoder. Unknown values (e.g. a tenth status added
  /// server-side after this client shipped) fall back to [active] so a single
  /// stale field never blocks rendering.
  static ItemStatus fromJsonValue(String? raw) {
    if (raw == null) return ItemStatus.active;
    for (final value in ItemStatus.values) {
      if (value.jsonValue == raw) return value;
    }
    return ItemStatus.active;
  }
}
