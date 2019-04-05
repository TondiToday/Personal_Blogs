clear
% get labels
n_img = 10; 
% load images
all_image = dir(sprintf('s10_20x20/s7/*.png'));

load('faces-ids-n6680-m417-20x20.mat');
for j=1:n_img
    
    im_read = imread(sprintf('s10_20x20/s7/%s', all_image(j).name));
    
    gray_im = rgb2gray(im_read);
    im_400  = double(reshape(gray_im, [20*20], 1));
    im_400_scale = (im_400' / 255);
    
    faces = [faces; im_400_scale];
    ids = [ids; 999];
end

faces_new = faces;
ids_new = ids;

save faces_ids_new_6690.mat faces_new ids_new;
% save('ids_1000.mat');