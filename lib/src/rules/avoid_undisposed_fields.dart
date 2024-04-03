// Copyright (c) 2024, the Code Collab Hub.

// This is the entrypoint of our custom linter
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _listenableChecker = TypeChecker.fromName(
  'Listenable',
  packageName: 'flutter/src/foundation',
);

PluginBase createPlugin() => _ExampleLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _ExampleLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidUndisposedListenableFields(),
      ];
}

class AvoidUndisposedListenableFields extends DartLintRule {
  AvoidUndisposedListenableFields() : super(code: _code);

  /// Metadata about the warning that will show-up in the IDE.
  /// This is used for `// ignore: code` and enabling/disabling the lint
  static const _code = LintCode(
    name: 'avoid_undisposed_listenable_fields',
    problemMessage: r'Avoid declaring listenable fields in StatefulWidgets without disposing them.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      if (node.extendsClause?.superclass.name2.lexeme == 'State') {
        final fields = <FieldDeclaration>[];

        for (final member in node.members) {
          if (member is FieldDeclaration) {
            fields.add(member);
          }
        }

        MethodDeclaration? disposeMethod;
        for (final member in node.members) {
          if (member is MethodDeclaration && member.name.lexeme == 'dispose') {
            disposeMethod = member;
            break;
          }
        }

        for (final field in fields) {
          for (final variable in field.fields.variables) {
            final name = variable.name.lexeme;
            final VariableElement? fieldElement = variable.declaredElement;
            final DartType? fieldType = fieldElement?.type;

            // print('fieldType: $fieldType');
            // final element = fieldType?.element;
            // print('element is ClassElement: ${element is ClassElement}');
            // if (element is ClassElement) {
            //   print('allSupertypes.length: ${element.allSupertypes.length}');
            //   print('allSupertypes: [');
            //   element.allSupertypes.forEach(((InterfaceType e) {
            //     print(e.element.library.identifier);
            //     print(e.getDisplayString(withNullability: true));
            //   }));
            //   print(']');
            // }

            if (fieldType == null || !_listenableChecker.isAssignableFromType(fieldType)) {
              continue;
            }

            // Check if the field is disposed in the dispose method
            if (disposeMethod == null || !disposeMethod.body.toSource().contains(name)) {
              reporter.reportErrorForNode(_code, variable);
            }
          }
        }
      }
    });
  }
}
