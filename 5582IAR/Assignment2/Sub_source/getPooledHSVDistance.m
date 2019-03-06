function [dist] = getPooledHSVDistance(im1, im2)
% function test
load('kmeans_entry64_ran5.mat');
codebook = bins;
pooling = [2, 2];
h1 = getPooledHSVHistogram(im1, codebook, pooling);
h2 = getPooledHSVHistogram(im2, codebook, pooling);

% Hog distance
[n1, m1, k]=size(h1); 
[n2, m2, k]=size(h2); 

x1 = reshape(h1, n1*m1, k);  
x2 = reshape(h2, n2*m2, k);  

d1 = mean(min(pdist2(x1, x2))); 
d2 = mean(min(pdist2(x2, x1))); 

dist = min(d1, d2);

end

