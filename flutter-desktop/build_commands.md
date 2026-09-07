flutter build macos --release

vpk pack \
  -u com.ayamedica.desktop \
  -v 1.0.23 \
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
  --releaseName "v1.0.23" \
  --tag v1.0.23 \
  --merge \
  --token github_ pat_ 11BANKSXY05uexFHN95g4T_FpiISxiQMav9Q6rVmXBszldQ5GWJLCjRY3jkaqWAPVf37BFGNJLtMAl6Aai



  2. Build:


flutter build windows --release
3. Package with vpk:


vpk pack ^
  -u com.ayamedica.desktop ^
  -v 1.0.23 ^
  -p build\windows\x64\runner\Release ^
  --packTitle "Ayamedica Desktop" ^
  -e ayamedica_desktop.exe ^
  --icon windows\runner\resources\app_icon.ico
4. Upload:


vpk upload github ^
  --repoUrl https://github.com/Ayamedica-MP/DesktopApp ^
  --publish ^
  --releaseName "v1.0.23" ^
  --tag v1.0.23 ^
  --merge ^
  --token github_ pat_ 11BANKSXY05uexFHN95g4T_FpiISxiQMav9Q6rVmXBszldQ5GWJLCjRY3jkaqWAPVf37BFGNJLtMAl6Aai