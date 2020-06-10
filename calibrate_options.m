function options=calibrate_options()
% options=calibrate_kinect_options()
% Creates the options struct for calibrate_kinect().
% Set the different use_fixed_* fields to control the degrees of freedom in
% the minimization.
% 
% Kinect calibration toolbox by DHC
options.display = 'iter'; %No info
options.correct_depth = 1; %use depth correction
options.depth_in_calib = 1;%use depth measurements in calibration
options.color_present = 0; %at least one color camera is present
options.max_iter = 30;
options.use_fixed_ini = 1; %use fixed initialization for initial intrinsic parameter estimation
%options.read_image = @(im_path) <custom function that loads an image>;
%should [return image, invalid_value]
%options.eval = 3;