#!/usr/bin/env bash
cat ../lib/* > main.dart
grep import < main.dart > imports.dart
grep -v import < main.dart > tmp.dart
LC_COLLATE=c sort -u imports.dart | grep : > imports_tmp.dart
cat imports_tmp.dart tmp.dart > main.dart
rm tmp.dart imports_tmp.dart imports.dart
flutter format main.dart
cat main.dart | xclip -selection clipboard
