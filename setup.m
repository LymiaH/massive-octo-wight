if ~exist('SETUP_DONE','var')
    if (is_octave)
        install_mexopencv_octave;
    else
        install_mexopencv_matlab;
        if exist(fullfile(path_root,'matconvnet-1.0-beta24')) == 0
            untar('http://www.vlfeat.org/matconvnet/download/matconvnet-1.0-beta24.tar.gz')
            cd matconvnet-1.0-beta24
            run matlab/vl_compilenn
        else
            cd matconvnet-1.0-beta24
        end
        run matlab/vl_setupnn
        cd(path_root)
    end
    addpath(fullfile(path_root,'PAScode'))
    path_images = fullfile(path_root, 'images');
    path_positives = fullfile(path_images, 'positives');
    path_negatives = fullfile(path_images, 'negatives');
    SETUP_DONE = true;
end
