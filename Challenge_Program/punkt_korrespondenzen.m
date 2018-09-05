function [ Korrespondenzen ] = punkt_korrespondenzen( I1, I2, Mpt1, Mpt2, varargin) 
%% Input parser
P = inputParser;

P.addOptional('window_length',25, @isnumeric)
P.addOptional('min_corr', 0.95, @isnumeric)
P.addOptional('do_plot', false, @islogical);

P.parse(varargin{:});

window_length = P.Results.window_length;
min_corr = P.Results.min_corr;
do_plot = P.Results.do_plot;

%% Merkmalsvorbereitung
if mod(window_length,2) == 0
    window_length = window_length+1;
end

num_Merkmale1 = size(Mpt1,2);
num_Merkmale2 = size(Mpt2,2);
window_size = floor(window_length/2);
intensity_val1 = -1*ones(window_length^2,num_Merkmale1);
intensity_val2 = -1*ones(window_length^2,num_Merkmale2);
num_merkmal_border = [0;0];

for i = 1:num_Merkmale1
    try
        intensity_val1(:,i) = reshape(I1(Mpt1(2,i)-window_size:Mpt1(2,i)+window_size,Mpt1(1,i)-window_size:Mpt1(1,i)+window_size),window_length^2,1);
    catch
        num_merkmal_border(1) = num_merkmal_border(1)+1;
    end
end

for j = 1:num_Merkmale2
    try 
        intensity_val2(:,j) = reshape(I2(Mpt2(2,j)-window_size:Mpt2(2,j)+window_size,Mpt2(1,j)-window_size:Mpt2(1,j)+window_size),window_length^2,1);
    catch
        num_merkmal_border(2) = num_merkmal_border(2)+1;
    end
end

Mpt1(:,(intensity_val1(1,:)==-1)) = [];
Mpt2(:,(intensity_val2(1,:)==-1)) = [];

%% Normiertung der Fenster
num1 = size(Mpt1,2);
num2 = size(Mpt2,2);
intensity_val1 = zeros(window_length^2,num1);
intensity_val2 = zeros(window_length^2,num2);
   
for i = 1:num1
    intensity_val1(:,i) = reshape(I1(Mpt1(2,i)-window_size:Mpt1(2,i)+window_size,Mpt1(1,i)-window_size:Mpt1(1,i)+window_size),window_length^2,1);
end
   
for j = 1:num2
    intensity_val2(:,j) = reshape(I2(Mpt2(2,j)-window_size:Mpt2(2,j)+window_size,Mpt2(1,j)-window_size:Mpt2(1,j)+window_size),window_length^2,1);       
end  

mean1 = mean(intensity_val1);    
mean2 = mean(intensity_val2);

std1 = sqrt(var(intensity_val1));
std2 = sqrt(var(intensity_val2));

for i = 1:size(intensity_val1,2)
    abweichung = intensity_val1(:,i)-mean1(:,i);
    intensity_val1(:,i) = abweichung/std1(:,i);
end

Mat_feat_1 = intensity_val1;

for i = 1:size(intensity_val2,2)
    abweichung = intensity_val2(:,i)-mean2(:,i);
    intensity_val2(:,i) = abweichung/std2(:,i);
end

Mat_feat_2 = intensity_val2;
    
%% Normalized Cross Correlation
NCC_matrix = 1/((window_length)^2-1)*Mat_feat_2'*Mat_feat_1;
NCC_matrix(NCC_matrix<min_corr) = 0;

[sorted_list, sorted_index] = sort(NCC_matrix(:),'descend');
sorted_index(sorted_list==0) = [];

%% Korrespondenzmatrix
Korrespondenzen = zeros(4,min(num1,num2));
a = 1;

number = numel(sorted_index);
size_ncc = size(NCC_matrix);

for it = 1:number 
    pt_index = sorted_index(it); 
    
    if(NCC_matrix(pt_index) == 0)
        continue;   
    else
        [Idx_fpt2,Idx_fpt1] = ind2sub(size_ncc,pt_index);
    end

    NCC_matrix(:,Idx_fpt1) = 0;
    Korrespondenzen(:,a) = [Mpt1(:,Idx_fpt1);Mpt2(:,Idx_fpt2)];
    a = a+1;
end

Korrespondenzen = Korrespondenzen(:,1:a-1);
    
%% Visualize found matches

if do_plot
figure

imshow(uint8(I1))
hold on;
plot(Korrespondenzen(1,:),Korrespondenzen(2,:),'g*')

imshow(uint8(I2))
alpha(0.5);
hold on;
plot(Korrespondenzen(3,:),Korrespondenzen(4,:),'r*')

title('Korrespondenzschaetzung von Merkmalspunkten')
for i=1:size(Korrespondenzen,2)
    hold on;
    x_1 = [Korrespondenzen(1,i), Korrespondenzen(3,i)];
    x_2 = [Korrespondenzen(2,i), Korrespondenzen(4,i)];
    line(x_1,x_2);
end
end
end
