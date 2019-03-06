function [hog_cell] = getImHog(im)
pooling = [2, 2];

im_mat = im{1, 1};
[r, c, ~] = size(im_mat);
cellSize = 8;
hog_cell = {};
n = 0;

for i = 1:pooling(1)
    for j = 1: pooling(2)
        n = n + 1;
        r_pool = r / pooling(1);
        c_pool = c / pooling(2);
        new_im = im_mat(((i - 1) * r_pool + 1):i * r_pool, ((j - 1) * c_pool + 1): j * c_pool, :);   % row then column
        gray_im = rgb2gray(new_im);
        single_im = im2single(gray_im);
        hog = vl_hog(single_im, cellSize, 'verbose', 'variant', 'dalaltriggs');
        hog_cell{i, j} = hog;
    end
end
end

