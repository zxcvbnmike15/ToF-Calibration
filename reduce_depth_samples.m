function [points, disparity]=reduce_depth_samples(points_in, disparity_in, max_count)
%reduce_depth_point_count(max_count)
% Reduces the total ammount of points in depth_plane_points and 
% depth_plane_disparity to make the minimization possible with limited
% memory.
%
% Kinect calibration toolbox by DHC
if(isempty(max_count) || max_count == 0)
  error('reduce_depth_samples:max_count','Invalid max_count.');
end

if(iscell(points_in))
  array_output = false;
else
  array_output = true;
  points_in = {points_in};
  disparity_in = {disparity_in};
end

points = points_in;
disparity = disparity_in;

%Reduce total count
initial_count = sum(cellfun(@(x) size(x,2),points));
total_count = sum(initial_count);
% while(true)
%   counts = cellfun(@(x) size(x,2),points);
%   total_count = sum(counts);
% 
%   if(total_count < max_count)
%     break;
%   end
% 
%   [~,max_i] = max(counts);
% 
%   points{max_i} = points{max_i}(:,1:2:end);
%   disparity{max_i} = disparity{max_i}(:,1:2:end);
% end
select = cellfun(@(x)randperm(length(x),floor(length(x)*max_count/total_count)),points,'UniformOutput',false);
points = cellfun(@(x,y) x(:,y), points,select,'UniformOutput',false);
disparity = cellfun(@(x,y) x(:,y), disparity,select,'UniformOutput',false);

% fprintf('done\n');
if(array_output)
  points = points{1};
  disparity = disparity{1};
end