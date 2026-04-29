#!/usr/bin/env python3
import os, sys, glob

candidates = [
    'android/app/build.gradle.kts',
    'android/app/build.gradle',
]
path = next((p for p in candidates if os.path.exists(p)), None)
if path is None:
    print("ERROR: could not find build.gradle or build.gradle.kts")
    print("android/app contents:", glob.glob('android/app/**', recursive=True))
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
    debug_signing = 'signingConfig = signingConfigs.getByName("debug")'
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
    debug_signing = 'signingConfig signingConfigs.debug'

# 1. Add keystoreProperties loader at top (only if not already there)
if 'keystoreProperties' not in c:
    c = load_ks + c

# 2. Add signingConfigs block (only if not already there)
if 'signingConfigs' not in c:
    c = c.replace('    buildTypes {', signing_cfg + '    buildTypes {', 1)

# 3. Replace debug signing with release signing (covers both new and existing)
if debug_signing in c:
    # Replace the whole line containing the debug signingConfig
    lines = c.split('\n')
    new_lines = []
    replaced = False
    for line in lines:
        if debug_signing in line and not replaced:
            new_lines.append(release_signing.rstrip('\n'))
            replaced = True
        else:
            new_lines.append(line)
    c = '\n'.join(new_lines)
    print(f"Replaced debug signingConfig with release")
elif 'signingConfig' not in c:
    # No signingConfig at all — insert one
    c = c.replace('        release {\n', '        release {\n' + release_signing, 1)
    print("Inserted release signingConfig")
else:
    print("signingConfig already set to release — no change needed")

with open(path, 'w') as f:
    f.write(c)

print(f'Done patching {path}')
# Print the release block so we can verify in build log
in_release = False
for line in c.split('\n'):
    if 'release' in line and '{' in line:
        in_release = True
    if in_release:
        print(line)
    if in_release and '}' in line and 'release' not in line:
        break
