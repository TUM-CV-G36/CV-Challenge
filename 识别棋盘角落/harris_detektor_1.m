function merkmale = harris_detektor_1(input_image, varargin)
    % In dieser Funktion soll der Harris-Detektor implementiert werden, der
    % Merkmalspunkte aus dem Bild extrahiert

    %% Input parser
    default_sg=15;
  default_k=0.05;
  default_tau=1e6;
  default_dp=false;
  default_min_dist=20;
  default_tile_size=[200,200];
  default_N=5;
    
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
    tile_size=p.Results.tile_size
    if size(tile_size,2)==1
        tile_size=[tile_size,tile_size];
    end
    if size(tile_size,2)>2
        tile_size=[tile_size(1),tile_size(2)];
    end
    % set parameters
    segment_length=p.Results.segment_length;
    k=p.Results.k;
    tau=p.Results.tau;
    do_plot=p.Results.do_plot;
    min_dist=p.Results.min_dist;
    tile_size=p.Results.tile_size;
    N=p.Results.N;
    
    %% Calculating harris-matrix
    [a,b,c]=size(input_image)
    
    if c~=1
        error('Image format has to be NxMx1')
    end
    % Approximation des Bildgradienten
    gray=double(input_image);
    [Ix,Iy]=sobel_xy(gray);
    % Gewichtung (Gaussian)
    n=segment_length;
     pm=(n-1)/2;
    x=-pm:pm;
    sigma=n/5;
    arg=(-x.*x)/(2*sigma*sigma);
    w=exp(arg);
    %w(w<eps*max(w(:))) = 0;
    %sumw=sum(w(:));
    w=w/sum(w(:));
    W=w'*w;
    % Harris Matrix G  
    G11=conv2(Ix.^2,W,'same');
    G12=conv2(Ix.*Iy,W,'same');
    G21=G12;
    G22=conv2(Iy.^2,W,'same');
    G=[G11 G12;G21 G22];
    
    %% Harris Detector Merkmal-extraction
    n=segment_length;
    [row,col,c]=size(input_image);
    H=[];
    H=(G11.*G22-G12.^2)-k*(G11+G22).^2;
    corners=zeros(row,col);
    corners(ceil(n/2):row-ceil(n/2),ceil(n/2):col-ceil(n/2))=H(ceil(n/2):row-ceil(n/2),ceil(n/2):col-ceil(n/2));
    corners(corners<tau)=0;
    
    %%  Considering min_dist
    corner=zeros(row+2*min_dist,col+2*min_dist);
    for i=min_dist+1:min_dist+row
        for j=min_dist+1:min_dist+col
            corner(i,j)=corners(i-min_dist,j-min_dist);
        end
    end
    [sorted_list,sorted_index] = sort(corner(:),'descend');
    sorted_index(sorted_list==0)=[];
    
    %% Harris Detector Kacheln; Akkumulatorfeld
     [x,y]=meshgrid([-min_dist:min_dist],[-min_dist:min_dist]);
%     Cake=sqrt(x.^2+y.^2)>min_dist;
    AKKA=zeros(ceil(row/tile_size(1)),ceil(col/tile_size(2)));
    Merk=zeros(2,min(numel(AKKA)*N,numel(sorted_index)));
  
    %% Harris Detector
    merk_counter=1;
    for i=1:numel(sorted_index)
        c_index= sorted_index(i);
        if corner(c_index)==0
            continue
        else
            % row & col in corners
            col_c=ceil(c_index/size(corner,1));
            row_c=c_index-(col_c-1)*size(corner,1);
            % row & col in AKKA
            A_x=ceil((row_c-min_dist)/tile_size(1)) ; % row_num in AKKA
            A_y=ceil((col_c-min_dist)/tile_size(2)) ; % col_num in AKKA
            % check if corners(x,y)==0
            
        end
        AKKA(A_x,A_y)=AKKA(A_x,A_y)+1;
        % using cake matrix
        corner(row_c-min_dist:row_c+min_dist,col_c-min_dist:col_c+min_dist)=corner(row_c-min_dist:row_c+min_dist,col_c-min_dist:col_c+min_dist).*cake(min_dist);
        % maximum N merkmale in one tile
        if AKKA(A_x,A_y)>=N
            corner((A_x-1)*tile_size(1)+1+min_dist:A_x*tile_size(1)+min_dist,(A_y-1)*tile_size(2)+1+min_dist:A_y*tile_size(2)+min_dist)=0;
            %corner((((A_x-1)*tile_size(1))+1+min_dist):min(size(corners,1),A_x*tile_size(1)+min_dist),(((A_y-1)*tile_size(2))+1+min_dist):min(size(corners,2),A_y*tile_size(2)+min_dist))=0;
        end
        Merk(:,merk_counter)=[col_c-min_dist,row_c-min_dist];
        merk_counter=merk_counter+1;
    end
    % delete all Merk(x,y)==0
    Merk(:,all(Merk==0,1))=[];
    merkmale=Merk;
    
   %% X-corner judgment
    mark=zeros(1,size(merkmale,2));
     for i=1:size(merkmale,2)
         mark(i)=isXcorner(merkmale(1,i),merkmale(2,i),gray,min_dist,45,40);  
         if mark(i)==false
             merkmale(1,i)=0;
             merkmale(2,i)=0;
         end
     end
     merkmale(:,all(merkmale==0,1))=[];
    
   %% Plot
    if(do_plot==1)
        figure
        colormap('gray')
        imagesc(input_image)
        hold on;
        plot(merkmale(1,:), merkmale(2,:), 'ro');
        axis('off');
    end
end