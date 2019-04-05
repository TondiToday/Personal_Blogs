clear

load('faces_ids_new_train_test.mat');

faces = train_faces;
ids = train_label;
% % train_faces train_label test_faces test_label

%% AS4 - 2 PCA
[A0, eigv] = getEigenfacemodel(faces);

%% AS4 - 3 LDA

[A1] = getFisherfacemodel(faces, A0, ids);

%% AS4 - 4 LPP

[A2, S] = getLaplacianfacemodel(faces, A0, ids);

%% AS4 - 5 mAP

q = 20;
eigen_d0 = [32, 64];
for i = 1:2
    kd = eigen_d0(i);
    eigen=faces*A0(:,1:kd); 
    test_eigen=test_faces*A0(:,1:kd);
    dist=pdist2(test_eigen, eigen);
    [mAP(i,:), prec(i,:), recall(i,:)] = getQueryMAP(q, dist, test_label, train_label);
end

fisher_d1 = [8, 16, 24];

for i = 1:3
    kd =fisher_d1(i);
    eigen=faces*A0(:,1:kd); 
    test_eigen=test_faces*A0(:,1:kd);
    [A1, ~]=getLDA(faces*A0(:,1:kd), ids);
    fisher=eigen*A1; 
    test_fisher=test_eigen*A1;
    fisher_dist=pdist2(test_fisher, fisher);
    [mAP(i+2, :), prec(i+2, :), recall(i+2, :)] = getQueryMAP(q, fisher_dist, test_label, train_label);
end

lpp_d2 = [8, 16, 24];
for i = 1:3
    kd =lpp_d2(i);
    
    eigenface = faces*A0(:,1:kd); 
    eigen_dist = pdist2(eigenface, eigenface);
    mdist = mean(eigen_dist(:)); 
    h = -log(50)/mdist; 
    S1 = exp(-h*eigen_dist); 
    id_dist = pdist2(train_label, train_label);
    S2=S1; S2(find(id_dist~=0)) = 0;
    lpp_opt.PCARatio = 1; 
    [A2, ~]=LPP(S2, lpp_opt, eigenface); 
    
    lpp=faces*A0(:,1:kd)*A2; 
    test_lpp=test_faces*A0(:,1:kd)*A2;
    lpp_dist=pdist2(test_lpp, lpp);
    [mAP(i+5, :), prec(i+5, :), recall(i+5, :)] = getQueryMAP(q, lpp_dist, test_label, train_label);
end


figure(51)
color = ["b", "w", "g", "c", "m", "b", "k", "r"];
for k = 1:8
    plot(recall(k,:), prec(k,:), color(k), 'LineWidth',2); hold on;
end
legendName = ["eigen 32, mAP=", "eigen 64, mAP=", "fisher 8, mAP=", "fisher 16, mAP=", "fisher 24, mAP=", "lpp 8, mAP=", "lpp 16, mAP=", "lpp 24, mAP="];

str=[];
for i = 1:8
%     str = {strcat(legendName(i) , mAP(i))};  % at the end of first loop, z being loop output
    str = [str, legendName(i) + mAP(i)]; % after 2nd loop
end
xlabel = "Recall";
ylabel = "Precision";
legend(str{:})
title(sprintf('Precision and Recall, Q = 20'))


















