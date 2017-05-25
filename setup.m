if ~exist('SETUP_DONE','var')
    if (is_octave)
        install_mexopencv_octave;
    else
        install_mexopencv_matlab;
    end
    addpath(fullfile(path_root,'PAScode'))
    path_images = fullfile(path_root, 'images');
    path_positives = fullfile(path_images, 'positives');
    path_negatives = fullfile(path_images, 'negatives');
    SETUP_DONE = true;
end
