% 判断是否为X角落，输入为x,y坐标，图像矩阵以及判断距离和两个阀值，斜对角的部分相似，相邻的部分相异。判断该距离内的图像是否对称
% 注意x坐标是列数，y坐标是行数
% mark = isXcorner(x,y,image,dist,thr_same,thr_diff)
function mark = isXcorner(x,y,image,dist,thr_same,thr_diff)
    gray=double(image);
    [a,b,c]=size(image)
    if c~=1
        error('Image format has to be NxMx1')
    end
    if (x<dist) || (y<dist)
        mark = false;
        return 
    end
        
    % 4 squares around the middle point
    sq_lu=gray([y-dist:y],[x-dist:x]);  % square left-up
    sq_ru=gray([y-dist:y],[x:x+dist]); % square right-up
    sq_ld=gray([y:y+dist],[x-dist:x]); % square left-down
    sq_rd=gray([y:y+dist],[x:x+dist]); % square right-down

    % average value
    av_lu=sum(sq_lu(:))/numel(sq_lu);
    av_ru=sum(sq_ru(:))/numel(sq_ru);
    av_ld=sum(sq_ld(:))/numel(sq_ld);
    av_rd=sum(sq_rd(:))/numel(sq_rd);
    
    % punkt-symmetrisch
    diff_lu_rd=abs(av_lu-av_rd);
    diff_ru_ld=abs(av_ru-av_ld);
    diff_lu_ld=abs(av_lu-av_ld);
    diff_ru_rd=abs(av_ru-av_rd);
    
    % Judgment
     if (diff_lu_rd<thr_same)&&(diff_ru_ld<thr_same)
         mark_same = true;
     else
         mark_same = false;
     end
     
     if (diff_lu_ld>thr_diff)&&(diff_ru_rd>thr_diff)
         mark_diff = true;
     else
         mark_diff=false;  
     end
     
     mark = mark_same & mark_diff;
  
     
end