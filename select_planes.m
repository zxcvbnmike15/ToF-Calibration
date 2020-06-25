function depth_params = select_planes(depth_files, depth_params)
% Time of Flight Calibration Toolbox
% Function: select_planes()
%
% SYNTAX:
%
% INPUT:
%   depth_files
%
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020
% Adapted from do_select_planes() ToF Calibration Toolbox 2006
%% Setup
% File info
num_files = numel(depth_files);
dpth_names = {depth_files(:).name};

% depth parameter info
depth_plane_poly = depth_params.depth_plane_poly;
depth_plane_mask = depth_params.depth_plane_mask;
% Get image size
filename = fullfile(depth_files(1).folder,depth_files(1).name);
im_info = imfinfo(filename);
width = im_info.Width;
height = im_info.Height;

fprintf('-------------------\n');
fprintf('Selecting planes\n');
fprintf('-------------------\n');

%Select images
if(isempty(depth_plane_poly))
    depth_plane_poly = cell(1,num_files);
    depth_plane_mask = cell(1,num_files);
    fidx = 1:num_files;
else
    %Check for too small or too big array
    if(length(depth_plane_poly) < num_files)
        depth_plane_poly{num_files} = [];
        depth_plane_mask{num_files} = [];
    elseif(length(depth_plane_poly) > num_files)
        depth_plane_poly = depth_plane_poly(1:num_files);
        depth_plane_mask = depth_plane_mask(1:num_files);
    end
    
    %Select only missing planes
    missing = cellfun(@(x) isempty(x),depth_plane_poly) & ~cellfun(@(x) isempty(x),dpth_names);
    if(all(missing))
        default = 1:num_files;
        fidx = input('Select images to process ([]=all): ');
    else
        default = find(missing);
        fidx = input(['Select images to process ([]=[' num2str(default) ']): ']);
    end
    if(isempty(fidx))
        fidx = default;
    end
end

%Get plane polygons for all images
[uu,vv] = meshgrid(0:width-1,0:height-1);
for ii=fidx
    filename = fullfile(depth_files(ii).folder,depth_files(ii).name);
    
    fprintf('#%d - %s\n',ii,depth_files(ii).name);
    
    imd = read_disparity(filename,0);
    
    depth_plane_poly{ii} = select_plane_polygon(imd);
    %Extract mask
    if(isempty(depth_plane_poly{ii}))
        depth_plane_mask{ii} = false(size(imd));
    else
        depth_plane_mask{ii} = inpolygon(uu,vv,depth_plane_poly{ii}(1,:),depth_plane_poly{ii}(2,:));
    end
end

%% Place results into structure
depth_params.depth_plane_poly = depth_plane_poly;
depth_params.depth_plane_mask = depth_plane_mask;

fprintf('Done\n');