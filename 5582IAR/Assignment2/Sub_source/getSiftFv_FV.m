% function [encoding]=getSiftFv(sift, A, gmm)
function [fv]=getSiftFv_FV(sift2, A, gmm)
%% Hongkun Jin
kd = 16; kd_indx = 1; nc = 32;
% fisher vec
n=1;
dsift_fv = zeros(1, kd*nc);
fv = vl_fisher(A(1:kd, :) * double(sift2), gmm(kd_indx, 2).m, gmm(kd_indx, 2).cov,  gmm(kd_indx, 2).p);
dsift_fv(1, :) = fv(1:kd * nc)';
fprintf('\n %d sift ', 1)

end

