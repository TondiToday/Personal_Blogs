clear

%loading faces, ids, of nx400 and nx1
load('faces_ids_new_6690.mat');

n=length(ids_new); 
uid = unique(ids_new); 
m = length(uid);

% query data index:
q_indx = zeros(1, m); 
for k=1:m 
      offs = find(ids_new==uid(k)); 
      q_indx(k) = offs(1);
end
train_indx = setdiff([1:n], q_indx); 

num_d = length(train_indx);

train_faces = [];
train_label = [];
for i = 1:num_d
    train_faces = [train_faces; faces_new(train_indx(i),:)];
    train_label = [train_label; ids_new(train_indx(i))];
end

test_faces = [];
test_label = [];
for j = 1:m
    test_faces = [test_faces; faces_new(q_indx(j),:)];
    test_label = [test_label; ids_new(q_indx(j))];
end

save faces_ids_new_train_test.mat train_faces train_label test_faces test_label;


