function [EF] = achtpunktalgorithmus(Korrespondenzen, K)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
    if nargin==1
       K=eye(3);
    end
    x1_strich=Korrespondenzen(1:2,:);
    x2_strich=Korrespondenzen(3:4,:);
    one=ones(1,size(x1_strich,2));
    % Homogenematrizen
    x1_strich_hom=[x1_strich;one];
    x2_strich_hom=[x2_strich;one];
    % kalibirierten
    x1_hom=zeros(3,size(x1_strich_hom,2));
    x2_hom=zeros(3,size(x1_strich_hom,2));
    for i=1:size(x1_strich_hom,2)
        x1_hom(:,i)=inv(K)*x1_strich_hom(:,i);
        x2_hom(:,i)=inv(K)*x2_strich_hom(:,i);
    end
    % Kroneckerprodukt: a=kron(x1,x2)
    A=zeros(0,size(x1_hom,2));
    for i=1:size(x1_hom,2)
        a=kron(x1_hom(:,i),x2_hom(:,i));
        a=a';
        A=[A;a];   
    end
    % Singulaerwertzerlegung
    [U,S,V]=svd(A); 
%     EF ={x1_hom, x2_hom, A ,V};
    %% Schaetzung der Matrizen
    % G_s = V9 % Stacking of G 
    G_s = V(:,9);
    G = [G_s(1:3) G_s(4:6) G_s(7:9)];
    % Singul?rwertzerlegung von G
    [U_G,S_G,V_G] = svd(G);
    %sigma=(S_G(1)+S_G(5))/2;
    if nargin == 2
        S_EF = [1 0 0;0 1 0;0 0 0]; % Skalierungsinvarianz
    else
        S_EF = [S_G(1) 0 0;0 S_G(5) 0;0 0 0];
    end
    EF_schaetz = U_G*S_EF*V_G';
    EF = EF_schaetz;
   %% Schaetzung der Matrizen
    % G_s = V9 % Stacking of G 
    G_s = V(:,9);
    G = [G_s(1:3) G_s(4:6) G_s(7:9)];
    % Singul?rwertzerlegung von G
    [U_G,S_G,V_G] = svd(G);
    %sigma=(S_G(1)+S_G(5))/2;
    if nargin == 2
        S_EF = [1 0 0;0 1 0;0 0 0]; % Skalierungsinvarianz
    else
        S_EF = [S_G(1) 0 0;0 S_G(5) 0;0 0 0];
    end
    EF_schaetz = U_G*S_EF*V_G';
    EF = EF_schaetz;
end

