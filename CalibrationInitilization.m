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
% NOTE: Regular Expressions
%   The regular expressions are very useful for identifying file naming
%   formats. The issue is you can spend an eternity customizing the
%   expression to match some wakey naming convention. So in the interest of
%   time, use a simple naming convension. Seriously, the default is a
%   pretty good one. I'm basically asking you to not have a date/time in
%   the file name. Make the only number the photonumber
% OUTPUTS:
%   cal_info                - Structure containing calibration settings and
%                               info.
%
% Author: Michael Smith
% Center for Coastal and Ocean Mapping
% University of New Hampshire
% Copyright 2020

%% Stadard Setup
fprintf(1,'Initilizing Calibration parameters and settings.\n');

% Calibration Options
cal_info.options.display = 'iter'; %No info
cal_info.options.correct_depth = true; %use depth correction
cal_info.options.depth_in_calib = true;%use depth measurements in calibration
cal_info.options.color_present = false; %at least one color camera is present
cal_info.options.max_iter = 30;
cal_info.options.use_fixed_ini = true; %use fixed initialization for initial intrinsic parameter estimation
cal_info.options.is_validation = false;

% Calibration Image Formats
cal_info.formats.ColorFiles = 'ImRGB\d*\.png';
cal_info.formats.DepthFiles = 'ImDepthOrig\d*\.png';
cal_info.formats.ConfidenceFiles = 'ImDepthConf\d*\.png';

% Files
cal_info.files.number_of_files = 0;
cal_info.files.depth = [];
cal_info.files.confidence = [];
cal_info.files.color = [];

% Calibration info
cal_info.files_added = false;
cal_info.dataset_path = [];

% Depth Calibration Parameters
cal_info.depth.depth_plane_poly = [];
cal_info.depth.depth_plane_mask = [];
cal_info.depth.depth_plane_points = [];
cal_info.depth.depth_plane_disparity = [];
cal_info.depth.max_depth_sample_count = 10000;

% Confidence Calibration Parameters
cal_info.confidence.conf_grid_x = [];
cal_info.confidence.conf_grid_p = [];

% Image Parameters....
cal_info.image.dx = [];
cal_info.image.corner_count_x = [];
cal_info.image.corner_count_y = [];

% Color Parameters
cal_info.color.rgb_grid_p = [];
cal_info.color.rgb_grid_x = [];

% Currently Unknown Parameters
cal_info.depth_corner_p =[];
cal_info.depth_corner_x = [];

% Initial Calibration Parameters
cal_info.calib0.rK = {};               %Color camera intrinsics matrix
cal_info.calib0.rkc = {};              %Color camera distortion coefficients
cal_info.calib0.rR = {};               %Rotation matrix depth camera to color camera (first is always identity)
cal_info.calib0.rt = {};               %Translation vector depth camera to color camera (first is always zero)
cal_info.calib0.Rext = [];             %checherboard plane rotation relative to color
cal_info.calib0.text = [];             %checherboard plane translation relative to color
cal_info.calib0.color_error_var = [];
cal_info.calib0.conf_error_var = [];
cal_info.calib0.cK = [];               %ToF intrinsics matrix
cal_info.calib0.ckc = [];              %ToF distortion coefficients
cal_info.calib0.cRext = [];            %checherboard plane rotation relative to ToF
cal_info.calib0.ctext = [];            %checherboard plane translation relative to ToF
cal_info.calib0.cR = [];               %1st color camera rotation relative to ToF
cal_info.calib0.ct = [];               %1st color camera translation relative to ToF
%  cal_info.calib0.inputs = [];        %X coordinates in regression
%  cal_info.calib0.res = [];           %Y responce in regression
cal_info.calib0.h = 20;                %kernel bandwidth
cal_info.calib0.coords = [1 2];        %coordinates from X actually used in regression

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
            if isnumeric(val_in) && val_in>0
                cal_info.options.max_iter = floor(val_in);
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
fprintf(1,'Calibration Initilization complete.\n');
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
fprintf(1,'\n\nGood Job! I really appreciate the effort there. Keep at it!\n\n');
fprintf(1,'+++++ Calibration Image Formats +++++\n');
fprintf(1,'The program will search a directory for calibration images.\n');
fprintf(1,'The image pertaining to a group must all have the same naming convention and be in the same folder.\n');
fprintf(1,'You can input custom formats using Regular Expression formatting.\n');
fprintf(1,'Do not get too wild with image names. Currently, the program only searches ');
fprintf(1,'for the incrementing number in the file name. It is strongly suggested ');
fprintf(1,'the images followe the default formats. Adding smarter file reading functionality is hard');
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
