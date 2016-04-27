Name:		coda-release-fedora
Version:	3
Release:	1
Summary:	Coda release files for Fedora

License:	GPLv2
URL:		https://github.com/cmusatyalab/coda-packaging
Source0:	coda.repo
Source1:	RPM-GPG-KEY-coda
BuildArch:	noarch


%description
This package contains the Coda repository configuration for Yum.


%prep


%build


%install
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
sed -e 's/!!DIST!!/fedora/g' %{SOURCE0} \
	> $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/coda.repo
install -Dpm 644 %{SOURCE1} \
	$RPM_BUILD_ROOT%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-coda


%files
%config(noreplace) %{_sysconfdir}/yum.repos.d/*
%{_sysconfdir}/pki/rpm-gpg/RPM-GPG-KEY-coda


%changelog
* Wed Apr 27 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 3-1
- Updates for Coda repository

* Wed Apr 10 2013 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 2-1
- Update package URL
- Change repository URLs
- Enable signature checking
- Fix rpmlint warning

* Sun Apr 08 2012 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 1-1
- Initial release
