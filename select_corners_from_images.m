function [grid_x, grid_p] = select_corners_from_images(conf_files, grid_x,grid_p,...
    use_automatic,dx,corner_count_x, corner_count_y)

num_files = numel(conf_files);

if(~exist('use_automatic','var'))
    use_automatic = input('Use automatic corner detector? ([]=true, other=false)? ','s');
    if(isempty(use_automatic))
        use_automatic = true;
    else
        use_automatic = false;
    end
end

if(~exist('corner_count_x','var'))
    corner_count_x = input('Inner corner count in X direction: ');
    corner_count_y = input('Inner corner count in Y direction: ');
end

default = 26;
if(~exist('dx','var'))
    dx = input(['Square size ([]=' num2str(default) 'mm): ']);
end
if(isempty(dx))
    dx = default;
end

default = 6;
win_dx = input(['Corner finder window size ([]=' num2str(default) 'px): ']);
if(isempty(win_dx))
    win_dx = default;
end

%Select images
if isempty(grid_x)
    grid_p = cell(1,num_files);
    grid_x = cell(1,num_files);
    fidx = 1:num_files;
else
    %Check for too small or too big array
    if length(grid_x) ~= num_files
        grid_p{num_files} = [];
        grid_x{num_files} = [];
    elseif length(grid_x) > num_files
        grid_p = grid_p(1:num_files);
        grid_x = grid_x(1:num_files);
    end
    
    %Select only missing planes
    % I don't know if this is necessary but okay...
    nms = struct2cell(conf_files);
    nms = nms(1,:);
    missing = cellfun(@(x) isempty(x),grid_x) & ~cellfun(@(x) isempty(x),nms);
    if(all(missing))
        fidx = 1:num_files;
    else
        fidx = find(missing);
    end
end

figure(2);
clf;
figure(1);
clf;


%Extract grid for all images
for ii=fidx

    % THis can't happen
%     if(isempty(conf_files{i}))
%         continue
%     end
    
    fprintf('#%d - %s\n',ii,conf_files(ii).name);
    filename = fullfile(conf_files(ii).folder,conf_files(ii).name);
    im = imread(filename);
    
    [pp,xx] = do_select_corners(im,corner_count_x,corner_count_y,dx,use_automatic,win_dx,ii);
    
    grid_p{ii} = pp;
    grid_x{ii} = xx;
    
    %fprintf('Press ENTER to continue\n');
    %pause;
end

fprintf('Finished extracting corners for the selected images.\n');