%define luajit_version 2.1
%define luajit_min_version 0
%define luajit_release beta3
%define luajit_bin_version %{luajit_version}.%{luajit_min_version}-%{luajit_release}

Name:           luajit
Version:        %{luajit_version}.%{luajit_min_version}
Release:        %{luajit_release}.1%{?dist}
Summary:        Just-In-Time Compiler for Lua
License:        MIT
URL:            http://luajit.org/
Source0:        http://luajit.org/download/LuaJIT-%{luajit_bin_version}.tar.gz

%if 0%{?rhel}
ExclusiveArch:  %{ix86} x86_64
%endif

Patch0:     create_symlink.patch

%description
LuaJIT implements the full set of language features defined by Lua 5.1.
The virtual machine (VM) is API- and ABI-compatible to the standard
Lua interpreter and can be deployed as a drop-in replacement.

%package devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description devel
This package contains development files for %{name}.

%prep
%setup -q -n LuaJIT-%{luajit_bin_version}
%patch0 -p1
echo '#!/bin/sh' > ./configure
chmod +x ./configure

# preserve timestamps (cicku)
sed -i -e '/install -m/s/-m/-p -m/' Makefile

%ifarch x86_64
%global multilib_flag MULTILIB=lib64
%endif

%build
%configure
# Q= - enable verbose output
# E= @: - disable @echo messages
# NOTE: we use amalgamated build as per documentation suggestion doc/install.html
make amalg Q= E=@: PREFIX=%{_prefix} TARGET_STRIP=: \
           CFLAGS="%{optflags}" \
           %{?multilib_flag} \
           %{?_smp_mflags}

%install
# PREREL= - disable -betaX suffix
# INSTALL_TNAME - executable name
%make_install PREFIX=%{_prefix} \
              %{?multilib_flag}

rm -rf _tmp_html ; mkdir _tmp_html
cp -a doc _tmp_html/html

# Remove static .a
find %{buildroot} -type f -name *.a -delete

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%{_bindir}/%{name}
%{_bindir}/%{name}-%{luajit_bin_version}
%{_libdir}/libluajit*.so.*
%{_mandir}/man1/luajit*
%{_datadir}/%{name}-%{luajit_bin_version}/

%files devel
%doc _tmp_html/html/
%{_includedir}/luajit-2.1/
%{_libdir}/libluajit*.so
%{_libdir}/pkgconfig/*.pc

%changelog
* Fri Jan 12 2018 Vinicius Mignot <vinicius.mignot@azion.com> - 2.1.0-beta3.1
- Spec for LuaJIT 2.1 created.
