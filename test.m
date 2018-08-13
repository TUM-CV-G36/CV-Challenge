img = imread('Schach2_03.jpg');
gray = rgb_to_gray(img);
merkmale = harris_detektor_1(gray, 'segment_length', 9, 'k', 0.06, 'do_plot', true);