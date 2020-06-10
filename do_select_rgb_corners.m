function do_select_rgb_corners()
%do_select_rgb_corners()
% UI function.
% Kinect calibration toolbox by DHC

global grid_p grid_x rfiles rgb_grid_p rgb_grid_x
global corner_count_x corner_count_y dx
fprintf('-------------------\n');
fprintf('Selecting rgb corners\n');
fprintf('-------------------\n');

ccount = length(rfiles);
if(isempty(rgb_grid_p))
    rgb_grid_p = cell(1,ccount);
    rgb_grid_x = cell(1,ccount);
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

for k=1:ccount
    fprintf('Camera %d\n',k);
    
    if(isempty(rgb_grid_p{k}))
        do_select_corners_from_images(rfiles{k}, use_automatic,dx,corner_count_x, corner_count_y);
        
        rgb_grid_p{k} = grid_p;
        rgb_grid_x{k} = grid_x;
        
        grid_p = {};
        grid_x = {};
        
        fprintf('Finished extracting corners for the selected images.\n');
    end
end
