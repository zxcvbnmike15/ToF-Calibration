function fig = plot_color_images(color_files)
% Time of Flight Calibration Toolbox
% Function: plot_color_images()
%
% SYNTAX:
% plot_color_images(color_files)
% fig = plot_color_images(color_files)
%
% DESCRIPTION:
%   This function plots all the color files found in the color_files
%   structure
%
%   plot_color_images(color_files) -
%   Plots the images on a single figure.
%
%   fig = plot_color_images(color_files) -
%   Plots the images on a single figure. Returns the figure handle.
%
% INPUTS:
%   color_files                     - Directory structure containing file
%                                       information on each color image
%
% OUTPUTS:
%   fig                             - Output figure handle.
%
% FUTURE CHANGES:
%   I don't currently care about color cameras. So I assume 1 color cam.
%   There is no effot made to handle this.
%
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020
% Adapted from : plot_all_images tof_calibraion 2006

%% Setup Figure

% Determine number grid shape
num_img = numel(color_files);
fig_rows = floor(sqrt(num_img));
fig_cols = ceil(num_img/fig_rows);
num_tiles = fig_rows*fig_cols;

fig = figure();
haxes = tight_subplot(fig_rows,fig_cols,0.01,0,0);

%% Plot image thumbnails
% Functionality is currently limited to 1 color cam, so ditching the old
% for loop that would go over each cam

for ii = 1:num_tiles
    axes(haxes(ii));
    
    try
        filename = fullfile(color_files(ii).folder, color_files(ii).name);
        imshow(filename);
        text(15,15,num2str(ii),...
            'Color',[1,1,0],'FontWeight','bold');
    catch
        imshow(1);
    end
    
end

