#!/usr/bin/env python3
import os, sys, glob

# Find whichever build.gradle variant flutter create generated
candidates = [
    'android/app/build.gradle.kts',
    'android/app/build.gradle',
]
path = next((p for p in candidates if os.path.exists(p)), None)
if path is None:
    files = glob.glob('android/app/**', recursive=True)
    print("android/app contents:", files)
    sys.exit(1)

print(f"Patching {path}")
with open(path, 'r') as f:
    c = f.read()

is_kts = path.endswith('.kts')

if is_kts:
    load_ks = (
        'import java.util.Properties\n'
        'import java.io.FileInputStream\n\n'
        'val keystoreProperties = Properties()\n'
        'val keystorePropertiesFile = rootProject.file("key.properties")\n'
        'if (keystorePropertiesFile.exists()) {\n'
        '    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n'
        '}\n\n'
    )
    signing_cfg = (
        '    signingConfigs {\n'
        '        create("release") {\n'
        '            keyAlias = keystoreProperties["keyAlias"] as String\n'
        '            keyPassword = keystoreProperties["keyPassword"] as String\n'
        '            storeFile = file(keystoreProperties["storeFile"] as String)\n'
        '            storePassword = keystoreProperties["storePassword"] as String\n'
        '        }\n'
        '    }\n'
    )
    release_signing = '            signingConfig = signingConfigs.getByName("release")\n'
    release_marker = '        release {\n'
else:
    load_ks = (
        'def keystoreProperties = new Properties()\n'
        'def keystorePropertiesFile = rootProject.file("key.properties")\n'
        'if (keystorePropertiesFile.exists()) {\n'
        '    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n'
        '}\n\n'
    )
    signing_cfg = (
        '    signingConfigs {\n'
        '        release {\n'
        '            keyAlias keystoreProperties["keyAlias"]\n'
        '            keyPassword keystoreProperties["keyPassword"]\n'
        '            storeFile file(keystoreProperties["storeFile"])\n'
        '            storePassword keystoreProperties["storePassword"]\n'
        '        }\n'
        '    }\n'
    )
    release_signing = '            signingConfig signingConfigs.release\n'
    release_marker = '        release {\n'

# Only patch if not already patched
if 'keystoreProperties' not in c:
    c = load_ks + c

if 'signingConfigs' not in c:
    c = c.replace('    buildTypes {', signing_cfg + '    buildTypes {', 1)

if 'signingConfig' not in c:
    c = c.replace(release_marker, release_marker + release_signing, 1)

with open(path, 'w') as f:
    f.write(c)

print(f'Signing config injected into {path}')
