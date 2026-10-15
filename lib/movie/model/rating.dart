import 'package:collection/collection.dart';

class Rating {
  String? source;
  String? value;

  Rating({this.source, this.value});

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    source: json['Source'] as String?,
    value: json['Value'] as String?,
  );

  Map<String, dynamic> toJson() => {'Source': source, 'Value': value};

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    if (other is! Rating) return false;
    final mapEquals = const DeepCollectionEquality().equals;
    return mapEquals(other.toJson(), toJson());
  }

  @override
  int get hashCode => source.hashCode ^ value.hashCode;
}
