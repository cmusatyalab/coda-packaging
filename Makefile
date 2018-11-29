SOURCE_URL = http://coda.cs.cmu.edu/coda/source/coda-VERSION.tar.xz

OUTDIR = output
DEB_DISTS_DEBIAN = jessie stretch
DEB_DISTS_UBUNTU = trusty xenial bionic cosmic
DEB_DISTS = $(DEB_DISTS_DEBIAN) $(DEB_DISTS_UBUNTU)
DEB_ARCHES = amd64 i386
RPM_ROOTS_FEDORA := $(foreach dist,28 29,$(foreach arch,i386 x86_64,fedora-$(dist)-$(arch)))
RPM_ROOTS_EL := epel-6-x86_64 epel-7-coda-x86_64
RPM_ROOTS := $(RPM_ROOTS_FEDORA) $(RPM_ROOTS_EL)

jessie_DISTVER = debian8.0
stretch_DISTVER = debian9.0
trusty_DISTVER = ubuntu14.04
xenial_DISTVER = ubuntu16.04
bionic_DISTVER = ubuntu18.04
cosmic_DISTVER = ubuntu18.10

jessie_OTHER = |deb http://mirrors.kernel.org/debian/ DISTRO-backports main
trusty_INSTALL_SED = "/\\\(systemd\\\|modules-load\\\.d\\\)/\ d"

DEB_CHROOT_BASE = chroots
DEBIAN_KEYRING = /usr/share/keyrings/debian-archive-keyring.gpg
DEBIAN_MIRROR = http://debian.lcs.mit.edu/debian
DEBIAN_SOURCES = deb http://security.debian.org/ DISTRO/updates main
DEBIAN_COMPONENTS = main
UBUNTU_KEYRING = /usr/share/keyrings/ubuntu-archive-keyring.gpg
UBUNTU_MIRROR = http://ubuntu.media.mit.edu/ubuntu
UBUNTU_SOURCES = deb http://security.ubuntu.com/ubuntu DISTRO-security main
UBUNTU_COMPONENTS = main universe

DOCKER_REGISTRY = registry.cmusatyalab.org/coda/coda-packaging

# Build or update a pbuilder chroot for building Debian packages
# $1 = distribution
# $2 = architecture
# $3 = mirror
# $4 = other sources.list lines, pipe-delimited.  DISTRO will be substituted
#      with $1.
# $5 = keyring to check Release file against
# $6 = components (normal default is "main")
builddebroot = mkdir -p $(DEB_CHROOT_BASE) && \
	tgz="$(DEB_CHROOT_BASE)/$(1)-$(2).tgz" && \
	echo "====== $(1) $(2) ======" && \
	if [ -s "$$tgz" ] ; then \
		pbuilder --update --basetgz "$$tgz" ;\
	else \
		pbuilder --create --basetgz "$$tgz" --distribution "$(1)" \
			--architecture "$(2)" --mirror "$(3)" \
			--othermirror "$(subst DISTRO,$(1),$(4))" \
			--debootstrapopts --variant=buildd \
			--debootstrapopts --keyring=$(5) \
			--components "$(6)" ;\
	fi

# $1 = specfile
# $2 = roots
buildrpm = $(foreach root,$(2), \
		if [ ! -e "/etc/mock/$(root).cfg" ] ; then \
			echo "Missing mock root: $(root)" && \
			false ; \
		fi && ) \
	sources=`mktemp -dt coda-sources-XXXXXXXX` && \
	rpms=`mktemp -dt coda-rpms-XXXXXXXX` && \
	mkdir -p $(OUTDIR) && \
	$(foreach file,\
		$(shell spectool $(1) | awk '!/:\/\// {print $$2}'),\
		cp $(addprefix $(dir $(1)),$(notdir $(file))) $$sources && ) \
	spectool -C $$sources -g $(1) && \
	rpmbuild -bs --define "_sourcedir $$sources" \
		--define "_srcrpmdir $$sources" $(1) && \
	$(foreach root,$(2), \
		mock $$sources/*.src.rpm -r "$(root)" -v --resultdir $$rpms && \
		mv $$rpms/*.rpm $(OUTDIR) && ) \
	rm -rf $$sources $$rpms

.PHONY: none
none:
	@echo "Please specify a target."
	@exit 1

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

.PHONY: debroots
debroots:
	[ `id -u` = 0 ]
	@$(foreach dist,$(DEB_DISTS_DEBIAN),$(foreach arch,$(DEB_ARCHES), \
		$(call builddebroot,$(dist),$(arch),$(DEBIAN_MIRROR),$(DEBIAN_SOURCES)$($(dist)_OTHER),$(DEBIAN_KEYRING),$(DEBIAN_COMPONENTS)) && )) :
	@$(foreach dist,$(DEB_DISTS_UBUNTU),$(foreach arch,$(DEB_ARCHES), \
		$(call builddebroot,$(dist),$(arch),$(UBUNTU_MIRROR),$(UBUNTU_SOURCES),$(UBUNTU_KEYRING),$(UBUNTU_COMPONENTS)) && )) :

.PHONY: deb
deb:
	[ `id -u` = 0 ]
	mkdir -p $(OUTDIR)
	@tmp=`mktemp -dt debpkg-XXXXXXXX` && \
	project=`dpkg-parsechangelog | grep ^Source: | awk '{print $$2}'` && \
	version=`dpkg-parsechangelog | grep ^Version: | awk 'BEGIN {FS=" +|-"} {print $$2}'` && \
	source=`echo "$(SOURCE_URL)" | sed "s/VERSION/$$version/"` && \
	output=`pwd`/$(OUTDIR) && \
	wget -O $$tmp/$${project}_$${version}.orig.tar.xz $$source && \
	$(foreach arch,$(DEB_ARCHES),$(foreach dist,$(DEB_DISTS), \
		echo "====== $(dist) $(arch) ======" && \
		tar xf $$tmp/$${project}_$${version}.orig.tar.xz -C $$tmp && \
		cp -a debian $$tmp/$${project}-$${version}/ && \
		sed -i -e "s/DISTVER/$($(dist)_DISTVER)/g" \
			-e "s/UNRELEASED/$(dist)/g" \
			$$tmp/$${project}-$${version}/debian/changelog && \
		sed -i -e "$($(dist)_INSTALL_SED)" \
			$$tmp/$${project}-$${version}/debian/coda-client.install \
			$$tmp/$${project}-$${version}/debian/coda-server.install \
			$$tmp/$${project}-$${version}/debian/coda-update.install && \
		( cd $$tmp/$${project}-$${version}/ && \
		pdebuild --architecture $(arch) \
			--buildresult $(abspath $(OUTDIR)) \
			$(if $(filter $(arch), \
				$(word 1,$(DEB_ARCHES))),,--debbuildopts -B) \
			--use-pdebuild-internal -- --basetgz \
			"$(abspath $(DEB_CHROOT_BASE))/$(dist)-$(arch).tgz" \
		) && \
		rm -r $$tmp/$$project-$$version/ && )) : \
	rm -r $$tmp

.PHONY: rpm
rpm:
	@$(call buildrpm,rpm/coda.spec,$(RPM_ROOTS))

.PHONY: rpmrepo
rpmrepo:
	@# Build on a single representative root for each distribution.
	@$(call buildrpm,rpmrepo/coda-release-fedora.spec,fedora-28-i386)
	@$(call buildrpm,rpmrepo/coda-release-el.spec,epel-6-i386)

.PHONY: msi
msi:
	mkdir -p $(OUTDIR)
	@tmp=`mktemp -dt windows-XXXXXXXX` && \
	output=`pwd`/$(OUTDIR) && \
	for file in windows/* ; do \
		if [ -f $$file ] ; then \
			cp $$file $$tmp ; \
		fi ; \
	done && \
	( cd $$tmp && \
		./build.sh clean && \
		./build.sh sdist && \
		./build.sh -j10 bdist && \
		mv *.zip *.msi $$output ) && \
	rm -rf $$tmp

.PHONY: upload
upload:
	[ -n "$(CODA_DISTRIBUTE_HOST)" -a -n "$(CODA_INCOMING_DIR)" ]
	@rsync -rv "$(OUTDIR)/" \
		"$(CODA_DISTRIBUTE_HOST):$(CODA_INCOMING_DIR)"

.PHONY: distribute
distribute:
	[ -n "$(CODA_DISTRIBUTE_HOST)" -a -n "$(CODA_DISTRIBUTE_DIR)" ]
	[ -n "$(SIGNING_SERVER)" ]
	@SIGNING_SERVER_ADDRESS=localhost:5280 \
		SIGNING_SERVER_KEYID=$$(git config user.signingkey) \
		$(SIGNING_SERVER) ssh "$(CODA_DISTRIBUTE_HOST)" \
		-R 5280:localhost:5280 \
		"cd $(CODA_DISTRIBUTE_DIR) && SIGNING_SERVER_ADDRESS=localhost:5280 ./distribute.pl"

.PHONY: docker-image
docker-image:
	( cd docker-coda-build && \
		docker build -t $(DOCKER_REGISTRY)/coda-build . && \
		docker push $(DOCKER_REGISTRY)/coda-build )
