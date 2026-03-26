APP_NAME = SlickWallpaper
ARCH_FLAGS ?= 
BUILD_DIR = $(shell swift build -c release $(ARCH_FLAGS) --show-bin-path)
APP_BUNDLE = $(APP_NAME).app
SPM_BUNDLE = $(BUILD_DIR)/$(APP_NAME)_$(APP_NAME).bundle

build:
	swift build -c release $(ARCH_FLAGS)

bundle: build
	@echo "📦 Creating app bundle..."
	@rm -rf $(APP_BUNDLE)
	@mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	@mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	@cp $(BUILD_DIR)/$(APP_NAME) "$(APP_BUNDLE)/Contents/MacOS/"
	@cp Sources/SlickWallpaper/Resources/Info.plist "$(APP_BUNDLE)/Contents/"
	@# Copy SPM resource bundle contents if it exists
	@if [ -f "$(SPM_BUNDLE)/quoteitup.db" ]; then \
		cp "$(SPM_BUNDLE)/quoteitup.db" "$(APP_BUNDLE)/Contents/Resources/"; \
		echo "✅ Copied DB from SPM bundle"; \
	else \
		echo "⚠️  SPM bundle DB not found, copying DB manually"; \
		cp Sources/SlickWallpaper/Resources/quoteitup.db "$(APP_BUNDLE)/Contents/Resources/"; \
	fi
	@cp AppIcon.icns "$(APP_BUNDLE)/Contents/Resources/"
	@echo "✅ App bundle created: $(APP_BUNDLE)"

sign: bundle
	@echo "🔏 Ad-hoc signing..."
	codesign --force --deep --sign - "$(APP_BUNDLE)"
	@echo "✅ Signed"

run: sign
	@echo "🚀 Launching $(APP_NAME)..."
	open "$(APP_BUNDLE)"

debug:
	swift build
	codesign --force --deep --sign - .build/debug/$(APP_NAME)
	.build/debug/$(APP_NAME)

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)

.PHONY: build bundle sign run debug clean
