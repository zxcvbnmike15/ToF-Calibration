function initial_calib_intel(cal_info)

%% Setup
conf_params = cal_info.confidence;
calib0 = cal_info.calib0;
color_files = cal_info.files.color;
options = cal_info.options;

%% do corner-based calibration
initial_conf_calib(conf_params, color_files, options.use_fixed_ini);

if(options.color_present)
    do_initial_rgb_calib();
    %relative transformation initialization
    [calib0.cR,calib0.ct]=estimate_relative(calib0);
end