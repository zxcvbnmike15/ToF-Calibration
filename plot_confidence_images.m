function plot_confidence_images(confidence_files)
% Time of Flight Calibration Toolbox
% Function: plot_confidence_images()
%
% SYNTAX:
% plot_confidence_images(confidence_files)
% fig = plot_confidence_images(confidence_files)
%
% DESCRIPTION:
%   This function plots all the confidence files found in the color_files
%   structure
%
%   plot_confidence_images(confidence_files) -
%   Plots the images on a single figure.
%
%   fig = plot_confidence_images(confidence_files) -
%   Plots the images on a single figure. Returns the figure handle.
%
% INPUTS:
%   confidence_files                     - Directory structure containing file
%                                       information on each confidence image
%
% OUTPUTS:
%   fig                             - Output figure handle.
%
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020
% Adapted from : plot_confidence tof_calibraion 2006

%% Setup Figure

% Determine number grid shape
num_img = numel(confidence_files);
fig_rows = floor(sqrt(num_img));
fig_cols = ceil(num_img/fig_rows);
num_tiles = fig_rows*fig_cols;

fig = figure();
haxes = tight_subplot(fig_rows,fig_cols,0.01,0,0);

%% Plot image thumbnails

for ii=1:num_tiles
    axes(haxes(ii));
    try
        filename = fullfile(confidence_files(ii).folder,confidence_files(ii).name);
        imd = double(imread(filename));
        imshow(imd/max(max(imd)));
        text(15,15,num2str(ii),...
            'Color',[1,1,0],'FontWeight','bold');
    catch
        imshow(0);
    end
end

