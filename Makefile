DEB_DISTS_DEBIAN := jessie stretch buster # bullseye
DEB_DISTS_UBUNTU := xenial bionic focal groovy
DEB_DISTS := $(DEB_DISTS_DEBIAN) $(DEB_DISTS_UBUNTU)

RPM_ROOTS_FEDORA := $(foreach dist,32 33,$(foreach arch,i386 x86_64,fedora-$(dist)-$(arch)))
RPM_ROOTS_EL := epel-7-coda-x86_64 epel-8-x86_64
RPM_ROOTS := $(RPM_ROOTS_FEDORA) $(RPM_ROOTS_EL)

DOCKER_REGISTRY := # registry.cmusatyalab.org/coda/coda-packaging/
OUTDIR := dist

.PHONY: none
none:
	@echo "Please specify a target."
	@exit 1

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

.PHONY: deb
deb: debian/changelog
	mkdir -p $(OUTDIR)
	@docker run --rm -it \
	    -v `pwd`:/src \
	    --privileged \
	    --entrypoint ./build-debs.sh \
	    $(DOCKER_REGISTRY)build-container-ubuntu:latest \
	    --in-docker $(DEB_DISTS)

.PHONY: rpm
rpm: rpm/coda.spec
	mkdir -p $(OUTDIR)
	@docker run --rm -it \
	    -v `pwd`:/src \
	    --privileged \
	    --entrypoint ./build-rpms.sh \
	    $(DOCKER_REGISTRY)build-container-fedora:latest \
	    --in-docker $(RPM_ROOTS)

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
	[ -n "$(SIGNING_SERVER)" ]
	@SIGNING_SERVER_ADDRESS=localhost:5280 \
		SIGNING_SERVER_KEYID=$$(git config user.signingkey) \
		$(SIGNING_SERVER) ssh "$(CODA_DISTRIBUTE_HOST)" \
		-R 5280:localhost:5280 \
		"cd $(CODA_DISTRIBUTE_DIR) && SIGNING_SERVER_ADDRESS=localhost:5280 ./distribute.pl"

fix-debrepo:
	@SIGNING_SERVER_ADDRESS=localhost:5280 \
		SIGNING_SERVER_KEYID=$$(git config user.signingkey) \
		$(SIGNING_SERVER) ssh "$(CODA_DISTRIBUTE_HOST)" \
		-R 5280:localhost:5280 \
		"cd $(CODA_DISTRIBUTE_DIR) && SIGNING_SERVER_ADDRESS=localhost:5280 reprepro --confdir=conf export"

.PHONY: docker-image
docker-image:
	( cd coda-build && \
	  docker build --no-cache -t $(DOCKER_REGISTRY)coda-build . ) \
	( cd build-container-ubuntu && \
	  docker build --no-cache -t $(DOCKER_REGISTRY)build-container-ubuntu .) \
	( cd build-container-fedora && \
	  docker build --no-cache -t $(DOCKER_REGISTRY)build-container-fedora . ) \
	[ -z "$(DOCKER_REGISTRY)" ] && true || \
	  docker push $(DOCKER_REGISTRY)coda-build && \
	  docker push $(DOCKER_REGISTRY)build-container-ubuntu && \
	  docker push $(DOCKER_REGISTRY)build-container-fedora

debian/changelog rpm/coda.spec: coda-*.tar.xz
	rm -rf $(OUTDIR)
	./setup-release.sh
