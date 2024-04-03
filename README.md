# Code Collab Lints

## Features

A custom set of lint rules for Dart and Flutter projects.

## Getting started

The application must contain an `analysis_options.yaml` with the following:

```yaml
analyzer:
  plugins:
    - custom_lint
```

And then add the following packages to the `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint:
  code_collab_lints:
    git: 'https://github.com/CodeCollabHub/code_collab_lints.git'
```

## Usage

Just restart Dart Analysis Server in your IDE or run the following command to analyze the project:

```bash
dart run custom_lint
```

## Additional information

The project is currently under development and will be updated with new rules and features.
