l1 = imread('L1.JPG');
r1 = imread('R1.JPG');

%% Farbbildkonvertierung
gray_l1 = rgb_to_gray(l1);
gray_r1 = rgb_to_gray(r1);


%% Harris Detector
merkmale_l1 = harris_detektor(gray_l1, 'segment_length', 9, 'k', 0.06,'do_plot',true);
merkmale_r1 = harris_detektor(gray_r1, 'segment_length', 9, 'k', 0.06,'do_plot',true);

%% Punkt_Korrespondenzen 
Korrespondenzen = punkt_korrespondenzen(gray_l1,gray_r1,merkmale_l1,merkmale_r1,'window_length',25,'min_corr', 0.95,'do_plot',true)