import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:records/records.dart';
import 'package:source_gen/source_gen.dart';

LibraryReader validate(LibraryReader library) {
  library
      .annotatedWith(const TypeChecker.fromRuntime(Record))
      .forEach(_validateElement);
  return library;
}

void _validateElement(AnnotatedElement annotatedElement) {
  final element = annotatedElement.element;
  if (element is! FunctionTypeAliasElement) {
    throw InvalidGenerationSourceError(
      '@record can be used only for function type aliases',
      element: element,
    );
  }

  _validateFunctionTypeAlias(element);
}

void _validateFunctionTypeAlias(FunctionTypeAliasElement element) {
  if (element.function.parameters.any(_isUnnamed)) {
    throw InvalidGenerationSourceError(
      "Unnamed parameters are not allowed",
      element: element,
    );
  }
  if (element.function.parameters
      .any((it) => !_isnullableType(it) && it.isOptionalPositional)) {
    throw InvalidGenerationSourceError(
      "Non-nullable type parameters can't be unnamed optional parameter",
      element: element,
    );
  }
}

bool _isUnnamed(Element element) {
  final String? name = element.name;
  return name == null || name.isEmpty;
}

bool _isnullableType(ParameterElement element) =>
    element.type.nullabilitySuffix == NullabilitySuffix.question;
