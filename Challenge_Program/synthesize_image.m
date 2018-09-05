function [img_final] = synthesize_image(I1_Rec_color,I2_Rec_color,disparity_1,disparity_2,interp)



% parameters
% interp = 0.5;   % interpolation factor

i1 = I1_Rec_color;
i2 = I2_Rec_color;
% load('disparity_right_left.mat')
% load('disparity_left_right.mat')
% disparity_1 = disparity_left_right;
% disparity_2 = disparity_right_left;
d1 =double(disparity_1) ;
d2 = double(disparity_2);
% tag bad depth values with NaNs
d1(d1==0) = nan;
d2(d2==0) = nan;

% synthesize new image and disparity map
[out,dmap,rmap] = genIntView(interp,i1,i2,d1,d2);   % generate view
[outr,dmapr] = refineView(rmap,out,dmap);           % refine it
dmap_final = fillDMap(dmapr);                       % fill disparity map
img = fillRegion(outr,dmap_final);                  % fill color image
% img = fillRegion(out,dmap);
img_final = refineHoleBorders(img,outr);            % refine it

% plot
% figure
% imshow(img_final)
% title('Synthesized image')
% figure
% imshow(dmap_final)
% title('Synthesized disparity map')
end
