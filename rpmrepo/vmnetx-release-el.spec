Name:		vmnetx-release-el
Version:	2
Release:	1
Summary:	VMNetX release files for Enterprise Linux

License:	GPLv2
URL:		https://github.com/cmusatyalab/vmnetx-packaging
Source0:	vmnetx.repo
Source1:	RPM-GPG-KEY-vmnetx
BuildArch:	noarch


%description
This package contains the VMNetX repository configuration for Yum.


%prep


%build


%install
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
sed -e 's/!!DIST!!/el/g' %{SOURCE0} \
	> $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/vmnetx.repo
install -Dpm 644 %{SOURCE1} \
	$RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-vmnetx


%files
%config(noreplace) %{_sysconfdir}/yum.repos.d/*
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-vmnetx


%changelog
* Wed Apr 10 2013 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 2-1
- Update package URL
- Change repository URLs
- Enable signature checking
- Fix rpmlint warning

* Sun Apr 08 2012 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 1-1
- Initial release
