flutter build macos --release

vpk pack \
  -u com.ayamedica.desktop \
  -v 1.0.1 \
  -p build/macos/Build/Products/Release/ayamedica_desktop.app \
  --packTitle "Ayamedica Desktop" \
  -e ayamedica_desktop \
  --signAppIdentity "Developer ID Application: Shoumanz LLC (YRTDZM895L)" \
  --signInstallIdentity "Developer ID Installer: Shoumanz LLC (YRTDZM895L)" \
  --notaryProfile "ayamedica-notary" \
  --signEntitlements macos/Runner/Release.entitlements


vpk upload github \
  --repoUrl https://github.com/Ayamedica-MP/DesktopApp \
  --publish \
  --releaseName "v1.0.1" \
  --tag v1.0.1 \
  --token github _pat _11BANKSXY0wdrdKR2GIBgb_JxlUs6ehPxi7p2meCnT39PiQtmcJu614xfUVyPER1IJSJYSADBO4luoyG69



  2. Build:


flutter build windows --release
3. Package with vpk:


vpk pack ^
  -u com.ayamedica.desktop ^
  -v 1.0.4 ^
  -p build\windows\x64\runner\Release ^
  --packTitle "Ayamedica Desktop" ^
  -e ayamedica_desktop.exe
4. Upload:


vpk upload github ^
  --repoUrl https://github.com/Ayamedica-MP/DesktopApp ^
  --publish ^
  --releaseName "v1.0.4" ^
  --tag v1.0.4 ^
  --token YOUR_TOKEN