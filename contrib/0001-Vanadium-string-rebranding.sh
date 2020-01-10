#!/usr/bin/env bash

# execute routine steps to generate a "Vanadium string rebranding" patch
sed -i 's/Chrom\(e\|ium\)/Vanadium/g' chrome/android/java/strings/android_chrome_strings.grd components/components_chromium_strings.grd components/new_or_sad_tab_strings.grdp components/security_interstitials_strings.grdp
find components/strings/ -name '*.xtb' -exec sed -i 's/Chrom\(e\|ium\)/Vanadium/g' {} +
find chrome/android/java/strings/translations -name '*.xtb' -exec sed -i 's/Chrom\(e\|ium\)/Vanadium/g' {} +

#git commit -a -F- << EOF
#Vanadium string rebranding
#
#sed -i 's/Chrom\(e\|ium\)/Vanadium/g' chrome/android/java/strings/android_chrome_strings.grd components/components_chromium_strings.grd components/new_or_sad_tab_strings.grdp components/security_interstitials_strings.grdp
#find components/strings/ -name '*.xtb' -exec sed -i 's/Chrom\(e\|ium\)/Vanadium/g' {} +
#find chrome/android/java/strings/translations -name '*.xtb' -exec sed -i 's/Chrom\(e\|ium\)/Vanadium/g' {} +
#EOF
#
#git format-patch HEAD~1 && git reset HEAD~1
