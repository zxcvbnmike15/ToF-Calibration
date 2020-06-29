function [points,disparity]=get_depth_samples(depth_files,masks,options)
%
%


num_files = numel(depth_files);

points = cell(1,num_files);
disparity = cell(1,num_files);

for ii=1:num_files
    filename = fullfile(depth_files(ii).folder,depth_files(ii).name);
    imd = read_disparity(filename,options);
    
    [points{ii}(2,:),points{ii}(1,:)] = ind2sub(size(masks{ii}),find(masks{ii})');
    points{ii} = points{ii}-1; %Zero based
    disparity{ii} = imd(masks{ii})';
    
end