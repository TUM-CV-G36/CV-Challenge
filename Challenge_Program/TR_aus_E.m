function [T1, R1, T2, R2, U, V]=TR_aus_E(E)
    % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    % for reconstruction please use the function : rekonstruktion.m
    
    %%
    R_p_halfpi=[0 -1 0;1 0 0;0 0 1];
    R_n_halfpi=[0 1 0;-1 0 0;0 0 1];
    magic_mtrx=[1 0 0;0 1 0;0 0 -1];
    % Singulaerwerte Zerlegung
    [U,S,V]=svd(E);
    % Rotationsmatrizen
     if det(U)~=1
         U=U*magic_mtrx;
     end
     if det(V)~=1
         V=V*magic_mtrx;
     end
    % Paare 1
    T1_decke=U*R_p_halfpi*S*U';
    T1=[T1_decke(3,2),T1_decke(1,3),T1_decke(2,1)]';
    R1=U*R_p_halfpi'*V';
    % Paare 2
    T2_decke=U*R_n_halfpi*S*U';
    T2=[T2_decke(3,2),T2_decke(1,3),T2_decke(2,1)]';
    R2=U*R_n_halfpi'*V';
end 