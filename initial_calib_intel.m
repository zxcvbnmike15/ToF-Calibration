function initial_calib_intel(calib0,options)

%% initialize calibration

%do corner-based calibration
do_initial_conf_calib(options.use_fixed_ini);

if(options.color_present)
    do_initial_rgb_calib();
    %relative transformation initialization
    [calib0.cR,calib0.ct]=estimate_relative(calib0);
end