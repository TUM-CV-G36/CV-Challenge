function [T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K)
    %% Preparation
    T_cell={T1,T2,T1,T2};
    R_cell={R1,R1,R2,R2};
    d=zeros(size(Korrespondenzen,2),2);
    d_cell={d d d d};
    x1_strech=Korrespondenzen(1:2,:);
    x2_strech=Korrespondenzen(3:4,:);
    zusatz_one=ones(1,size(Korrespondenzen,2));
    x1_strech_hom=[x1_strech;zusatz_one];
    x2_strech_hom=[x2_strech;zusatz_one];
    x1_hom=inv(K)*x1_strech_hom;
    x2_hom=inv(K)*x2_strech_hom;
    x1=x1_hom;
    x2=x2_hom;
    %% Reconstruction
     N=size(Korrespondenzen,2);
    for i=1:4
        M1_1=[];
        M1_2=[];
        M2_1=[];
        M2_2=[];
        for j=1:N
            x1_decke=Dach(x1(:,j));
            x2_decke=Dach(x2(:,j));
            M1_1{j}=x2_decke*R_cell{i}*x1(:,j);
            M1_2=[M1_2;x2_decke*T_cell{i}];
            M2_1{j}=x1_decke*R_cell{i}'*x2(:,j);
            M2_2=[M2_2;-x1_decke*R_cell{i}'*T_cell{i}];
        end
        m1{i}=[blkdiag(M1_1{:}) M1_2];
        m2{i}=[blkdiag(M2_1{:}) M2_2];
        [U1,S1,V1]=svd(m1{i});
        [U2,S2,V2]=svd(m2{i});
        d1=V1(:,end);
        d1=d1/d1(end);
        d1=d1(1:end-1);
        d2=V2(:,end);
        d2=d2/d2(end);
        d2=d2(1:end-1);
        d_cell{i}=[d1 d2];
        p_num(i)=numel(find(d_cell{i}>0));
    end
    [value,index]=max(p_num);
    T=T_cell{index};
    R=R_cell{index};
    lambda=d_cell{index};
    M1=m1{4};
    M2=m2{4};
end