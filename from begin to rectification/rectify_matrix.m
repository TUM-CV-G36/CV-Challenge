function [T_rec1,T_rec2] = rectify_matrix(T,R,K)
%  rectification of cam1 and cam2
%  input: Transfromationvector, Rotationmatrix, intrinsic Matrix
%  output: rectification transform-matrix T_rec1 and T_rec2

%% Perspective projection matrix
% R = R';
Po1 = K * [eye(3), zeros(3,1)];
Po2 = K * [R, T];
%% rectification matrix
% optical centers
c1 = [0,0,0]';
c2 = c1 + T;
% new x axis
v1 = c2 - c1;
v2 = cross(R(3,:)',v1);
v3 = cross(v1,v2);
% new extrinsic parameters
R_new = [v1'/norm(v1); v2'/norm(v2); v3'/norm(v3)];
% new projection matrices
Pn1 = K * [R_new, -R_new*c1];
Pn2 = K * [R_new, -R_new*c2];
% rectifying image transformation
T_rec1 = Pn1(1:3,1:3) * inv(Po1(1:3,1:3));
T_rec2 = Pn2(1:3,1:3) * inv(Po2(1:3,1:3));
end