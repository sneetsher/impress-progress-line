buildtag := $(shell date "+%Y%m%d%H%M")
default:
	mkdir -p builds/
	cd package/ && zip -r ../builds/LOImpressProgressLine_$(buildtag).oxt ./

clean:
	rm -rf builds/
