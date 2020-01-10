#!/bin/sh

set -x

[ -z $ANDROID_CHROMIUM_TARGET_CPU ] && echo "must set chromium build target. bailing..." && exit 1
[ -z $ANDROID_CHROMIUM_TARGET_OS ] && echo "must set chromium build target. bailing..." && exit 1

[ $(ls /vanadium | wc -l) -eq 0 ] && echo "/chromium needs to be bind mounted to actual source directory on host. bailing..." && exit 1

ARG_FILE=/vanadium/args.gn
[ ! -f $ARG_FILE ] && ls /vanadium/ && echo "args.gn file not found in /vanadium dir. Bailing..." && exit 1

sed -i "s/target_os.*/target_os = \"$ANDROID_CHROMIUM_TARGET_OS\"/g" $ARG_FILE
sed -i "s/target_cpu.*/target_cpu = \"$ANDROID_CHROMIUM_TARGET_CPU\"/g" $ARG_FILE
[ ! -z $ANDROID_CHROMIUM_VERSION_NAME ] && sed -i "s/android_default_version_name.*/android_default_version_name = \"$ANDROID_CHROMIUM_VERSION_NAME\"/g" $ARG_FILE
[ ! -z $ANDROID_CHROMIUM_VERSION_CODE ] && sed -i "s/android_default_version_code.*/android_default_version_code = \"$ANDROID_CHROMIUM_VERSION_CODE\"/g" $ARG_FILE
[ ! -z $CHROMIUM_DEBUG_BUILD ] && sed -i "s/is_debug.*/is_debug = \"true\"/g" $ARG_FILE

# set a default git ident
set_gitconfig() {
    git config --global user.name "buildman"
    git config --global user.email "buildman@bob-the-builder.com"
}
set_gitconfig

cd /vanadium
# gets the default chromium version name arg from args.gn
[ -z $ANDROID_CHROMIUM_VERSION_NAME ] && export ANDROID_CHROMIUM_VERSION_NAME=$(awk '/android_default_version_name/ {print $3}' args.gn | tr -d '"')
git fetch --all
[ ! -z $VANADIUM_TAG ] && echo "VANADIUM_TAG set, checking out $VANADIUM_TAG" && git checkout $VANADIUM_TAG
# fetch chromium sources
echo "fetching chromium source"
[ ! -d src ] && fetch --nohooks android && gclient sync -D --with_branch_heads -r $ANDROID_CHROMIUM_VERSION_NAME --jobs 32
gclient sync -D --with_branch_heads -r $ANDROID_CHROMIUM_VERSION_NAME --jobs 32


[ ! -f vanadium.keystore ] && echo "no keystore included, generating an ephemeral one" && \
    keytool -genkey -v -keystore vanadium.keystore -alias vanadiumkey -keyalg RSA -keysize 4096 -sigalg SHA512withRSA -validity 10000 -dname "cn=GrapheneOS"

echo "applying patches" && \
    cd src && \
    git am --whitespace=nowarn ../*.patch

[ $? -ne 0 ] && echo "patch application failed" && git am --abort && exit 1
echo "checking vanadium.keystore exist?" && [ ! -f vanadium.keystore ] && cp ../vanadium.keystore .

echo "building"
if [ $CHROMIUM_DEBUG_BUILD ]; then
    gn args out/Debug
    ninja -C out/Debug/ chrome_modern_public_apk
    ninja -C out/Debug/ system_webview_apk
else
    gn args out/Default
    ninja -C out/Default/ chrome_modern_public_apk
    ninja -C out/Default/ system_webview_apk
fi

