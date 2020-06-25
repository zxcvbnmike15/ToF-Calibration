function cal_info = find_images(cal_info, dataset_path)
% Time of Flight Calibration Toolbox
% Function: find_images()
%
% SYNTAX:
%   cal_info = find_images(cal_info)
%   cal_info = find_images(cal_info, dataset_path)
%
% DESCRIPTION:
%   find_images seaches the user provided data directory for images. Images
%   found will match the file formats described in cal_info.formats.
%
%   cal_info = find_images(cal_info)
%   Searches for images in the directory identified in cal_info.data_path.
%   If data_path is empty, user is prompted to select a directory.
%
%   cal_info = find_images(cal_info, dataset_path)
%   Searches for images in the directory identifed by dataset_path.
%
% INPUTS:
%   cal_info                - Calibration metadata structure used
%   dataset_path            - Path to directory containing images
%
% OUTPUTS:
%   cal_info               - Updated metadata structure with valid files
%
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020
fprintf(1,'\n**** Calibration Image Search ****\n');

%% Parse inputs
if ~exist('dataset_path','var')         % path was not passed in function call
    if isempty(cal_info.dataset_path)   % path is not set in cal_info
        dataset_path = uigetdir(pwd,'Select directory containing calibration images');
    else                                % path is set in cal_info
        dataset_path = cal_info.dataset_path;
    end
end

% Make platform independent path string
dpath = fullfile(dataset_path);

% Check the path exists
if ~exist(dpath,'dir')
    error('Path does not exist! Check for syntax errors');
end

%% Create directory structure
data_dir = dir(dpath);

% remove the windows '.' and '..'
if ispc
    data_dir = data_dir(3:end);
end

%% Search for depth files
fmt = cal_info.formats.DepthFiles;
[depth_files, depth_fnum] = find_files(data_dir,fmt);

%% Search for confidence files
fmt = cal_info.formats.ConfidenceFiles;
[conf_files, conf_fnum] = find_files(data_dir,fmt);

%% Search for Color files
if cal_info.options.color_present == 1
    fmt = cal_info.formats.ColorFiles;
    [color_files, color_fnum] = find_files(data_dir,fmt);
    
end

%% Remove entries that lack matching files.
% Remove indices missing between depth and confidence files
[~,ix_depth,ix_conf] = intersect(depth_fnum,conf_fnum);
depth_files = depth_files(ix_depth);
conf_files = conf_files(ix_conf);

% Remove indices missing between color and results from of above
if cal_info.options.color_present == 1
    [~,ix_depth,ix_color] = intersect(depth_fnum,color_fnum);
    depth_files = depth_files(ix_depth);
    conf_files = conf_files(ix_depth);
    color_files = color_files(ix_color);
end

%% Add to calibration info object
cal_info.files.depth = depth_files;
cal_info.files.confidence = conf_files;

if cal_info.options.color_present == 1
    cal_info.files.color = color_files;
end
num_files = numel(cal_info.files.depth);
cal_info.files_added = 1;
cal_info.files.number_of_files = num_files;
fprintf(1,'%d plane poses found.\n',num_files);

end



function [found_files, num_file] = find_files(data_dir,fmt)
inds = zeros(numel(data_dir),1);
num_file =[];
for ii = 1:numel(data_dir)
    fname = data_dir(ii).name;
    chk = regexp(fname,fmt);
    if chk == 1
        inds(ii) = 1;
        fn_num = regexp(fname,'\d*','match');
        num_file = [num_file; str2num(fn_num{1})];
    end
end
found_files = data_dir(logical(inds));
end
