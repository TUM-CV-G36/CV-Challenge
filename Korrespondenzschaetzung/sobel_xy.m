function [Fx, Fy] = sobel_xy(input_image)

h1 = [1 2 1;0 0 0;-1 -2 -1];
h2 = [1 0 -1;2 0 -2;1 0 -1];

Fy = conv2(input_image,h1,'same');
Fx = conv2(input_image,h2,'same');

end