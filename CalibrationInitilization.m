function cal_info = CalibrationInitilization(varargin)
% Time of Flight Calibration Toolbox
% Function: CalibrationInitilization()
%
% SYNTAX:
%   cal_info = CalibrationInitilization()
%   cal_info = CalibrationInitilization('setup')
%   cal_info = CalibrationInitilization(name,value,...)
%
% DESCRIPTION:
%   The CalibrationInitilization function act as a psuedo class constructor.
%   The function is used to initialize the calibration paramters,
%   setttings, and formats. 
%   
%   cal_info = CalibrationInitilization() - 
%   Return the default settings and formats.
%
%   cal_info = CalibrationInitilization('setup') - 
%   The user will be propted to input the settings and format in the
%   command window
%
%   cal_info = CalibrationInitilization(name,value) = 
%   Name value pairs are parsed and added to cal_info. Any parameters not
%   specifed will be set to default.
%
% NAME/VALUES:
%   display                 - Unknown Option. Suggest leaving as default.
%                             Character Array.
%   correct_depth           - Use depth correction. Logical value.
%   depth_in_cailb          - Use depth measurements in calibration. 
%                             Logical value.
%   color_present           - Indicates Presence of at least one color
%                             camera. Logical value.
%   max_itererations        - Maximum number ofiterations. Positive Integer
%   use_fixed_init          - Use Fixed Initilization for initial intrinsic
%                             parameter estimation. Logical value.
%   color_file_format       - Format of Color Image files. 
%                             Regular Expression. 
%   depth_file_format       - Format of Depth Image files.
%                             Regular Expression.
%   confidence_file_format  - Format of Confidence Image files.
%                             Regular Expressions.
%
% OUTPUTS:
%   cal_info                - Structure containing calibration settings and
%                               info.
%
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020 

%% Stadard Setup
% Calibration Options
cal_info.options.display = 'iter'; %No info
cal_info.options.correct_depth = true; %use depth correction
cal_info.options.depth_in_calib = true;%use depth measurements in calibration
cal_info.options.color_present = false; %at least one color camera is present
cal_info.options.max_iter = 30;
cal_info.options.use_fixed_ini = true; %use fixed initialization for initial intrinsic parameter estimation

% Calibration Image Formats
cal_info.formats.ColorFiles = 'ImRGB\d*\.png';
cal_info.formats.DepthFiles = 'ImDepthOrig\d*\.png';
cal_info.formats.ConfidenceFiles = 'ImDepthConf\d*\.png';

%% Parse Inputs
for ii = 1:2:length(varargin)
    name_in = varargin{ii};
    
    % Handle single input case
    if numel(varargin) == 1
        if strcmpi(name_in,'setup')
            %run the setup function
            cal_info = cal_ui(cal_info);
            break
        end
    end
    
    val_in = varargin{ii+1};
    switch lower(name_in)
        case 'display'
            if ~ischar(val_in)
                error('Invalid input type for "display". Must be character arrray');
            else
                cal_info.options.display = val_in;
            end
            
        case 'correct_depth'
            if ~islogical(val_in)
                if val_in == 1 || val_in == 0
                    cal_info.options.correct_depth = val_in;
                else
                    error('Invalid input type for "correct_depth". Must be logical value');
                end
            else
                cal_info.options.correct_depth = val_in;
            end
            
        case 'depth_in_calib'
            if ~islogical(val_in)
                if val_in == 1 || val_in == 0
                    cal_info.options.depth_in_calib = val_in;
                else
                    error('Invalid input type for "depth_in_calib". Must be logical value');
                end
            else
                cal_info.options.depth_in_calib = val_in;
            end
            
        case 'color_present'
            if ~islogical(val_in)
                if val_in == 1 || val_in == 0
                    cal_info.options.color_present = val_in;
                else
                    error('Invalid input type for "color_present". Must be logical value');
                end
            else
                cal_info.options.color_present = val_in;
            end
            
        case 'max_iterations'
            if isnumeric(val_in) && isinteger(val_in) && val_in>0
                cal_info.max_iter = val_in;
            else
                error('Invalid input for "max_iterations". Must be positive non-zero integer');
            end
            
        case 'use_fixed_init'
            if ~islogical(val_in)
                if val_in == 1 || val_in == 0
                    cal_info.options.use_fixed_ini = val_in;
                else
                    error('Invalid input type for "use_fixed_init". Must be logical value');
                end
            else
                cal_info.options.use_fixed_ini = val_in;
            end
            
        case 'color_file_format'
            if ischar(val_in)
                cal_info.formats.ColorFiles = val_in;
            else
                error('Invalid input type for "color_file_format". Must be regular expression of type character array.');
            end
            
        case 'depth_file_format'
            if ischar(val_in)
                cal_info.formats.DepthFiles = val_in;
            else
                error('Invalid input type for "depth_file_format". Must be regular expression of type character array.');
            end
            
        case 'confidence_file_format'
            if ischar(val_in)
                cal_info.formats.ConfidenceFiles = val_in;
            else
                error('Invalid input type for "confidence_file_format". Must be regular expression of type character array.');
            end
            
        otherwise
            continue
    end
end
end

function setup_out = cal_ui(setup_in)
% Calibration Initilization : cal_setup()
% Local Function
%
% Function is ran when user chooses interactive calibration setup.

setup_out = setup_in;

%% Print out options prompt
fprintf(1,'**** Running Interactive Calibration Initilization ****\n\n');
fprintf(1,'+++++ Calibration Options +++++\n');
fprintf(1,'The following options are available for modification.\n')
fprintf(1,'Provided is the expected input and the default setting.\n')
fprintf(1,'Pressing enter without entering any text will automatically select the default setting.\n\n')
fprintf(1,'display\t\t\t\tInput type: ''string''\t\t\tdefault: ''iter''\n');
fprintf(1,'correct_depth\t\tInput type: true/false\t\t\tdefault: true\n');
fprintf(1,'depth_in_calib\t\tInput type: true/false\t\t\tdefault: true\n');
fprintf(1,'color_present\t\tInput type: true/false\t\t\tdefault: false\n');
fprintf(1,'max_iterations\t\tInput type: integer>0\t\t\tdefault: 30\n');
fprintf(1,'use_fixed_init\t\tInput type: true/false\t\t\tdefault: true\n\n');
%% Calibration Options

% Display
prompt = sprintf('Calibration display option {string}: ');
val_in = [];
while ~ischar(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.options.display;
        break
    end
end
setup_out.options.display = val_in;

% Correct Depth
prompt = sprintf('Use depth correction {logical}: ');
val_in = [];
while ~islogical(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.options.correct_depth;
        break
    end
end
setup_out.options.correct_depth = val_in;

% Depth in Calibration
prompt = sprintf('Use depth in calibration {logical}: ');
val_in = [];
while ~islogical(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.options.depth_in_calib;
        break
    end
end
setup_out.options.depth_in_calib;

% Color Present
prompt = sprintf('Color present {logical}: ');
val_in = [];
while ~islogical(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.options.color_present;
        break
    end
end
setup_out.options.color_present = val_in;

% Max interations
prompt = sprintf('Maximum iterations option {integer}: ');
val_in = 'foobar';
while ~isnumeric(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.options.max_iter;
        break
    end
end
setup_out.options.max_iter = val_in;

% Use fixed initilization
prompt = sprintf('Use fixed initilization for initial intrinsic parameter estimation {logical}: ');
while ~islogical(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.options.use_fixed_ini;
        break
    end
end
setup_out.options.use_fixed_ini = val_in;

%% Calibration formats
fprintf(1,'\n\nGood Job! I really appreciate the effort there. Keep at it!\n');
fprintf(1,'+++++ Calibration Image Formats +++++\n');
fprintf(1,' The program will search a directory for calibration images.\n');
fprintf(1,'The images must all have the same naming convention and be in the same folder.\n');
fprintf(1,' You can input custom formats using Regular Expression formatting.\n');
fprintf(1,'The default formats are shown below:\n\n');
fprintf(1,'Color Files -\t\t\tImRGB\\d*\\.png\n');
fprintf(1,'Depth Files -\t\t\tImDepthOrig\\d*\\.png\n');
fprintf(1,'Confidence Files -\t\t\tImDepthConf\\d*\\.png\n\n');

% Color Files
prompt = sprintf('Color files format {string}: ');
val_in = [];
while ~ischar(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.formats.ColorFiles;
        break
    end
end
setup_out.formats.ColorFiles = val_in;

% Depth Files
prompt = sprintf('Depth files format {string}: ');
val_in = [];
while ~ischar(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.formats.DepthFiles;
        break
    end
end
setup_out.formats.DepthFiles = val_in;

% Confidence Files
prompt = sprintf('Confidence files format {string}: ');
val_in = [];
while ~ischar(val_in)
    val_in = input(prompt);
    if isempty(val_in)
        val_in = setup_in.formats.ConfidenceFiles;
        break
    end
end
setup_out.formats.ConfidenceFiles = val_in;

end
