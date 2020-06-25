function plot_depth_images(depth_files,options)
% Time of Flight Calibration Toolbox
% Function: plot_depth_images()
%
% SYNTAX:
% plot_depth_images(color_files)
% fig = plot_depth_images(color_files)
%
% DESCRIPTION:
%   This function plots all the depth files found in the depth_files
%   structure
%
%   plot_deoth_images(depth_files) -
%   Plots the images on a single figure.
%
%   fig = plot_depth_images(depth_files) -
%   Plots the images on a single figure. Returns the figure handle.
%
% INPUTS:
%   depth_files                     - Directory structure containing file
%                                       information on each color image
%
% OUTPUTS:
%   fig                             - Output figure handle.
%
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020
% Adapted from : plot_all_images tof_calibraion 2006

%% Setup Figure

% Determine number grid shape
num_img = numel(depth_files);
fig_rows = floor(sqrt(num_img));
fig_cols = ceil(num_img/fig_rows);
num_tiles = fig_rows*fig_cols;
fig = figure();
haxes = tight_subplot(fig_rows,fig_cols,0.01,0,0);

%% Plot image thumbnails
for ii = 1:num_tiles
    axes(haxes(ii));
    
    try
        
        filename = fullfile(depth_files(ii).folder, depth_files(ii).name);
        imd = read_disparity(filename,options);
        imshow(visualize_disparity(imd));
        text(15,15,num2str(ii),...
            'Color',[1,1,0],'FontWeight','bold');
    catch
        imshow(1);
    end
    
end
