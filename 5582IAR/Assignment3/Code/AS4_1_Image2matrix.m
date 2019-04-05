clear
% get labels
n_img = 10; 
% load images
all_image = dir(sprintf('s10_20x20/s7/*.png'));
ims_new10 = [];
for j=1:n_img
    
    im_read = imread(sprintf('s10_20x20/s7/%s', all_image(j).name));
    
    gray_im = rgb2gray(im_read);
    im_400  = double(reshape(gray_im, [20*20], 1));
    im_400_scale = (im_400' / 255);
    
    ims_new10 = [ims_new10; im_400_scale];
end

% associated labels
ids = kron(1, ones(1,n_img))';
ids_new10 = ids * 418;

save data_new10.mat ims_new10 ids_new10;
% save('ids_1000.mat');