function [pool_hist] = getPooledHSVHistogram(im, codebook, pooling)
% function test

bins = codebook;
im_mat = im{1, 1};
[r, c, ~] = size(im_mat);

pool_hist = [];
num = 0;
for i = 1:pooling(1)
    for j = 1: pooling(2)
%         pool_hist = [pool_hist; append()];
        num = num + 1;
        new_im = im_mat(((i - 1) * 32 + 1):i * 32, ((j - 1) * 32 + 1): j * 32, :);   % row then column
        r_pool = r / pooling(1);
        c_pool = c / pooling(2);
        
        hsv_im = rgb2hsv(new_im);
        x = reshape(hsv_im, [r_pool * c_pool, 3]);
        
        % data points and bin
        [n, ~] = size(x);
        [m, ~] = size(bins);
        % compute the n_data_points x n_bins distance matrix
        dist = pdist2(x, bins);
        [~, pixel_bin_offs] = min(dist');
        % Compute the distribution
        for k = 1:m
            h(k) = length(find(pixel_bin_offs == k));
        end
        h = h / sum(h);
        pool_hist = [pool_hist; h];
    end
end

end

