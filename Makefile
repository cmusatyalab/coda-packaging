OUTDIR = output
RPM_ROOTS_FEDORA := $(foreach dist,17 18,$(foreach arch,i386 x86_64,fedora-$(dist)-$(arch)))
RPM_ROOTS_EL := $(foreach dist,6,$(foreach arch,i386 x86_64,epel-$(dist)-$(arch)))
RPM_ROOTS := $(RPM_ROOTS_FEDORA) $(RPM_ROOTS_EL)

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

.PHONY: rpm
rpm:
	$(call buildpackage,rpm/vmnetx.spec,$(RPM_ROOTS))

.PHONY: rpmrepo
rpmrepo:
	@# Build on a single representative root for each distribution.
	$(call buildpackage,rpmrepo/vmnetx-release-fedora.spec,fedora-18-i386)
	$(call buildpackage,rpmrepo/vmnetx-release-el.spec,epel-6-i386)
