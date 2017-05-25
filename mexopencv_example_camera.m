%From documentation at: https://github.com/kyamagu/mexopencv/wiki/Getting-Started
% Connect to a camera
camera = cv.VideoCapture();
pause(2);
for i = 1:50
    % Capture and show frame
    frame = camera.read();
    imshow(frame);
    pause(0.3);
end

