function [color_params,image_params] = select_rgb_corners(color_params,color_files,image_params)
%do_select_rgb_corners()
% UI function.
% Kinect calibration toolbox by DHC

persistent grid_p grid_x
corner_count_x = image_params.corner_count_x;
corner_count_y = image_params.corner_count_y;
rgb_grid_p = color_params.rgb_grid_p;
rgb_grid_x = color_params.rgb_grid_x;
dx = image_params.dx;


num_files = numel(color_files);

fprintf('-------------------\n');
fprintf('Selecting rgb corners\n');
fprintf('-------------------\n');

if(isempty(rgb_grid_p))
    rgb_grid_p = cell(1,num_files);
    rgb_grid_x = cell(1,num_files);
end

if(isempty(corner_count_x))
    corner_count_x = input(['Inner corner count in X direction: ']);
    corner_count_y = input(['Inner corner count in Y direction: ']);
end
%Select pattern dimensions
default = 26;
if(isempty(dx))
    dx = input(['Square size ([]=' num2str(default) 'mm): ']);
end
if(isempty(dx))
    dx = default;
end

%Use automatic corner detector?
%use_automatic = input(['Use automatic corner detector? ([]=true, other=false)? '],'s');
%if(isempty(use_automatic))
%  use_automatic = true;
%else
use_automatic = true;
%end

for k=1:num_files
    fprintf('Camera %d\n',k);
    
    if(isempty(rgb_grid_p{k}))
        [grid_x, grid_p] = select_corners_from_images(color_files, grid_x, grid_p,...
            use_automatic,dx,corner_count_x, corner_count_y);
        
        rgb_grid_p{k} = grid_p;
        rgb_grid_x{k} = grid_x;
        
        grid_p = {};
        grid_x = {};
        
        fprintf('Finished extracting corners for the selected images.\n');
    end
end
%% Pack it up
color_params.rgb_grid_x = rgb_grid_x;
color_params.rgb_grid_p = rgb_grid_p;
image_params.corner_count_y = corner_count_y;
image_params.corner_count_x = corner_count_x;
image_params.dx = dx;
grid_p = {};
grid_x = {};