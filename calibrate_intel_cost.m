function [cost, comp ] =calibrate_intel_cost(cal_info)
% cost=calibrate_intel_cost_depth(params,options,depth_plane_points,depth_plane_disparity)
% Cost for depth images, used by calibrate_intel_cost;
% Uses both depth and corner-based cost on confidence map
%
% Kinect calibration toolbox by DHC
%% Unpack
calib = cal_info.calib0;
depth_points = cal_info.depth.depth_plane_points;
depth_disparity = cal_info.depth.depth_plane_disparity;
conf_grid_x = cal_info.confidence.conf_grid_x;
conf_grid_p = cal_info.confidence.conf_grid_p;
options = cal_info.options;
rgb_grid_p = cal_info.color.rgb_grid_p;
[cost_depth, comp] = calibrate_intel_cost_depth(calib,depth_points,depth_disparity,conf_grid_x,conf_grid_p,options);

if(sum(isnan(cost_depth))>0)
    warning('NaN values in cost');
end

if (exist('rgb_grid_p','var'))
    cost_rgb = calibrate_intel_cost_color(calib, conf_grid_x, rgb_grid_p);
    
    comp = [comp; repmat('R',length(cost_rgb),1)];
    
    cost = [cost_depth; cost_rgb];
else
    cost = cost_depth;
end