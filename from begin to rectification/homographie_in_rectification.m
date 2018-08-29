function [H] = homographie_in_rectification(a1,b1,K)
% compute the homographie-matrix in the steps of rectification

%%
theta1 = acos(a1'*b1/(norm(a1)*norm(b1)));
rot_axis1 = cross(a1,b1)/(norm(a1)*norm(b1));
R1 = eye(3) + sin(theta1) * Dach(rot_axis1) + (1-cos(theta1)) * (Dach(rot_axis1))^2;
H = K * R1 * inv(K);
end