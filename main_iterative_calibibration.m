%% Clear workspace to prevent issues with global variables
clear global; clear function; clear all;
clc;
close all;

%% Add the Gaussian package to the past
addpath(genpath('.'));
%% Establish Calibiration Options
cal_info = CalibrationInitilization('color_present',false,'max_iterations',3);


%% Add Camera Files

% Add the dataset path
dataset_path = fullfile('C:\Users\zxcvb\Documents\MATLAB\Yuri\data');
cal_info.dataset_path = dataset_path;

% Find Images:
if cal_info.files_added == false
    cal_info = find_images(cal_info);
end

% Show Color Image thumbnails
if cal_info.options.color_present == 1
    plot_color_images(cal_info.files.color);
end

% Show Depth Image Thumbnails
plot_depth_images(cal_info.files.depth, cal_info.options);

% Show Confidence Image Thumbnails
plot_confidence_images(cal_info.files.confidence);

% Select poses to use
cal_info = select_poses(cal_info,[1]);

%% Iterative calibration
%% Process Depth Regions
cal_info = process_depth_regions(cal_info);

%% Run intial Calibration
%save all markups
cal_info = initial_calib_intel(cal_info);

fprintf('Initial Calibration - done\n');
fprintf('Saving the variables \n');
init_cal = fullfile(cal_info.dataset_path,'markup.mat');
save(init_cal,'cal_info');

%% Start Iterative Calibration
%c = calib0;
errors = [];
iter = 0;
calib = cal_info.calib0;
depth_plane_points = cal_info.depth.depth_plane_points;
depth_plane_disparity = cal_info.depth.depth_plane_disparity;
conf_grid_x = cal_info.confidence.conf_grid_x;
conf_grid_p = cal_info.confidence.conf_grid_p;
options = cal_info.options;
rgb_grid_p = cal_info.color.rgb_grid_p;

if cal_info.options.color_present
    [cost,comp] = calibrate_intel_cost(calib,depth_plane_points,depth_plane_disparity,conf_grid_x,conf_grid_p,options,rgb_grid_p{1});
    if(cal_info.options.depth_in_calib)
        calib.sigma_dplane = std(cost(comp=='P'))*sqrt(sum(comp=='P'))/1; %underweight depth points
    else
        calib.sigma_dplane = 1;
    end
    calib.sigma_dcorners = std(cost(comp=='C'))*sqrt(sum(comp=='C'))/10;
    calib.sigma_rgb = std(cost(comp=='R'))*sqrt(sum(comp=='R'))/10;
else
    [cost,comp] = calibrate_intel_cost(calib,depth_plane_points,depth_plane_disparity,conf_grid_x,conf_grid_p,options);
    calib.sigma_dplane = std(cost(comp=='P'))*sqrt(sum(comp=='P'))/10;
    calib.sigma_dcorners = std(cost(comp=='C'))*sqrt(sum(comp=='C'))/10;
    calib.sigma_rgb = 1;
end

errors = [errors cost];

errors(comp=='P',:) = errors(comp=='P',:)/calib.sigma_dplane;
errors(comp=='C',:) = errors(comp=='C',:)/calib.sigma_dcorners;
errors(comp=='R',:) = errors(comp=='R',:)/calib.sigma_rgb;

c = calibrate(cal_info,calib);

%eval = do_eval(c,options);

%[cost,comp] = calibrate_intel_cost(c,depth_plane_points,depth_plane_disparity,conf_grid_x,conf_grid_p,options,rgb_grid_p{1});

%errors = [errors cost];
%corr = [];
%corr_points = 500:10:2000;

if cal_info.options.depth_in_calib && cal_info.options.correct_depth
    
    calib = fit_depth_correction(c,depth_plane_disparity,depth_plane_points);
    %corr = [corr; gaussian_kern_reg(corr_points,calib.inputs,calib.res, calib.h)];
    
    %eval = do_eval(calib,options,eval);
    
    %[cost,comp] = calibrate_intel_cost(calib,depth_plane_points,depth_plane_disparity,conf_grid_x,conf_grid_p,options,rgb_grid_p{1});
    %errors = [errors cost];
    
    
    while(iter < options.max_iter-1)
        
        
        c = calibrate(cal_info,calib);
        
        %eval = do_eval(c,options,eval);
        
        %[cost,comp] = calibrate_intel_cost(c,depth_plane_points,depth_plane_disparity,conf_grid_x,conf_grid_p,options,rgb_grid_p{1});
        %errors = [errors cost];
        
        calib = fit_depth_correction(c,depth_plane_disparity,depth_plane_points);
    
        %corr = [corr; gaussian_kern_reg(corr_points,calib.inputs,calib.res, calib.h)];
        
        %eval = do_eval(calib,options,eval);
        
        if(options.color_present)
            cost = calibrate_intel_cost(calib,depth_plane_points,depth_plane_disparity,conf_grid_x,conf_grid_p,options,rgb_grid_p{1});
        else
            [cost,comp] = calibrate_intel_cost(calib,depth_plane_points,depth_plane_disparity,conf_grid_x,conf_grid_p,options);
        end
        
        %if(options.eval)
        errors = [errors cost];
        %end
        
        iter = iter +1
    end
    
else
    calib = c;
end



