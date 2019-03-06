function [hog] = gethogDist(h1, h2)

h1 = getImHog(h1);
h2 = getImHog(h2);

[n1, m1, k]=size(h1); 
[n2, m2, k]=size(h2); 

x1 = reshape(h1, n1*m1, k); 
x2 = reshape(h2, n2*m2, k); 
dist = [];
for i = 1:4
    cell1 = x1{i}; cell2 = x2{i};
    [n, m, d]=size(cell1); 
    
    cell_r1 =  reshape(cell1, n*m, d);
    cell_r2 =  reshape(cell2, n*m, d);
    
    d1 = mean(min(pdist2(cell_r1, cell_r2))); 
    d2 = mean(min(pdist2(cell_r2, cell_r1))); 

    dist = [dist; min(d1, d2)];
end
hog = mean(dist);
hog1 =min(dist);
end

