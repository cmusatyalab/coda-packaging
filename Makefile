OUTDIR = output
# debootstrap < 1.0.47 fails on wheezy, Debian #703146
DEB_DISTS_DEBIAN = squeeze
DEB_DISTS_UBUNTU = precise quantal raring
DEB_DISTS = $(DEB_DISTS_DEBIAN) $(DEB_DISTS_UBUNTU)
DEB_ARCHES = i386 amd64
RPM_ROOTS_FEDORA := $(foreach dist,17 18,$(foreach arch,i386 x86_64,fedora-$(dist)-$(arch)))
RPM_ROOTS_EL := $(foreach dist,6,$(foreach arch,x86_64,epel-$(dist)-$(arch)))
RPM_ROOTS := $(RPM_ROOTS_FEDORA) $(RPM_ROOTS_EL)

DEB_CHROOT_BASE = chroots
DEBIAN_KEYRING = /usr/share/keyrings/debian-archive-keyring.gpg
DEBIAN_MIRROR = http://debian.lcs.mit.edu/debian
DEBIAN_SOURCES = deb http://security.debian.org/ DISTRO/updates main
UBUNTU_KEYRING = /usr/share/keyrings/ubuntu-archive-keyring.gpg
UBUNTU_MIRROR = http://ubuntu.media.mit.edu/ubuntu
UBUNTU_SOURCES = deb http://security.ubuntu.com/ubuntu DISTRO-security main

# Build or update a pbuilder chroot for building Debian packages
# $1 = distribution
# $2 = architecture
# $3 = mirror
# $4 = other sources.list lines, pipe-delimited.  DISTRO will be substituted
#      with $1.
# $5 = keyring to check Release file against
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
			--debootstrapopts --keyring=$(5) ;\
	fi

# $1 = specfile
# $2 = roots
buildpackage = @sources=`mktemp -dt vmnetx-sources-XXXXXXXX` && \
	rpms=`mktemp -dt vmnetx-rpms-XXXXXXXX` && \
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
		$(call builddebroot,$(dist),$(arch),$(DEBIAN_MIRROR),$(DEBIAN_SOURCES),$(DEBIAN_KEYRING)) && )) :
	@$(foreach dist,$(DEB_DISTS_UBUNTU),$(foreach arch,$(DEB_ARCHES), \
		$(call builddebroot,$(dist),$(arch),$(UBUNTU_MIRROR),$(UBUNTU_SOURCES),$(UBUNTU_KEYRING)) && )) :

.PHONY: rpm
rpm:
	$(call buildpackage,rpm/vmnetx.spec,$(RPM_ROOTS))

.PHONY: rpmrepo
rpmrepo:
	@# Build on a single representative root for each distribution.
	$(call buildpackage,rpmrepo/vmnetx-release-fedora.spec,fedora-18-i386)
	$(call buildpackage,rpmrepo/vmnetx-release-el.spec,epel-6-i386)

.PHONY: distribute
distribute:
	[ -n "$(VMNETX_DISTRIBUTE_HOST)" -a -n "$(VMNETX_DISTRIBUTE_DIR)" ]
	[ -n "$(VMNETX_INCOMING_DIR)" ]
	rpm --define "_gpg_name $$(git config user.signingkey)" \
		--resign $(OUTDIR)/*.rpm >/dev/null
	rsync $(OUTDIR)/*.rpm \
		"$(VMNETX_DISTRIBUTE_HOST):$(VMNETX_INCOMING_DIR)"
	ssh "$(VMNETX_DISTRIBUTE_HOST)" \
		"cd $(VMNETX_DISTRIBUTE_DIR) && ./distribute.pl"
