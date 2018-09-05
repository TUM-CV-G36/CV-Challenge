function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    % d = a^2/((b'*b)+(c'*c))
    e3_decke=[0 -1 0;1 0 0;0 0 0];
    sd=zeros(1,0);
%     for j=1:size(x1_pixel,2)
%         a=x2_pixel(:,j)'*F*x1_pixel(:,j);
%         b=e3_decke*F*x1_pixel(:,j);
%         c=x2_pixel(:,j)'*F*e3_decke;
%         d=a^2/((b'*b)+(c*c'));
%         sd=[sd d];
%     end
    a=diag(x2_pixel'*F*x1_pixel);
    b=e3_decke*F*x1_pixel;
    b=diag(b'*b);
    c=x2_pixel'*F*e3_decke;
    c=diag(c*c');
    sd=a'.^2./(b'+c');
end