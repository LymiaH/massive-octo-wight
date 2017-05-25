if ~exist('SETUP_DONE','var')
    if (is_octave)
        install_mexopencv_octave;
    else
        install_mexopencv_matlab;
    end
    addpath(fullfile(path_root,'PAScode'))
    SETUP_DONE = true;
end
