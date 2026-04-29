#!/usr/bin/env python3
import os, sys, glob

candidates = ['android/app/build.gradle.kts', 'android/app/build.gradle']
path = next((p for p in candidates if os.path.exists(p)), None)
if path is None:
    print("ERROR: build.gradle(.kts) not found")
    print(glob.glob('android/app/**', recursive=True))
    sys.exit(1)

print(f"Patching {path}")
with open(path, 'r') as f:
    c = f.read()

is_kts = path.endswith('.kts')

if is_kts:
    loader = (
        'import java.util.Properties\n'
        'import java.io.FileInputStream\n\n'
        'val keystoreProperties = Properties()\n'
        'val keystorePropertiesFile = rootProject.file("key.properties")\n'
        'if (keystorePropertiesFile.exists()) {\n'
        '    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n'
        '}\n\n'
    )
    release_block = (
        '        create("release") {\n'
        '            keyAlias = keystoreProperties["keyAlias"] as String\n'
        '            keyPassword = keystoreProperties["keyPassword"] as String\n'
        '            storeFile = file(keystoreProperties["storeFile"] as String)\n'
        '            storePassword = keystoreProperties["storePassword"] as String\n'
        '        }\n'
    )
    debug_ref = 'signingConfig = signingConfigs.getByName("debug")'
    release_ref = 'signingConfig = signingConfigs.getByName("release")'
    signing_block_start = '    signingConfigs {'
else:
    loader = (
        'def keystoreProperties = new Properties()\n'
        'def keystorePropertiesFile = rootProject.file("key.properties")\n'
        'if (keystorePropertiesFile.exists()) {\n'
        '    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n'
        '}\n\n'
    )
    release_block = (
        '        release {\n'
        '            keyAlias keystoreProperties["keyAlias"]\n'
        '            keyPassword keystoreProperties["keyPassword"]\n'
        '            storeFile file(keystoreProperties["storeFile"])\n'
        '            storePassword keystoreProperties["storePassword"]\n'
        '        }\n'
    )
    debug_ref = 'signingConfig signingConfigs.debug'
    release_ref = 'signingConfig signingConfigs.release'
    signing_block_start = '    signingConfigs {'

# Step 1: add keystoreProperties loader at top of file
if 'keystoreProperties' not in c:
    c = loader + c
    print("Added keystoreProperties loader")

# Step 2: insert release signingConfig inside the existing signingConfigs block
if 'create("release")' not in c and 'release {' not in c.split('signingConfigs')[1].split('}')[0] if 'signingConfigs' in c else True:
    if signing_block_start in c:
        c = c.replace(signing_block_start, signing_block_start + '\n' + release_block, 1)
        print("Inserted release signingConfig block")
    else:
        print("WARNING: signingConfigs block not found — inserting before buildTypes")
        bt = '    buildTypes {'
        full_block = (
            signing_block_start + '\n' + release_block + '    }\n\n'
        )
        c = c.replace(bt, full_block + bt, 1)

# Step 3: replace debug signing reference with release
if debug_ref in c:
    c = c.replace(debug_ref, release_ref)
    print(f"Replaced: {debug_ref} -> {release_ref}")
else:
    print("No debug signingConfig reference found (already release or not present)")

with open(path, 'w') as f:
    f.write(c)

print(f"Done. Relevant section:")
for i, line in enumerate(c.split('\n')):
    if any(k in line for k in ['signingConfig', 'signingConfigs', 'keyAlias', 'storeFile']):
        print(f"  {i+1}: {line}")
