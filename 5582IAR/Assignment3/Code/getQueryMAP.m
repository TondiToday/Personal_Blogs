function [mAP, prec, recall] = getQueryMAP(q, dist, test_label, train_label)

idx = [];
for k=length(test_label)
    [~, offs]=sort(dist(k, :));
    prc_true = [];
    true = zeros(1, q);
    for i = 1:q
        if train_label(offs(i)) == test_label(k)
            idx = [idx, i];
            true(i) = 1;
            prc_true = [prc_true; i];
        end
        prec(i) = sum(true) / i;
    end
    
    n=length(find(true(1:q)==1));
    for i = 1:q
        recall(i) = sum(true(1:i)) / n;
    end
end

sum_p = 0;
for i = 1:length(prc_true)
    sum_p = sum_p + prec(prc_true(i));
end
mAP = sum_p / length(prc_true);

end

