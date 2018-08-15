function gray_image = rgb_to_gray(input_image)
  mysize = size(input_image);
  if numel(mysize)>2
      input_image=double(input_image);
      gray_image=0.299*input_image(:,:,1)+0.587*input_image(:,:,2)+0.114*input_image(:,:,3); 
      gray_image=uint8(gray_image);
  else
      gray_image=input_image;
  end

end 