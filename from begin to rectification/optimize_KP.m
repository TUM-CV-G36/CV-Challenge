function [matchedPoints1,matchedPoints2] = optimize_KP(Korrespondenzen)
matchedPoints1 = Korrespondenzen(1:2,:)';
matchedPoints2 = Korrespondenzen(3:4,:)';
%showMatchedFeatures(gray_l1,gray_r1,matchedPoints1,matchedPoints2)
for i = 1:size(matchedPoints1,1)
    distance_KP = norm(matchedPoints1(i,:)-matchedPoints2(i,:));
    distance_y = abs(matchedPoints1(i,2) - matchedPoints2(i,2));
     distance_x = abs(matchedPoints1(i,1) - matchedPoints2(i,1));
    if (distance_KP > 250) || (distance_y >100) || (distance_x >200)
        matchedPoints1(i,:) = [0,0];
        matchedPoints2(i,:) = [0,0];
    end
end
matchedPoints1(all(matchedPoints1 == 0,2),:)=[];
matchedPoints2(all(matchedPoints2 == 0,2),:)=[];
%showMatchedFeatures(gray_l1,gray_r1,matchedPoints1,matchedPoints2)
end