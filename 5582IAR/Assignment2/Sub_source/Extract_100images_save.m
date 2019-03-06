%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load Tiny ImageNet data set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
% get labels
cat_list = dir('tiny_data/tiny-imagenet-200/train');
n_cat = 10; n_img = 10; n = 0; 
% load images
for k = 1:n_cat
    ids(k, :) = cat_list(k + 2).name;
    flist = dir(sprintf('tiny_data/tiny-imagenet-200/train/%s/images/*.JPEG', ids(k,:)));
    for j=1:n_img
        n=n+1; ims{n} = imread(sprintf('tiny_data/tiny-imagenet-200/train/%s/images/%s', ids(k,:), flist(j+2).name));
    end
end
% associated labels
ids = kron([1:n_cat], ones(1,n_img))';

save data_100_test.mat;
% save('ids_1000.mat');