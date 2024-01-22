# QuickJS Build

1. Install Git
2. `git clone https://github.com/DarcJC/QuickJS-build.git && cd QuickJS-build && bash fetch_and_build.sh`
3. Get your static libraries in `quickjs/quickjs-[version]/build`.

## Environment Variables

**QUICKJS_VERSION** : Set the version of QuickJS to fetch. Default: `2024-01-13`.

**DESTINATION_DIR** : Set the temporary folder to download and build QuickJS with. Default: `quickjs`.

## Parameter

**--window** : Cross-compile to windows platform. You must install mingw first.

## No interactive

`echo "y" | bash fetch_and_build.sh`

