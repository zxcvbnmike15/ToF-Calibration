function calib0 = initial_rgb_calib(color_params,color_files,calib0,...
    do_joint_calib,use_fixed_init)
%do_initial_rgb_calib()
% UI function
% Kinect calibration toolbox by DHC

%% Unpack
num_files = numel(color_files);
rgb_grid_p = color_params.rgb_grid_p;
rgb_grid_x = color_params.rgb_grid_x;
rK = calib0.rK;
rkc = calib0.rkc;
Rext = calib0.Rext;
text = calib0.text;
color_error_var = calib0.color_error_var;

%Check previous steps
%Check previous steps
if(isempty(rgb_grid_p))
    do_select_rgb_corners();
end

for kk=1:num_files
    if(isempty(rgb_grid_p{kk}))
        do_select_rgb_corners();
    end
end

if(~isempty(rK))
    return;
end

fprintf('-------------------\n');
fprintf('Initial RGB camera calibration\n');
fprintf('-------------------\n');

if (nargin < 1)
    do_joint_calib = false;
end

if(nargin < 2)
    use_fixed_init = false;
end

if(~isempty(rgb_grid_p))
    ccount = 1;%length(rgb_grid_p);
else
    ccount = 0;
end

%Rext = cell(1,ccount);
%text = cell(1,ccount);
kc0 = zeros(1,5);

%Independent camera calibration
for kk = 1:ccount
  fprintf('Color camera #%d\n',kk);
  filename = fullfile(color_files(kk).folder,color_files(kk).name);
  im = imread(filename);
  
  if(kk==1)
    [rK{kk},rkc{kk},Rext,text,color_error_var(kk)] = do_initial_calib(rgb_grid_p{kk},rgb_grid_x{kk},size(im),kc0,use_fixed_init);
    calib0.rR{kk} = eye(3);
    calib0.rt{1} = zeros(3,1);
  else
    [rK{kk},rkc{kk},Rext_o,text_o,color_error_var(kk)] = do_initial_calib(rgb_grid_p{kk},rgb_grid_x{kk},size(im),kc0,use_fixed_init);
    [rR{kk},rt{kk}] = do_initial_relative_transform(Rext,text,Rext_o,text_o);
  end

end

%% Repackage and print results
calib0.rK = rK;
calib0.rkc = rkc;
calib0.Rext = Rext;
calib0.text = text;
calib0.color_error_var = color_error_var;

%Print calibration results
for kk = 1:ccount
  fprintf('\nInitial calibration for camera %d:\n',kk);
  
  print_calib_color(kk,calib0);
  
  %Reproject
  error_abs=[];
  error_rel=[];
  for ii=1:num_files
    X = rgb_grid_x{kk}{ii};

%     p_abs = project_points_k(X,calib0.rK{k},calib0.rkc{k},Rext{k}{i},text{k}{i});
%     errori = p_abs-rgb_grid_p{k}{i};
%     errori = sum(errori.^2,1).^0.5;
%     error_abs = [error_abs, errori];

    R = calib0.rR{kk}'*calib0.Rext{ii};
    t = calib0.rR{kk}'*(calib0.text{ii} - calib0.rt{kk});
    p_rel = project_points_k(X,calib0.rK{kk},calib0.rkc{kk},R,t);
    errori = p_rel-rgb_grid_p{kk}{ii};
    
%     errori = sum(errori.^2,1).^0.5;
%     error_rel = [error_rel, errori];
    error_rel = [error_rel; errori(:)];
  end
  %fprintf('Mean reprojection error with absolute Rt: %f\n',mean(error_abs));
  fprintf('Reprojection error std. dev.: %f\n',std(error_rel));
end