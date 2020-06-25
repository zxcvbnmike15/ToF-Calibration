function cal_info = select_poses(cal_info, poses)
% Time of Flight Calibration Toolbox
% Function: select_poses()
%
% SYNTAX:
% cal_info = select_poses(cal_info)
% cal_info = select_poses(cal_info,poses)
%
% DESCRIPTION:
%   This fuction selects image poses for calibration.
%
%   cal_info = select_poses(cal_info) -
%   Interactive method. Selects poses based on user input.
%
%   cal_info = select_poses(cal_info, poses) -
%   Selects poses based on vector of pose numbers provided
%
% INPUTS:
%   cal_info                  - structure object containing the project
%                               information including directory structures
%                               of the calibration files.
%
%   poses                   - Vector of integers. Used to select poses for
%                             calibration. Must be of equal or less length
%                             to the number of files in cal_info.
%
% OUTPUT
%   file                    - Updated file list containing only files for
%                             calibration.
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020

%% Manage Inputs
num_files = cal_info.files.number_of_files;

% Check if poses was passed
if ~exist('poses','var')    % poses was not passed, query user
    start_index = input('Enter starting pose index: ');
    end_index = input('Enter ending pose index: ');
    poses = start_index:end_index;
end

% Check poses is valid
if ~isnumeric(poses) || length(poses)>num_files
    error('Must be a vector of numbers between 1 and number of files');
end


%% Truncate the files
cal_info.files.depth = cal_info.files.depth(poses);
cal_info.files.confidence = cal_info.files.confidence(poses);

if cal_info.options.color_present == 1
    cal_info.files.color = cal_info.files.color(poses);
end
