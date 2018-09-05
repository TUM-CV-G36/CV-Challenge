function [epipole1,epipole2] = epipole_aus_F(F)
% find epipole pairs out of fundamentalmatrix F

%% F*e_1 = 0 ;  (F^T)*e_2 = 0
[U_F,~,V_F] = svd(F);
epipole1 = V_F(:,3);   % e1 ~ v3
epipole2 = U_F(:,3);  % e2 ~ u3
%%
epipole1 = epipole1/epipole1(3);   % e1 = (ex1;ey1;1)
epipole2 = epipole2/epipole2(3);  % e2 = (ex2;ey2;1)
end