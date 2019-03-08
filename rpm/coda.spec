Name:           coda
Version:        7.0.5
Release:        1%{?dist}
Summary:        Coda distributed file system
Group:          System Environment/Daemons
License:        GPLv2
URL:            http://coda.cs.cmu.edu/
Source0:        http://coda.cs.cmu.edu/coda/source/%{name}-%{version}.tar.xz

BuildRequires:  readline-devel
BuildRequires:  flex bison python perl
BuildRequires:  e2fsprogs-devel
# For /etc/rc.d/init.d so that configure can detect we have RH style init
BuildRequires:  chkconfig
Requires:       readline

# Avoid systemd dependency on RHEL6
%if ! 0%{?el6}
BuildRequires:  systemd
%{?systemd_requires}
%endif

# Hardened build for long running and/or running as root programs
%global _hardened_build 1


%description
Source package for the Coda file system. Four packages are provided by
this rpm: the client, server, and common components. Separately
you must install a kernel module, or have a Coda enabled kernel, and
you should get the Coda documentation package.


%package client
Summary:        Client for the Coda distributed file system
Group:          System Environment/Daemons
Requires:       coda-common = %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig

%description client
This package contains the main client program, the cachemanager Venus.
Also included are the binaries for the cfs, utilities for logging, ACL
manipulation etc, the hoarding tools for use with laptops and repair
tools for fixing conflicts. Finally there is the cmon and codacon
console utilities to monitor Coda's activities. You need a Coda
kernel-module for your kernel version, or Coda in your kernel, to have
a complete coda client.


%package server
Summary:        Server for the Coda distributed file system
Group:          System Environment/Daemons
Requires:       coda-common = %{version}-%{release}
Requires(post): chkconfig
Requires(preun): chkconfig

%description server
This package contains the fileserver for the Coda file system, as well
as the volume utilities.


%package gcodacon
Summary:	Graphical tray monitor for the Coda distributed file system
Group:          System Environment/Daemons
Requires:       coda-client = %{version}-%{release}
Requires:	pygtk2 notify-python

%description gcodacon
This package contains gcodacon, a graphical tray monitor for the Coda
distributed file system client.


%package common
Summary:        LWP, RPC2 and RVM libraries for the Coda distributed file system
Group:          System Environment/Daemons

%description common
This package contains LWP, RPC2 and RVM libraries used by the Coda file system
client and server binaries.


%prep
%setup -q

# Avoid rerunning autotools
touch -r aclocal.m4 configure configure.ac configs/*.m4

%build
export PKG_CONFIG_PATH="$(pwd)/lib-src/lwp:$(pwd)/lib-src/rpc2:$(pwd)/lib-src/rvm:$PKG_CONFIG_PATH"
%configure --libdir="%{_libdir}/coda" --disable-static
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT INSTALL="install -p"

%if 0%{?el6}
# install init scripts
install -d $RPM_BUILD_ROOT/%{_initddir}/
install -p tools/coda-client.init $RPM_BUILD_ROOT/%{_initddir}/coda-client
install -p tools/coda-server.init $RPM_BUILD_ROOT/%{_initddir}/coda-server
install -p tools/coda-update.init $RPM_BUILD_ROOT/%{_initddir}/coda-update
%endif

# coda mount point for the client
mkdir -p $RPM_BUILD_ROOT/coda
touch $RPM_BUILD_ROOT/coda/NOT_REALLY_CODA

# coda cache/log dirs for the client
mkdir -p $RPM_BUILD_ROOT/%{_var}/lib/coda
mkdir -p $RPM_BUILD_ROOT/%{_var}/lib/coda/cache
mkdir -p $RPM_BUILD_ROOT/%{_var}/lib/coda/spool
mkdir -p $RPM_BUILD_ROOT/%{_var}/log/coda

# for %%ghost
touch $RPM_BUILD_ROOT%{_sysconfdir}/coda/{venus,server}.conf

#remove parser, it conflicts with grib_api
rm -f $RPM_BUILD_ROOT%{_bindir}/parser

# remove build/development files we don't care to package
find $RPM_BUILD_ROOT -name '*.h' -exec rm -f {} ';'
find $RPM_BUILD_ROOT -name '*.la' -exec rm -f {} ';'
find $RPM_BUILD_ROOT -name '*.pc' -exec rm -f {} ';'
find $RPM_BUILD_ROOT -name '*.so' -exec rm -f {} ';'
rm -f $RPM_BUILD_ROOT/%{_bindir}/rp2gen


%clean
rm -rf $RPM_BUILD_ROOT


%post client
# not pretty, but we cannot simply put /coda in our files-list because then
# rpm will fail when updating coda-client when coda is mounted
if [ ! -e /coda ]; then
    mkdir /coda
    touch /coda/NOT_REALLY_CODA
fi
%if ! 0%{?el6}
%systemd_post coda-client.service
%else
/sbin/chkconfig --add coda-client
%endif

%preun client
%if ! 0%{?el6}
%systemd_preun coda-client.service
%else
/sbin/chkconfig --del coda-client
%endif

%if ! 0%{?el6}
%postun client
%systemd_postun
%endif

%files client
%defattr(-,root,root,-)
%doc AUTHORS ChangeLog LICENSE NEWS
%dir %{_sysconfdir}/coda
%ghost %config(noreplace) %{_sysconfdir}/coda/venus.conf
%config(noreplace) %{_sysconfdir}/coda/venus.conf.ex
%config(noreplace) %{_sysconfdir}/coda/realms
%if %{defined _unitdir}
%{_unitdir}/coda-client.service
/usr/lib/modules-load.d/coda.conf
%else
%{_initddir}/coda-client
%endif
%{_sbindir}/asrlauncher
%{_sbindir}/venus
%{_sbindir}/coda-client-setup
%{_sbindir}/volmunge
%{_sbindir}/vutil
%{_bindir}/au
%{_bindir}/cfs
%{_bindir}/clog
%{_bindir}/cmon
%{_bindir}/codacon
%{_bindir}/cpasswd
%{_bindir}/ctokens
%{_bindir}/cunlog
%{_bindir}/filerepair
%{_bindir}/hoard
%{_bindir}/mkcodabf
%{_bindir}/mklka
%{_bindir}/removeinc
%{_bindir}/repair
%{_bindir}/coda_replay
%{_bindir}/spy
%{_bindir}/xaskuser
%{_bindir}/xfrepair
%{_mandir}/man1/au.1.gz
%{_mandir}/man1/cfs.1.gz
%{_mandir}/man1/clog.1.gz
%{_mandir}/man1/cmon.1.gz
%{_mandir}/man1/coda_replay.1.gz
%{_mandir}/man1/cpasswd.1.gz
%{_mandir}/man1/ctokens.1.gz
%{_mandir}/man1/cunlog.1.gz
%{_mandir}/man1/hoard.1.gz
%{_mandir}/man1/mkcodabf.1.gz
%{_mandir}/man1/repair.1.gz
%{_mandir}/man1/spy.1.gz
%{_mandir}/man8/venus.8.gz
%{_mandir}/man8/coda-client-setup.8.gz
%{_mandir}/man8/volmunge.8.gz
%{_mandir}/man8/vutil.8.gz
%ghost %dir /coda
%ghost /coda/NOT_REALLY_CODA
%dir %{_var}/lib/coda
%dir %{_var}/lib/coda/cache
%dir %{_var}/lib/coda/spool
%dir %{_var}/log/coda


%post server
%if ! 0%{?el6}
%systemd_post coda-server.service coda-auth2.service coda-update-master.service coda-update-slave.service
%else
/sbin/chkconfig --add coda-update
/sbin/chkconfig --add coda-server
%endif

%preun server
%if ! 0%{?el6}
%systemd_preun coda-server.service coda-auth2.service coda-update-master.service coda-update-slave.service
%else
/sbin/chkconfig --del coda-update
/sbin/chkconfig --del coda-server
%endif

%if ! 0%{?el6}
%postun server
%systemd_postun_with_restart coda-server.service coda-auth2.service coda-update-master.service coda-update-slave.service
%endif

%files server
%defattr(-,root,root,-)
%doc AUTHORS ChangeLog LICENSE NEWS
%dir %{_sysconfdir}/coda
%ghost %config(noreplace) %{_sysconfdir}/coda/server.conf
%config(noreplace) %{_sysconfdir}/coda/server.conf.ex
%if %{defined _unitdir}
%{_unitdir}/coda-server.service
%{_unitdir}/coda-auth2.service
%{_unitdir}/coda-update-master.service
%{_unitdir}/coda-update-slave.service
%else
%{_initddir}/coda-server
%{_initddir}/coda-update
%endif
%{_sbindir}/auth2
%{_sbindir}/bldvldb.sh
%{_sbindir}/coda-server-logrotate
%{_sbindir}/codadump2tar
%{_sbindir}/codamergedump
%{_sbindir}/codareaddump
%{_sbindir}/codasrv
%{_sbindir}/codastart
%{_sbindir}/createvol_rep
%{_sbindir}/initpw
%{_sbindir}/inoder
%{_sbindir}/norton
%{_sbindir}/norton-reinit
%{_sbindir}/partial-reinit.sh
%{_sbindir}/pdbtool
%{_sbindir}/printvrdb
%{_sbindir}/purgevol_rep
%{_sbindir}/rdsinit
%{_sbindir}/rvmutl
%{_sbindir}/startserver
%{_sbindir}/tokentool
%{_sbindir}/updatesrv
%{_sbindir}/updateclnt
%{_sbindir}/updatefetch
%{_sbindir}/vice-killvolumes
%{_sbindir}/vice-setup
%{_sbindir}/vice-setup-rvm
%{_sbindir}/vice-setup-srvdir
%{_sbindir}/vice-setup-user
%{_sbindir}/vice-setup-scm
%{_sbindir}/volutil
%{_bindir}/getvolinfo
%{_bindir}/reinit
%{_bindir}/rpc2ping
%{_bindir}/rvmsizer
%{_bindir}/smon2
%{_mandir}/man1/rdsinit.1.gz
%{_mandir}/man1/rvmutl.1.gz
%{_mandir}/man5/codadumpfile.5.gz
%{_mandir}/man5/maxgroupid.5.gz
%{_mandir}/man5/passwd.coda.5.gz
%{_mandir}/man5/servers.5.gz
%{_mandir}/man5/vicetab.5.gz
%{_mandir}/man5/volumelist.5.gz
%{_mandir}/man5/vrdb.5.gz
%{_mandir}/man8/auth2.8.gz
%{_mandir}/man8/bldvldb.sh.8.gz
%{_mandir}/man8/codamergedump.8.gz
%{_mandir}/man8/codareaddump.8.gz
%{_mandir}/man8/codasrv.8.gz
%{_mandir}/man8/createvol_rep.8.gz
%{_mandir}/man8/initpw.8.gz
%{_mandir}/man8/norton.8.gz
%{_mandir}/man8/pdbtool.8.gz
%{_mandir}/man8/purgevol_rep.8.gz
%{_mandir}/man8/startserver.8.gz
%{_mandir}/man8/updateclnt.8.gz
%{_mandir}/man8/updatesrv.8.gz
%{_mandir}/man8/vice-setup.8.gz
%{_mandir}/man8/volutil.8.gz


%files gcodacon
%defattr(-,root,root,-)
%{_bindir}/gcodacon


%files common
%defattr(-,root,root,-)
%{_sbindir}/codaconfedit
%{_libdir}/coda/*.so.*


%changelog
* Fri Mar 08 2019 Jan Harkes <jaharkes@cs.cmu.edu> - 7.0.5-1
- New upstream release.

* Thu Jan 24 2019 Jan Harkes <jaharkes@cs.cmu.edu> - 7.0.4-1
- New upstream release.

* Tue Jan 22 2019 Jan Harkes <jaharkes@cs.cmu.edu> - 7.0.3-1
- New upstream release.

* Thu Jan 17 2019 Jan Harkes <jaharkes@cs.cmu.edu> - 7.0.2-1
- New upstream release.

* Thu Dec 20 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 7.0.1-1
- New upstream release.

* Thu Dec 20 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 7.0.0-1
- New upstream release.

* Thu Nov 29 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.15.3-1
- New upstream release.

* Thu Oct 25 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.15.2-1
- New upstream release.

* Wed Oct 17 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.15.1-1
- New upstream release.

* Tue Oct 16 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.15.0-1
- New upstream release.

* Fri Jun 29 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.14.0-1
- New upstream release.

* Tue Jun 12 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.13.4-1
- New upstream release.

* Tue Jun 12 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.13.3-1
- New upstream release.

* Tue Jun 05 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.13.2-1
- New upstream release.

* Tue Jun 05 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.13.1-1
- New upstream release.

* Wed May 23 2018 Jan Harkes <jaharkes@cs.cmu.edu> - 6.13.0-1
- New upstream release.

* Wed Oct 11 2017 Jan Harkes <jaharkes@cs.cmu.edu> - 6.12.0-1
- New upstream release.

* Wed Jun 14 2017 Jan Harkes <jaharkes@cs.cmu.edu> - 6.11.2-1
- New upstream release.

* Mon Jan 23 2017 Jan Harkes <jaharkes@cs.cmu.edu> - 6.11.1-1
- New upstream release.

* Mon Jan 23 2017 Jan Harkes <jaharkes@cs.cmu.edu> - 6.11.0-1
- New upstream release.

* Thu Dec 15 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.10.0-2
- Don't use .init extension for init scripts.

* Tue Oct 25 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.10.0-1
- New upstream release.

* Tue Oct 04 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.9.10-2
- Reinstate init scripts on RHEL6.

* Thu Sep 29 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.9.10-1
- New upstream release.
- Reenabled builds for RHEL6/RHEL7.
- Build hardened binaries (PIC/Fortify).

* Fri Sep 23 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.9.9-1
- New upstream release.
- Remove coda-backup package.

* Wed Jul 20 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.9.8-1
- New upstream release.

* Fri May 27 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.9.7-1
- New upstream release.

* Tue Apr 26 2016 Jan Harkes <jaharkes@cs.cmu.edu> - 6.9.6-1
- New upstream release.
- Don't build kerberos and vcodacon.
- Install LWP, RPC2 and RVM in %{_libdir}/coda/.

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 6.9.5-16
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue Mar 11 2014 Neil Horman <nhorman@redhat.com> - 6.9.5-15
- Fixed pid file name for auth2 services (bz 1074321)

* Mon Mar 03 2014 Neil Horman <nhorman@redhat.com> - 6.9.5-14
- Fixed service file startup script (bz 1071534)

* Tue Dec 03 2013 Neil Horman <nhorman@redhat.com> - 6.9.5-13
- Fixed format-secure errors (bz 1037020)

* Wed Aug 28 2013 Neil Horman <nhorman@redhat.com> - 6.9.5-12
- Rebuilt with fixed obsoletes tags

* Sat Aug 03 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 6.9.5-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Wed Jul 17 2013 Petr Pisar <ppisar@redhat.com> - 6.9.5-10
- Perl 5.18 rebuild

* Wed Feb 13 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 6.9.5-9
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Wed Jul 18 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 6.9.5-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Fri Jan 06 2012 Neil Horman <nhorman@redhat.com> - 6.9.5-6
- Converted sysv init script to systemd scripts (bz 771490)

* Sun Jun 12 2011 Ralf Corsépius <corsepiu@fedoraproject.org> - 6.9.5-6
- Extend coda-6.9.5-vcodacon-configure.patch to reflect fltk headers having
  changed (Fix FTBS).
- Add "touch-magic" to avoid rerunning the autotools.
- Revert the Fri Jun 03 2011's spec changes.

* Fri Jun 03 2011 Neil Horman <nhorman@redhat.com> - 6.9.5-5
- Found an additional missing depends

* Fri Jun 03 2011 Neil Horman <nhorman@redhat.com> - 6.9.5-5
- Fixed broken dep on fltk for coda-vcodacon 

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 6.9.5-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Wed May 19 2010 Adam Goode <adam@spicenitz.org> - 6.9.5-3
- Split out gcodacon
- Macroize /usr stuff

* Tue May 18 2010 Adam Goode <adam@spicenitz.org> - 6.9.5-2
- Relax the build requires versions for the coda libraries

* Tue May 18 2010 Adam Goode <adam@spicenitz.org> - 6.9.5-1
- Remove many patches merged upstream
- New upstream release
  + When writing a checkpoint file of the reintegration log took
    longer than the checkpoint interval, we would immediately start
    writing out a new checkpoint, looping indefinitly. (Paolo
    Casanova)
  + Checkpointing failed when the reintegration log contained an empty file.
  + Truncate cache file when lookaside lookup fails to avoid the
    following fetch from assuming we already successfully fetched some
    of the data.
  + Make sure we wake up blocked threads when a fetch fails.
  + Only close the shadow file descriptor during reintegration if we
    actually opened it.
  + Return permission error when a user tries to rmdir a mountpoint.
  + Do not flush kernel caches whenever we check if a file is in use.
  + gcodacon improvements, notification rate limiting and window
    placement. (Benjamin Gilbert)
  + Reduce server->client RPC2 timeout from 60 to 30 seconds, reduces the
    time a client is blocked while callbacks are broken.
  + Introduce stricter locking on the server->client callback connections.
  + Make sure clients cannot indefinitely keep a callback break RPC busy
    preventing it from completing.
  + Write a stack backtrace to the log when an assertion fails.
  + Don't create /etc/modules.conf on newer Linux kernels (Adam Goode)

* Fri Dec 04 2009 Neil Horman <nhorman@redhat.com> - 6.9.4-9
- Convert venus-setup to coda-client-setup (bz 544096)

* Thu Sep 17 2009 Adam Goode <adam@spicenitz.org> - 6.9.4-8
- Patch venus-setup.in to remove unnecessary modules.conf stuff

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 6.9.4-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Thu Jul 23 2009 Neil Horman <nhorman@redhat.com> - 6.9.4-6
- Fix misuse of depricated udevsettle

* Mon Jul 20 2009 Neil Horman <nhorman@redhat.com> - 6.9.4-5
- Fix some sname stack overflows

* Mon Jul 20 2009 Neil Horman <nhorman@redhat.com> - 6.9.4-4
- Further changes to support compat-readline5 (bz 511305)

* Fri Jul 17 2009 Neil Horman <nhorman@redhat.com> - 6.9.4-3
- Change spec to require compat-readline5 (bz 511305)

* Tue Mar 31 2009 Neil Horman <nhorman@redhat.com> - 6.9.4-2
- Remove parser from coda-client, due to name conflict (bz 492953)

* Fri Feb 27 2009 Adam Goode <adam@spicenitz.org> - 6.9.4-1
- New upstream release
  + Avoid possible crashes and/or data loss when volumes are removed
    from and re-added to the client cache.
  + Add configuration setting (detect_reintegration_retry) for Coda
    clients running in a VMM which prevents dropping reintegrated
    operations when the virtual machine is reset to an earlier snapshot.
  + Do not assert on various non-fatal conditions (failing chown/chmod)
    that may arise when for instance the client cache is stored on a vfat
    formatted file system.
  + During backups, avoid unlocking locks that may have been taken by
    another thread.
  + Allow changing of the ctime/mtime of symlinks.
  + Avoid a server deadlock by correcting lock ordering between ViceFetch,
    ViceGetAttr and ViceValidataAttrs (problem identified and tracked down
    with lots of help from Rune).
  + Improve tar support and add cpio archive formats for modification log
    checkpoints.
  + Do not invoke server resolution on a single available replica.
  + Add new incremental dump format that maintains full path information
    when converting the resulting volume dump to a tar archive.
- Remove -D_GNU_SOURCE
- Drop sudo patch (upstream)
- Drop SIGTERM patch (upstream)

* Tue Feb 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 6.9.4-0.4.rc2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Sun Sep 14 2008 Adam Goode <adam@spicenitz.org> - 6.9.4-0.3.rc2
- Do not change the default behavior of clog when building with krb5
  (rh 462179)

* Tue Sep 09 2008 Neil Horman <nhorman@redhat.com> 6.9.4-0.2.rc2
- Enabling krb5 support (bz 461041)

* Thu May 29 2008 Hans de Goede <j.w.r.degoede@hhs.nl> 6.9.4-0.1.rc2
- Update to 6.9.4~rc2 (bz 448749)

* Tue May 20 2008 Hans de Goede <j.w.r.degoede@hhs.nl> 6.9.3-2
- Make coda-client package put everything in FHS locations like Debian does,
  rename coda-client initscript / service from venus to coda-client (rh 446653)

* Mon May 12 2008 Hans de Goede <j.w.r.degoede@hhs.nl> 6.9.3-1
- Initial Fedora package
