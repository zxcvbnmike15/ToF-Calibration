function process_depth_regions(cal_info)
% Time of Flight Calibration Toolbox
% Function: CalibrationInitilization()
%
% SYNTAX:
%

%% Get depth plane masks
if isempty(cal_info.depth.depth_plane_mask)
    cal_info.depth = select_planes(cal_info.files.depth, cal_info.depth);
end

%% Process depth samples
fprintf('Extracting disparity samples...\n');
[depth_plane_points,depth_plane_disparity] = get_depth_samples(cal_info.files.depth,cal_info.depth,cal_info.options);
initial_count = sum(cellfun(@(x) size(x,2),depth_plane_points));

[depth_plane_points,depth_plane_disparity] = remove_invalid(depth_plane_points,depth_plane_disparity,options);
clean_count = sum(cellfun(@(x) size(x,2),depth_plane_points));

[depth_plane_points,depth_plane_disparity] = reduce_depth_samples(depth_plane_points,depth_plane_disparity,max_depth_sample_count);
total_count = sum(cellfun(@(x) size(x,2),depth_plane_points));
fprintf('Initial disparity samples: %d\nClean disparity samples: %d\nUsing %d.\n',initial_count,clean_count,total_count);