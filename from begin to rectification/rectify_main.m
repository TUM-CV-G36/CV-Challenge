l1 = imread('L2.JPG');
r1 = imread('R2.JPG');
 %% Farbbildkonvertierung
gray_l1 = rgb_to_gray(l1);
gray_r1 = rgb_to_gray(r1);
 %% Harris Detector

merkmale_l1 = harris_detektor(gray_l1,'segment_length',9,'k',0.05,'min_dist',40,'N',50);
merkmale_r1 = harris_detektor(gray_r1,'segment_length',9,'k',0.05,'min_dist',40,'N',50);
 %% Punkt_Korrespondenzen 

 Korrespondenzen = punkt_korrespondenzen(gray_l1,gray_r1,merkmale_l1,merkmale_r1,'window_length',25,'min_corr',0.9);
 %% Optimize KP
% figure(1)
 %matchedPoints1 = Korrespondenzen(1:2,:)';
% matchedPoints2 = Korrespondenzen(3:4,:)';
% showMatchedFeatures(gray_l1,gray_r1,matchedPoints1,matchedPoints2)
% for i = 1:size(matchedPoints1,1)
%     distance_KP(i) = norm(matchedPoints1(i,:)-matchedPoints2(i,:));
%     if distance_KP(i) > 250
%         matchedPoints1(i,:) = [0,0];
%         matchedPoints2(i,:) = [0,0];
%     end
% end
% figure(2)
% matchedPoints1(all(matchedPoints1 == 0,2),:)=[];
% matchedPoints2(all(matchedPoints2 == 0,2),:)=[];
[matchedPoints1,matchedPoints2] = optimize_KP(Korrespondenzen);
%showMatchedFeatures(gray_l1,gray_r1,matchedPoints1,matchedPoints2)
Korrespondenzen_opt = [matchedPoints1'; matchedPoints2'];
%% Fundamentalmatrix
F = achtpunktalgorithmus(Korrespondenzen);
%% K Matrix
 load('K.mat');
%% epipoles
 [epipole1,epipole2] = epipole_aus_F(F);
 %% Rectifiy Matrices
 [H1,H2] = rectify_matrix2(matchedPoints1', matchedPoints2',epipole1,epipole2,K);
% rectified KP
  [KP1_Rec,KP2_Rec] = rectification(matchedPoints1',matchedPoints2',epipole1,epipole2,K);
  KP1_Rec = KP1_Rec(1:2,:);
  KP2_Rec = KP2_Rec(1:2,:);
%% Rectification
rows_of_image = size(gray_l1,1);
columns_of_image = size(gray_l1,2);
x_coordinate = zeros(1,0);
y_coordinate = zeros(1,0);
x_temp = [1:columns_of_image];
for i =1:rows_of_image
    y_temp = i * ones(1,columns_of_image);
    y_coordinate = [y_coordinate,y_temp];
    x_coordinate = [x_coordinate,x_temp];
end
Location = [x_coordinate;y_coordinate;ones(1,size(x_coordinate,2))];
Location_Rec1 = H1 * Location;
Location_Rec2 = H2 * Location;
[min_y,~] = min(Location_Rec1(2,:));
[min_x,~] = min(Location_Rec2(1,:));
Location_Rec1(1,:) = Location_Rec1(1,:) - repmat(min_x-1,1,size(Location,2));
Location_Rec1(2,:) = Location_Rec1(2,:) - repmat(min_y-1,1,size(Location,2));
Location_Rec1 = Location_Rec1(1:2,:);
Location_Rec2(1,:) = Location_Rec2(1,:) - repmat(min_x-1,1,size(Location,2));
Location_Rec2(2,:) = Location_Rec2(2,:) - repmat(min_y-1,1,size(Location,2));
Location_Rec2 = Location_Rec2(1:2,:);
Location_Rec1_int = round(Location_Rec1);
Location_Rec2_int = round(Location_Rec2);
KP1_Rec(1,:) = KP1_Rec(1,:) - repmat(min_x-1,1,size(KP1_Rec,2));
KP1_Rec(2,:) = KP1_Rec(2,:) - repmat(min_y-1,1,size(KP1_Rec,2));
KP2_Rec(1,:) = KP2_Rec(1,:) - repmat(min_x-1,1,size(KP2_Rec,2));
KP2_Rec(2,:) = KP2_Rec(2,:) - repmat(min_y-1,1,size(KP1_Rec,2));
I1 = gray_l1;
I2 = gray_r1;
% I1_Rec = uint8(zeros(2000,3000));
% I2_Rec = I1_Rec;
for i = 1:size(Location_Rec1_int,2)
    I1_Rec(Location_Rec1_int(2,i) , Location_Rec1_int(1,i)) = I1(Location(2,i) , Location(1,i));
end
for i = 1:size(Location_Rec2_int,2)
    I2_Rec(Location_Rec2_int(2,i) , Location_Rec2_int(1,i)) = I2(Location(2,i) , Location(1,i));
end
imshowpair(I1_Rec,I2_Rec)
hold on
 % test rectification
% connect the KP pairs
 x1 = KP1_Rec(1,:);
 x2 = KP2_Rec(1,:);
 y1 = KP1_Rec(2,:);
 y2 = KP1_Rec(2,:);
 for i = 1:size(x1,2)
     plot(x1,y1,'ro',x2,y2,'g+')
     line([x1(i),x2(i)],[y1(i),y2(i)],'Color','y','LineStyle','-')     
 end
%%
%        校准之后的矩阵分别为
%        I1_Rec 和 I2_Rec
%        分别对应左图和右图

