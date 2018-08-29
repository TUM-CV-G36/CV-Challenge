function merkmale = harris_detektor(input_image, varargin)
%% Input parser
default_sg = 15;
default_k = 0.05;
default_tau = 1e6;
default_dp = false;
default_min_dist = 20;
default_tile_size = [200,200];
default_N = 5;
    
p=inputParser;
Validsg=@(x)isnumeric(x)&&(mod(x,2)==1)&&(x>0);
Validk=@(x)isnumeric(x)&&(x>=0)&&(x<=1);
Validtau=@(x)isnumeric(x)&&(x>0);
Validmindist=@(x)isnumeric(x)&&(x>=1);
Validtilesize=@(x)isnumeric(x);
ValidN=@(x)isnumeric(x)&&(x>=1);
    
addParameter(p,'segment_length',default_sg,Validsg);
addParameter(p,'k',default_k,Validk);
addParameter(p,'tau',default_tau,Validtau);
addParameter(p,'do_plot',default_dp,@islogical);
addParameter(p,'min_dist',default_min_dist,Validmindist);
addParameter(p,'tile_size',default_tile_size,Validtilesize);
addParameter(p,'N',default_N,ValidN);
    
parse(p,varargin{:});
tile_size = p.Results.tile_size

if size(tile_size,2) == 1
    tile_size = [tile_size,tile_size];
end
if size(tile_size,2)>2
    tile_size = [tile_size(1),tile_size(2)];
end

% set parameters
segment_length = p.Results.segment_length;
k = p.Results.k;
tau = p.Results.tau;
do_plot = p.Results.do_plot;
min_dist = p.Results.min_dist;
tile_size = p.Results.tile_size;
N = p.Results.N;
    
%% Calculating harris-matrix

[a,b,c] = size(input_image)
if c~=1
    error('Image format has to be NxMx1')
end

gray = double(input_image);
[Ix,Iy] = sobel_xy(gray);

n = segment_length;
pm = (n-1)/2;
x = -pm:pm;
sigma = n/5;
arg = (-x.*x)/(2*sigma*sigma);
w = exp(arg);
w = w/sum(w(:));
W = w'*w;
  
G11 = conv2(Ix.^2,W,'same');
G12 = conv2(Ix.*Iy,W,'same');
G21 = G12;
G22 = conv2(Iy.^2,W,'same');
    
%% Harris Detector Merkmal-extraction
n = segment_length;
[row,col,c] = size(input_image);
H = (G11.*G22-G12.^2)-k*(G11+G22).^2;
corners = zeros(row,col);
corners(ceil(n/2):row-ceil(n/2),ceil(n/2):col-ceil(n/2)) = H(ceil(n/2):row-ceil(n/2),ceil(n/2):col-ceil(n/2));
corners(corners<tau ) = 0;
    
%%  Considering min_dist
corner = zeros(row+2*min_dist,col+2*min_dist);
for i = min_dist+1:min_dist+row
    for j = min_dist+1:min_dist+col
        corner(i,j) = corners(i-min_dist,j-min_dist);
    end
end

[sorted_list,sorted_index] = sort(corner(:),'descend');
sorted_index(sorted_list==0) = [];
    
%% Harris Detector Kacheln; Akkumulatorfeld
[x,y] = meshgrid([-min_dist:min_dist],[-min_dist:min_dist]);
AKKA = zeros(ceil(row/tile_size(1)),ceil(col/tile_size(2)));
Merk = zeros(2,min(numel(AKKA)*N,numel(sorted_index)));
  
%% Harris Detector
merk_counter = 1;
for i = 1:numel(sorted_index)
    c_index = sorted_index(i);
    if corner(c_index) == 0 
        continue
    else
        col_c = ceil(c_index/size(corner,1));
        row_c = c_index-(col_c-1)*size(corner,1);
        A_x = ceil((row_c-min_dist)/tile_size(1)) ; % row_num in AKKA
        A_y = ceil((col_c-min_dist)/tile_size(2)) ; % col_num in AKKA     
    end
    
    AKKA(A_x,A_y) = AKKA(A_x,A_y)+1;
    corner(row_c-min_dist:row_c+min_dist,col_c-min_dist:col_c+min_dist) = corner(row_c-min_dist:row_c+min_dist,col_c-min_dist:col_c+min_dist).*cake(min_dist);
    
    if AKKA(A_x,A_y) >= N
        corner((A_x-1)*tile_size(1)+1+min_dist:A_x*tile_size(1)+min_dist,(A_y-1)*tile_size(2)+1+min_dist:A_y*tile_size(2)+min_dist) = 0;
    end
    
    Merk(:,merk_counter) = [col_c-min_dist,row_c-min_dist];
    merk_counter = merk_counter+1;
    
end

Merk(:,all(Merk == 0,1)) = [];
merkmale = Merk;
%% Plot
if(do_plot == 1)
    figure
    colormap('gray')
    imagesc(input_image)
    hold on;
    plot(merkmale(1,:), merkmale(2,:), 'ro');
    axis('off');
end
end