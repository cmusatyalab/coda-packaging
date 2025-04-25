DEB_DISTS_DEBIAN := bullseye bookworm
DEB_DISTS_UBUNTU := focal jammy noble
DEB_DISTS := $(DEB_DISTS_DEBIAN) $(DEB_DISTS_UBUNTU)

RPM_ROOTS_FEDORA := $(foreach dist,40 41,$(foreach arch,i386 x86_64,fedora-$(dist)-$(arch)))
RPM_ROOTS_EL := $(foreach dist,8 9,rocky+epel-$(dist)-x86_64)
RPM_ROOTS := $(RPM_ROOTS_FEDORA) $(RPM_ROOTS_EL)

OUTDIR := dist

.PHONY: none
none:
	@echo "Please specify a target."
	@exit 1

.PHONY: clean
clean:
	rm -rf $(OUTDIR) *.image

.PHONY: deb
deb: coda-build-deb.image debian/changelog
	mkdir -p $(OUTDIR)
	docker run --rm -it \
	    -v `pwd`:/src \
	    --privileged \
	    coda-build-deb:latest \
	    $(DEB_DISTS)

.PHONY: rpm
rpm: coda-build-rpm.image rpm/coda.spec
	mkdir -p $(OUTDIR)
	@docker run --rm -it \
	    -v `pwd`:/src \
	    --privileged \
	    coda-build-rpm:latest \
	    $(RPM_ROOTS)

#.PHONY: msi
#msi:
#	mkdir -p $(OUTDIR)
#	@tmp=`mktemp -dt windows-XXXXXXXX` && \
#	output=`pwd`/$(OUTDIR) && \
#	for file in windows/* ; do \
#		if [ -f $$file ] ; then \
#			cp $$file $$tmp ; \
#		fi ; \
#	done && \
#	( cd $$tmp && \
#		./build.sh clean && \
#		./build.sh sdist && \
#		./build.sh -j10 bdist && \
#		mv *.zip *.msi $$output ) && \
#	rm -rf $$tmp

.PHONY: upload
upload:
	[ -n "$(CODA_DISTRIBUTE_HOST)" -a -n "$(CODA_DISTRIBUTE_DIR)" ]
	@rsync -rv "$(OUTDIR)/" \
		"$(CODA_DISTRIBUTE_HOST):$(CODA_DISTRIBUTE_DIR)/incoming"

.PHONY: distribute
distribute:
	[ -n "$(CODA_DISTRIBUTE_HOST)" -a -n "$(CODA_DISTRIBUTE_DIR)" ]
	@ssh -o"RemoteForward $$(ssh $(CODA_DISTRIBUTE_HOST) gpgconf --list-dir agent-socket) $$(gpgconf --list-dir agent-extra-socket)" \
		-t $(CODA_DISTRIBUTE_HOST) "cd $(CODA_DISTRIBUTE_DIR) && SIGNING_KEYID=$$(git config user.signingkey) ./distribute.py"

fix-debrepo:
	@ssh -o"RemoteForward $$(ssh $(CODA_DISTRIBUTE_HOST) gpgconf --list-dir agent-socket) $$(gpgconf --list-dir agent-extra-socket)" \
		-t $(CODA_DISTRIBUTE_HOST) "cd $(CODA_DISTRIBUTE_DIR) && reprepro --confdir=/home/repos/conf export"

debian/changelog rpm/coda.spec: coda-*.tar.xz
	rm -rf $(OUTDIR)
	./setup-release.sh

## rebuild local docker build container images
NOCACHE = # --no-cache
.SUFFIXES: .image
%.image: %/*
	docker build $(NOCACHE) -t $* $*
	@touch $*.image

.PHONY: docker-image
docker-image: coda-build-src.image coda-build-deb.image coda-build-rpm.image

