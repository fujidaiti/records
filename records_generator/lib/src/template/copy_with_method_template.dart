import 'package:code_builder/code_builder.dart';
import 'package:records_generator/src/models.dart';

Method inflate(RecordType type) {
  final method = MethodBuilder()
    ..name = 'copyWith'
    ..returns = refer(_returnType(type))
    ..optionalParameters.addAll(_parameters(type))
    ..lambda = true
    ..body = _bodyCode(type);
  return method.build();
}

Iterable<Parameter> _parameters(RecordType type) =>
    type.fields.map(_parameter);

Parameter _parameter(RecordField field) {
  final param = ParameterBuilder()
    ..name = field.name
    ..type = refer(_nullableType(field))
    ..named = true;
  return param.build();
}

String _returnType(RecordType type) {
  final params = type.typeParameters.map((it) => it.name);
  return params.isNotEmpty
      ? '${type.name}<${params.join(', ')}>'
      : type.name;
}

String _nullableType(RecordField field) {
  final type = field.type.name.trim();
  return type.endsWith('?') ? type : '$type?';
}

Code _bodyCode(RecordType type) {
  final ctor = '${type.name}';
  // final ctor = '${type.name}._';
  // final args =
  //     type.fields.map((it) => '${it.name} ?? this.${it.name}').join(', ');
  final positionalArgs = type.fields
      .where((it) => it.isPositional)
      .map((it) => '${it.name} ?? this.${it.name}');
  final namedArgs = type.fields
      .where((it) => !it.isPositional)
      .map((it) => '${it.name}: ${it.name} ?? this.${it.name}');
  final args = [
    ...positionalArgs,
    ...namedArgs,
  ].join(', ');
  return Code('$ctor($args)');
}
