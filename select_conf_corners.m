function conf_params = select_conf_corners(conf_params, conf_files, image_params)

%% Setup
persistent grid_p grid_x

corner_count_x = image_params.corner_count_x;
corner_count_y = image_params.corner_count_y;
dx = image_params.dx;


 %% Select the confidence image corners
fprintf('-------------------\n');
fprintf('Selecting conf corners\n');
fprintf('-------------------\n');

%  if(~exist('use_automatic','var'))
%        use_automatic = input('Use automatic corner detector? ([]=true, other=false)? ','s');
%        if(isempty(use_automatic))
%            use_automatic = true;
%        else
use_automatic = true;
%        end
%  end

if(isempty(corner_count_x))
    corner_count_x = input('Inner corner count in X direction: ');
    corner_count_y = input('Inner corner count in Y direction: ');
end

default = 26;
if(isempty(dx))
    dx = input(['Square size ([]=' num2str(default) 'mm): ']);
end
if(isempty(dx))
    dx = default;
end

[grid_x, grid_p] = select_corners_from_images(conf_files, grid_x, grid_p,...
    use_automatic,dx,corner_count_x, corner_count_y);

conf_grid_p = grid_p;
conf_grid_x = grid_x;

%% Pack it up
conf_params.conf_grid_x = conf_grid_x;
conf_params.conf_grid_p = conf_grid_p;
image_params.corner_count_y = corner_count_y;
image_params.corner_count_x = corner_count_x;
image_params.dx = dx;
grid_p = {};
grid_x = {};