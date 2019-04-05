% input:
%   -d0: n0 x 1 distances from matching pairs
%   -d1: n1 x 1 distances from non-matching pairs
%   -npt: n plot point
%function [tp, fp, tn, fn]=getPrecisionRecall(d0, d1, npt)
function [tp, fp, tn, fn]=getPrecisionRecall(d0, d1, npt)
dbg = 0;
if dbg
    load ../data/d0-d1-grasf-kd32-md16.mat;  
    npt = 32;
end

d_min = min(min(d0), min(d1));
d_max = max(max(d0), max(d1));

delta = (d_max - d_min) / npt;

for k=1:npt
    thres = d_min + (k-1)*delta;
    tp(k) = length(find(d0<=thres));
    fp(k) = length(find(d1<=thres));
    tn(k) = length(find(d1>thres));
    fn(k) = length(find(d0>thres));   
end

if dbg
    figure(21); grid on; hold on;
    plotHist(d0, 40); plotHist(d1, 40); 
     
    figure(22); grid on; hold on;
    plot(fp./(tn+fp), tp./(tp+fn), '.-r', 'DisplayName', 'tpr-fpr');
    plot(tp./(tp+fn), tp./(tp+fp), '.-k', 'DisplayName', 'precision-recall');   
    legend();
end

return;

