call setup.bat
set "PKG_CONFIG_PATH=%devfolder%build\install"
cd "%devfolder%mexopencv"
make MATLABDIR=/d/OCTAVE/dev/octave WITH_OCTAVE=true WITH_CONTRIB=true NO_CV_PKGCONFIG_HACK=true all contrib
