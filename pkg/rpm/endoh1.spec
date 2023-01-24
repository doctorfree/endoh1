Name: endoh1
Version:    %{_version}
Release:    %{_release}
BuildArch:  x86_64
URL:        https://github.com/doctorfree/endoh1
Vendor:     Doctorwhen's Bodacious Laboratory
Packager:   ronaldrecord@gmail.com
License     : CC-by-sa
Summary     : Ascii fluid dynamics simulator

%global __os_install_post %{nil}

%description

%prep

%build

%install
cp -a %{_sourcedir}/usr %{buildroot}/usr

%pre

%post

%preun

%files
%defattr(-,root,root)
%exclude %dir /usr/share
%exclude %dir /usr/bin
/usr/bin/*
/usr/share/*

%changelog
