function gray_image = rgb_to_gray(input_image)
    % Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
    % das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
    input_image=double(input_image);
    [a,b,c]=size(input_image);
    if c==1
        gray_image=uint8(input_image);
        return
    else
    r=input_image(:,:,1);
    g=input_image(:,:,2);
    b=input_image(:,:,3);
    gray_image=0.299*r+0.587*g+0.114*b;
    gray_image=uint8(gray_image);
end
