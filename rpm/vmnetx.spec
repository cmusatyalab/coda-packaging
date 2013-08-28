%global selinux_policyver %(%{__sed} -e 's,.*selinux-policy-\\([^/]*\\)/.*,\\1,' /usr/share/selinux/devel/policyhelp 2>/dev/null || echo 0.0.0)
%global selinux_variants mls targeted minimal

Name:           vmnetx
Version:        0.4.0
Release:        1%{?dist}
Summary:        Virtual machine network execution

# desktop/vmnetx.png is under CC-BY-3.0
License:        GPLv2 and CC-BY
URL:            https://github.com/cmusatyalab/vmnetx
Source0:        https://olivearchive.org/vmnetx/source/%{name}-%{version}.tar.xz

BuildRequires:  python2-devel
BuildRequires:  pkgconfig
BuildRequires:  glib2-devel
BuildRequires:  libcurl-devel
BuildRequires:  fuse-devel
BuildRequires:  libxml2-devel
# For SELinux
BuildRequires:  selinux-policy-devel
BuildRequires:  selinux-policy-doc
BuildRequires:  checkpolicy
BuildRequires:  hardlink

Requires:       %{name}-common%{?_isa} = %{version}-%{release}
Requires:       pygtk2
Requires:       gtk-vnc-python
Requires:       spice-gtk-python


%description
VMNetX allows you to execute a KVM virtual machine over the Internet
without downloading all of its data to your computer in advance.


%package        common
Summary:        VMNetX support code
License:        GPLv2
Conflicts:      vmnetx < 0.4.0
Requires:       pygobject2
Requires:       python-lxml
Requires:       python-requests
Requires:       python-dateutil
Requires:       libvirt
Requires:       libvirt-python
Requires:       qemu-kvm
# For authorizer
Requires:       dbus-python
Requires:       dbus
Requires:       polkit
# For SELinux
Requires:       selinux-policy >= %{selinux_policyver}
Requires(post): /usr/sbin/semodule
Requires(postun): /usr/sbin/semodule

%description    common
This package includes support code for VMNetX.


%package        server
Summary:        VMNetX server
License:        GPLv2
Requires:       %{name}-common%{?_isa} = %{version}-%{release}
Requires:       python-flask
Requires:       python-msgpack
Requires:       PyYAML

%description    server
This package includes the VMNetX remote execution server.


%prep
%setup -q


%build
%configure
make %{?_smp_mflags}

# Build SELinux modules
for selinuxvariant in %{selinux_variants}
do
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile
    mv vmnetx.pp vmnetx.pp.${selinuxvariant}
    make NAME=${selinuxvariant} -f /usr/share/selinux/devel/Makefile clean
done


%install
make install DESTDIR=$RPM_BUILD_ROOT

# Let python-devel handle byte-compiling
find $RPM_BUILD_ROOT \( -name '*.pyc' -o -name '*.pyo' \) -exec rm -f {} ';'

# Install SELinux modules
for selinuxvariant in %{selinux_variants}
do
    install -d $RPM_BUILD_ROOT%{_datadir}/selinux/${selinuxvariant}
    install -p -m 644 vmnetx.pp.${selinuxvariant} \
        $RPM_BUILD_ROOT%{_datadir}/selinux/${selinuxvariant}/vmnetx.pp
done
hardlink -cv $RPM_BUILD_ROOT%{_datadir}/selinux


%files
%doc desktop/README.icon
%{_bindir}/vmnetx
%{_bindir}/vmnetx-generate
%{_datadir}/applications/vmnetx.desktop
%{_datadir}/icons/hicolor/256x256/apps/vmnetx.png
%{_datadir}/man/man1/*
%{_datadir}/mime/packages/vmnetx.xml


%files common
%doc COPYING README.rst NEWS.md
%{_sysconfdir}/dbus-1/system.d/org.olivearchive.VMNetX.Authorizer.conf
%{_libexecdir}/%{name}
%{python_sitelib}/*
%{_datadir}/dbus-1/system-services/org.olivearchive.VMNetX.Authorizer.service
%{_datadir}/polkit-1/actions/org.olivearchive.VMNetX.Authorizer.policy
%{_datadir}/selinux/*/vmnetx.pp


%files server
%{_sbindir}/vmnetx-server
%{_datadir}/man/man8/*


%post
/bin/touch --no-create %{_datadir}/icons/hicolor &>/dev/null ||:
/usr/bin/update-mime-database %{_datadir}/mime &> /dev/null ||:
/usr/bin/update-desktop-database &> /dev/null ||:


%postun
if [ $1 -eq 0 ] ; then
    /bin/touch --no-create %{_datadir}/icons/hicolor &>/dev/null
    /usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor &>/dev/null ||:
    /usr/bin/update-mime-database %{_datadir}/mime &> /dev/null ||:
    /usr/bin/update-desktop-database &> /dev/null ||:
fi


%posttrans
/usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor &>/dev/null ||:


%post common
for selinuxvariant in %{selinux_variants}
do
    /usr/sbin/semodule -s ${selinuxvariant} -i \
        %{_datadir}/selinux/${selinuxvariant}/vmnetx.pp &> /dev/null ||:
done


%postun common
if [ $1 -eq 0 ] ; then
    for selinuxvariant in %{selinux_variants}
    do
        /usr/sbin/semodule -s ${selinuxvariant} -r vmnetx &> /dev/null ||:
    done
fi


%changelog
* Wed Aug 28 2013 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 0.4.0-1
- New release
- Add -common and -server subpackages

* Fri Jun 21 2013 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 0.3.3-1
- New release

* Fri Apr 26 2013 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 0.3.2-1
- New release

* Mon Apr 22 2013 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 0.3.1-1
- New release

* Wed Apr 10 2013 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 0.3-1
- New release
- Update package and source URLs

* Sun Apr 08 2012 Benjamin Gilbert <bgilbert@cs.cmu.edu> - 0.2-1
- Initial release
