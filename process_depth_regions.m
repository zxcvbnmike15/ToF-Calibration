function process_depth_regions(cal_info)
% Time of Flight Calibration Toolbox
% Function: CalibrationInitilization()
%
% SYNTAX:
%

%% Subset the data
depth_files = cal_info.files.depth;
options = cal_info.options;

depth_plane_mask = cal_info.depth.depth_plane_mask;
depth_plane_poly = cal_info.depth.depth_plane_poly;
depth_plane_points = cal_info.depth.depth_plane_points;
depth_plane_disparity = cal_info.depth.depth_plane_disparity;

%% Get depth plane masks
if isempty(depth_plane_mask)
    [depth_plane_poly, depth_plane_mask] = select_planes(depth_files, ...
        depth_plane_poly, depth_plane_mask);
end

%% Process depth samples
fprintf('Extracting disparity samples...\n');
[depth_plane_points,depth_plane_disparity] = get_depth_samples(depth_files,depth_plane_mask,options);
initial_count = sum(cellfun(@(x) size(x,2),depth_plane_points));

[depth_plane_points,depth_plane_disparity] = remove_invalid(depth_plane_points,depth_plane_disparity,options);
clean_count = sum(cellfun(@(x) size(x,2),depth_plane_points));

[depth_plane_points,depth_plane_disparity] = reduce_depth_samples(depth_plane_points,depth_plane_disparity,max_depth_sample_count);
total_count = sum(cellfun(@(x) size(x,2),depth_plane_points));
fprintf('Initial disparity samples: %d\nClean disparity samples: %d\nUsing %d.\n',initial_count,clean_count,total_count);


%% Place results in cal_info
 cal_info.depth.depth_plane_mask = depth_plane_mask;
 cal_info.depth.depth_plane_poly = depth_plane_poly;
 cal_info.depth.depth_plane_points = depth_plane_points;
 cal_info.depth.depth_plane_disparity = depth_plane_disparity;