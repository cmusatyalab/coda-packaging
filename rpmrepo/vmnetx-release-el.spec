Name:		vmnetx-release-el
Version:	1
Release:	1
Summary:	VMNetX release files for Enterprise Linux

License:	GPLv2
URL:		https://github.com/vmnetx/vmnetx-packaging
Source0:	vmnetx.repo
BuildArch:	noarch


%description
This package contains the VMNetX repository configuration for Yum.


%prep


%build


%install
install -d -m 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
sed -e 's/!!DIST!!/el/g' %{SOURCE0} \
        > $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d/vmnetx.repo


%files
%config(noreplace) %{_sysconfdir}/yum.repos.d/*

%changelog
* Sun Apr 08 2012 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 1-1
- Initial release
