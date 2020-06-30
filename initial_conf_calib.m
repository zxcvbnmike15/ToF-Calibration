function conf_error_var = initial_conf_calib(calib0,conf_params,color_files, use_fixed_init)

conf_grid_p = conf_params.conf_grid_p;
conf_grid_x = conf_params.conf_grid_x;

cK = calib0.cK;
%% Setup
% Confidence Params


%% Confidence Camera Calibration
% Select the confidence corners
if(isempty(conf_grid_p))
    do_select_conf_corners();
end

if(~isempty(cK))
    conf_error_var = 0;
    return
end

fprintf('-------------------\n');
fprintf('Initial Depth confidence camera calibration\n');
fprintf('-------------------\n');

% Get the image size
file_name = fullfile(color_files.folder(1), color_files(1).name);
im_info = imfinfo(file_name);
width = im_info.Width;
height = im_info.Height;

kc0 = zeros(1,5);
[cK,ckc,cRext,ctext,conf_error_var]  = do_initial_calib(conf_grid_p,conf_grid_x,[im_height,im_width],kc0,use_fixed_init);
cR = eye(3,3);
ct = zeros(3,1);

%% Store Results of initial calibration and print to command window
% store results
calib0.cK = cK;
calib0.ckc = ckc;
calib0.cRext = cRext;
calib0.ctext = ctext;
calib0.cR = cR;
calib0.ct = ct;

fprintf('\nInitial calibration for depth camera\n');
print_calib_conf(calib0);
  
  %Reproject

error_rel=[];
indices = find(~cellfun(@(x) isempty(x),conf_grid_p));

for ii=1:length(indices)
    X = conf_grid_x{indices(ii)};

    R = cR'*cRext{indices(ii)};
    t = cR'*(ctext{indices(ii)} - ct);
    
    p_rel = project_points_k(X,cK,ckc,R,t);
    errori = p_rel-conf_grid_p{indices(ii)};

    error_rel = [error_rel; errori(:)];
    
end
fprintf('Reprojection error mean: %f\n',mean(error_rel));
fprintf('Reprojection error std. dev.: %f\n',std(error_rel));