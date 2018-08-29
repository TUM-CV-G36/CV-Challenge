function [KP1_Rec,KP2_Rec] = rectification(KP1,KP2,epipole1, epipole2,K)
% 3-step rectification

%% step1 rotate (ex,ey,1) to (ex,ey,0)
e1 = epipole1;
e2 = epipole2;
% for e1
e1_1 = [e1(1:2);0];
a1_1 = inv(K)*e1;
b1_1 = inv(K)*e1_1;
% for e2
e2_1 = [e2(1:2);0];
a2_1 = inv(K)*e2;
b2_1 = inv(K)*e2_1;
% homograpie matrix in step1
H1_1 = homographie_in_rectification(a1_1,b1_1,K);
H2_1 = homographie_in_rectification(a2_1,b2_1,K);

%% step2 rotate (ex,ey,0) to (1,0,0)
e1_2 = [1,0,0]';
e2_2 = [1,0,0]';

% homograpie matrix in step2
H1_2 = homographie_in_rectification(e1_1,e1_2,K);
H2_2 = homographie_in_rectification(e2_1,e2_2,K);

%% Rectification
KP1_hom = [KP1; ones(1,size(KP1,2))];
KP2_hom = [KP2;ones(1,size(KP2,2))];
KP1_Rec = H1_1 * H1_2 * KP1_hom;
KP2_Rec = H2_1 * H2_2 * KP2_hom;

end