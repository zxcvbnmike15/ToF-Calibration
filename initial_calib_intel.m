function cal_info = initial_calib_intel(cal_info)

%% Setup
conf_params = cal_info.confidence;
calib0 = cal_info.calib0;
conf_files = cal_info.files.confidence;
options = cal_info.options;

%% do corner-based calibration
[conf_error_var, calib0,conf_params] = initial_conf_calib(calib0,conf_params, conf_files, options.use_fixed_ini);

if(options.color_present)
    do_initial_rgb_calib();
    %relative transformation initialization
    [calib0.cR,calib0.ct]=estimate_relative(calib0);
end

%% Packup
cal_info.confidence = conf_params;
cal_info.calib0 = calib0;