#!/usr/bin/env bash
cat ../lib/main.dart > main.dart
cd ../lib
cat $(ls | grep -v 'main.dart') >> ../scripts/main.dart
cd -
grep import < main.dart > imports.dart
grep -v import < main.dart > tmp.dart
LC_COLLATE=c sort -u imports.dart | grep : > imports_tmp.dart
cat imports_tmp.dart tmp.dart > main.dart
rm tmp.dart imports_tmp.dart imports.dart
flutter format main.dart

if command -v xclip &> /dev/null
then
    echo "Copied with xclip"
    xclip -selection clipboard < main.dart
elif command -v wl-copy &> /dev/null
then
    echo "Copied with wl-copy"
    wl-copy < main.dart
fi

