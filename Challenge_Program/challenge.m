%% Computer Vision Challenge

% Groupnumber:
group_number = 0;

% Groupmembers:
% members = {'Max Mustermann', 'Johannes Daten'};
members = {'Hu Yichen','Wu Yunhai','Lu YingYing','Zhang Qili','Zhang Hongjingye'};

% Email-Adress (from Moodle!):
% mail = {'ga99abc@tum.de', 'daten.hannes@tum.de'};
mail = {'ge56vay@tum.de'};

%% Load images
warning off
I1_color = imread('L2.JPG'); 
I2_color = imread('R2.JPG');
 %% Farbbildkonvertierung
gray_l1 = rgb_to_gray(I1_color);
gray_r1 = rgb_to_gray(I2_color);
 %% Harris Detector

merkmale_l1 = harris_detektor(gray_l1,'segment_length',9,'k',0.05,'min_dist',40,'N',50);
merkmale_r1 = harris_detektor(gray_r1,'segment_length',9,'k',0.05,'min_dist',40,'N',50);
 %% Punkt_Korrespondenzen 

 Korrespondenzen = punkt_korrespondenzen(gray_l1,gray_r1,merkmale_l1,merkmale_r1,'window_length',25,'min_corr',0.9);

%% Optimize KP
figure(1)
matchedPoints1 = Korrespondenzen(1:2,:)';
matchedPoints2 = Korrespondenzen(3:4,:)';
showMatchedFeatures(gray_l1,gray_r1,matchedPoints1,matchedPoints2)

[matchedPoints1,matchedPoints2] = optimize_KP(Korrespondenzen);
figure(2)
showMatchedFeatures(gray_l1,gray_r1,matchedPoints1,matchedPoints2)
Korrespondenzen_opt = [matchedPoints1'; matchedPoints2'];
x1_hom = [Korrespondenzen_opt([1:2],:);ones(1,size(Korrespondenzen_opt,2))];
x2_hom = [Korrespondenzen_opt([3:4],:);ones(1,size(Korrespondenzen_opt,2))];
%% Fundamentalmatrix
% F = achtpunktalgorithmus(Korrespondenzen_opt);
% [F,e1,e2] = fundmatrix(x1_hom,x2_hom);
load('fmatrix');
F = fmatrix;
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

% Generate Location Vector
IND = [1:6000000];
s = [3000,2000];
[x_coordinate,y_coordinate] = ind2sub(s,IND);
Location = [x_coordinate;y_coordinate];
Location = [x_coordinate;y_coordinate;ones(1,size(x_coordinate,2))];
% Rectificaiton
Location_Rec1 = H1 * Location;
Location_Rec2 = H2 * Location;

Location_Rec1 = Location_Rec1(1:2,:);

Location_Rec2 = Location_Rec2(1:2,:);
Location_Rec1_int = round(Location_Rec1);
Location_Rec2_int = round(Location_Rec2);

[min_y_1,~] = min(Location_Rec1_int(2,:));
[min_y_2,~] = min(Location_Rec2_int(2,:));
[min_x_1,~] = min(Location_Rec1_int(1,:));
[min_x_2,~] = min(Location_Rec2_int(1,:));
min_x = min(min_x_1,min_x_2);
min_y = min(min_y_1,min_y_2);
% Move the images to the center of the graph
Location_Rec1_int(1,:) = Location_Rec1_int(1,:) - repmat(min_x-1,1,size(Location,2));
Location_Rec1_int(2,:) = Location_Rec1_int(2,:) - repmat(min_y-1,1,size(Location,2));
Location_Rec2_int(1,:) = Location_Rec2_int(1,:) - repmat(min_x-1,1,size(Location,2));
Location_Rec2_int(2,:) = Location_Rec2_int(2,:) - repmat(min_y-1,1,size(Location,2));
%%
I1 = gray_l1;
I2 = gray_r1;
I1_Rec = uint8(zeros(2000,3000));
I2_Rec = I1_Rec;
for i = 1:size(Location_Rec1_int,2)
    I1_Rec(Location_Rec1_int(2,i) , Location_Rec1_int(1,i)) = I1(Location(2,i) , Location(1,i));
end
for i = 1:size(Location_Rec2_int,2)
    I2_Rec(Location_Rec2_int(2,i) , Location_Rec2_int(1,i)) = I2(Location(2,i) , Location(1,i));
end
I2_Rec = I2_Rec(1:2000,198:3197);   % move the whole I2_Rec image to the left by 197
Location_Rec2_int(1,:) = Location_Rec2_int(1,:) - repmat(197,1,size(Location,2));
imshowpair(I1_Rec,I2_Rec)
hold on
 % test rectification
% connect the KP pairs
 KP1_Rec(1,:) = KP1_Rec(1,:) - repmat(min_x-1,1,size(KP1_Rec,2));
 KP1_Rec(2,:) = KP1_Rec(2,:) - repmat(min_y-1,1,size(KP1_Rec,2));
 KP2_Rec(1,:) = KP2_Rec(1,:) - repmat(min_x-1+197,1,size(KP2_Rec,2));
 KP2_Rec(2,:) = KP2_Rec(2,:) - repmat(min_y-1,1,size(KP1_Rec,2));
 x1 = KP1_Rec(1,:);
 x2 = KP2_Rec(1,:);
 y1 = KP1_Rec(2,:);
 y2 = KP1_Rec(2,:);
 for i = 1:size(x1,2)
     plot(x1,y1,'ro',x2,y2,'g+')
     line([x1(i),x2(i)],[y1(i),y2(i)],'Color','y','LineStyle','-')     
 end
 hold off
 %% Fill in color ---> from gray image to color image
 r1= I1_color(:,:,1);
g1 = I1_color(:,:,2);
b1 = I1_color(:,:,3);
r2 = I2_color(:,:,1);
g2 = I2_color(:,:,2);
b2 = I2_color(:,:,3);
Location_Rec2_int_x =  Location_Rec2_int(1,:);
Location_Rec2_int_x(Location_Rec2_int_x >3000) = 3000;
Location_Rec2_int_y = Location_Rec2_int(2,:);
Location_Rec2_int_y(Location_Rec2_int_y > 2000) = 2000;
Location_Rec2_int = [Location_Rec2_int_x ; Location_Rec2_int_y];
I1_Rec_color = I1_color;
for i = 1:size(Location_Rec2_int,2)
    I2_Rec_color(Location_Rec2_int(2,i) , Location_Rec2_int(1,i),1) = r2(Location_Rec2_int(2,i),Location_Rec2_int(1,i));
end
for i = 1:size(Location_Rec2_int,2)
    I2_Rec_color(Location_Rec2_int(2,i) , Location_Rec2_int(1,i),2) = g2(Location_Rec2_int(2,i),Location_Rec2_int(1,i));
end
for i = 1:size(Location_Rec2_int,2)
    I2_Rec_color(Location_Rec2_int(2,i) , Location_Rec2_int(1,i),3) = b2(Location_Rec2_int(2,i),Location_Rec2_int(1,i));
end

%% Compute Disparity map
% load('disparity_right_left.mat')
% load('disparity_left_right.mat')
% disparity_1 = disparity_left_right;
% disparity_2 = disparity_right_left;
tic();
disparity_1 = disparity_map(I1_Rec,I2_Rec);
disparity_2 = disparity_map(I2_Rec,I1_Rec);
%% Free Viewpoint Rendering
% start execution timer -> tic;

warning('off','stats:kmeans:EmptyCluster')
warning('off','stats:kmeans:FailedToConverge')
warning('off','stats:kmSeans:MissingDataRemoved');
interp = 0;
img_final = synthesize_image(I1_Rec_color,I2_Rec_color,disparity_1,disparity_2,interp);
elapsed = toc();
fprintf('Synthesizing image took %.2f min.\n', elapsed / 60.0);
% stop execution timer -> toc;
% elapsed_time = Inf;

%% Display Output
% Display Virtual View
imshow(img_final);