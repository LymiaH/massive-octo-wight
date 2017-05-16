call setup.bat
cd %devfolder%
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE:STRING=Release -DOPENCV_EXTRA_MODULES_PATH:PATH="%devfolder%opencv_contrib/modules" -DOPENCV_ENABLE_NONFREE:BOOL=ON -DWITH_CUDA:BOOL=OFF -DWITH_CUFFT:BOOL=OFF -DWITH_EIGEN:BOOL=OFF -DWITH_MATLAB:BOOL=OFF -DWITH_VTK:BOOL=OFF -DBUILD_DOCS:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DBUILD_PACKAGE:BOOL=OFF -DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DBUILD_opencv_apps:BOOL=OFF -DBUILD_opencv_contrib_world:BOOL=OFF -DBUILD_opencv_cuda:BOOL=OFF -DBUILD_opencv_cvv:BOOL=OFF -DBUILD_opencv_hdf:BOOL=OFF -DBUILD_opencv_java:BOOL=OFF -DBUILD_opencv_matlab:BOOL=OFF -DBUILD_opencv_python2:BOOL=OFF -DBUILD_opencv_python3:BOOL=OFF -DBUILD_opencv_sfm:BOOL=OFF -DBUILD_opencv_ts:BOOL=OFF -DBUILD_opencv_viz:BOOL=OFF -DBUILD_opencv_world:BOOL=OFF %devfolder%opencv
cmake --build .
cmake --build . --target install
copy /y "%devfolder%build\unix-install\opencv.pc" "%devfolder%build\install"
