path_root = pwd;
%change this to where you have the libaries
path_dev = fullfile(fileparts(path_root),'dev');
cd(fullfile(path_dev,'mexopencv'));
path_mexopencv = fullfile(path_dev,'mexopencv');
addpath(path_mexopencv);
addpath(fullfile(path_mexopencv,'opencv_contrib'));
path_opencv = fullfile(path_dev,'build','install');
addpath(path_opencv);
mexopencv.make('opencv_path',path_opencv,'opencv_contrib',true);
cd(path_root);
