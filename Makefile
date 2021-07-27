buildtag := $(shell date "+%Y%m%d%H%M")
buildlast := $(shell ls builds|tail -1)

default:
	mkdir -p builds/
	cd package/ && zip -r ../builds/LOImpressProgressLine_$(buildtag).oxt ./ -x .DS_Store

clean:
	rm -rf builds/

install:
	/Applications/LibreOffice.app/Contents/MacOS/unopkg add builds/$(buildlast)

uninstall:
	/Applications/LibreOffice.app/Contents/MacOS/unopkg remove dz.user.progressline

update: uninstall default install

refresh:
	pkill -15 soffice || echo
	$(MAKE) update
	/Applications/LibreOffice.app/Contents/MacOS/soffice &
