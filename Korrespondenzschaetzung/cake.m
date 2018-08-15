function Cake=cake(min_dist)
[X,Y]=meshgrid(-min_dist:min_dist,[-min_dist:-1,0:min_dist]);
Cake=sqrt(X.^2+Y.^2)>min_dist;
end