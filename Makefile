APP = ClipboardManager
BUILD = build
SOURCES = Sources/*.swift

all: $(BUILD)/$(APP).app

$(BUILD)/$(APP).app: $(BUILD)/$(APP) Info.plist
	mkdir -p "$(BUILD)/$(APP).app/Contents/MacOS"
	mkdir -p "$(BUILD)/$(APP).app/Contents/Resources"
	cp "$(BUILD)/$(APP)" "$(BUILD)/$(APP).app/Contents/MacOS/"
	cp Info.plist "$(BUILD)/$(APP).app/Contents/"

$(BUILD)/$(APP): $(SOURCES)
	mkdir -p $(BUILD)
	swiftc -o "$(BUILD)/$(APP)" \
		-framework AppKit \
		-framework SwiftUI \
		$(SOURCES)

run: $(BUILD)/$(APP).app
	open "$(BUILD)/$(APP).app"

clean:
	rm -rf $(BUILD)

.PHONY: all run clean
