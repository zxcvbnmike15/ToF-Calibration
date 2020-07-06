function cal_info = initial_calib_intel(cal_info)

%% Setup
conf_params = cal_info.confidence;
conf_files = cal_info.files.confidence;
color_params = cal_info.color;
color_files = cal_info.files.color;
image_params = cal_info.image;
calib0 = cal_info.calib0;

options = cal_info.options;

%% do corner-based calibration
[calib0,conf_params] = initial_conf_calib(calib0,conf_params,conf_files,image_params,options.use_fixed_ini);

if(options.color_present)
    calib0 = initial_rgb_calib(color_params,color_files,image_params,calib0);
    %relative transformation initialization
    [calib0.cR,calib0.ct]=estimate_relative(calib0);
end

%% Packup
cal_info.confidence = conf_params;
cal_info.calib0 = calib0;