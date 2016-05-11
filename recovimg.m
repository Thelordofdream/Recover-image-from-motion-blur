%recovimg('origin.jpg');
function recovered=recovimg(im)
%% 读入图片并灰度化
img = imread(im);
figure(1),imshow(img);
[ROW,COLUMN,RGB] = size(img);
if RGB == 3
    gb = rgb2gray(img);
elseif RGB ==1
    gb = img;
end
%function theta=get_theta(im)
%% 读入图片并灰度化
F = fft2(gb);
Hc = fftshift(F);
figure(2),subplot(221),imshow(Hc);
Hc=abs(Hc);

%% 获取角度
 Hc = Hc/max(max(Hc));
[ROW,COLUMN] = size(Hc);
x = zeros(1,ROW*COLUMN);
y = zeros(1,ROW*COLUMN);
count = 0;
for row = 1:ROW
    for column = 1:COLUMN
        if Hc(row,column) > 0.0005
            count = count+1;
            x(count) = row+1-ROW/2;
            y(count) = column+1-COLUMN/2;
        end
    end
end
% 线性回归获取移动角度
[p,s] = polyfit(x,y,1);
if s.normr>4500
    [p,s] = polyfit(y,x,1);
    rio = atan(p(1))/pi*180;
    rio = 90-rio;
    if rio<0
        rio = rio+180;
    end
    yfit = polyval(p,x);%求拟合后的y值;
    figure(2),subplot(222),plot(-y,x,'r.',x,-yfit,'b');
else
    rio = atan(p(1))/pi*180;
    if rio < 0
        rio = rio +180;
    end
    yfit = polyval(p,x);%求拟合后的y值;
    figure(2),subplot(222),plot(-y,x,'r.',-yfit,x,'b');
end

if rio > 170
    THETA = rio;
elseif rio < 10
    THETA = rio;
elseif rio >150
    THETA = rio-5;
elseif rio <30
    THETA = rio+5;
elseif rio >130
    THETA = rio-7;    
elseif rio <50
    THETA = rio+7;  
end
THETA
axis([-500 500 -500 500]);
%% 获取距离
x0=x;
x = zeros(1,ROW*COLUMN);
y = zeros(1,ROW*COLUMN);
count = 0;
for row = 1:ROW
    for column = 1:COLUMN
        if Hc(row,column) > 0.00015
            count = count+1;
            x(count) = row+1-ROW/2;
            y(count) = column+1-COLUMN/2;
        end
    end
end
figure(2),subplot(223),plot(-y,x,'r.',-yfit,x0,'b');

X = cos((THETA-90)/180*pi);
Y = sin((THETA-90)/180*pi);
length = round(sqrt(ROW.*ROW+COLUMN.*COLUMN)/2)+1;
dis =zeros(2,length);
for i = 1:count
    distance=round(X.*x(i)+Y.*y(i));
    if distance >0
        dis(1,distance) = dis(1,distance)+1;
    elseif distance <0
        dis(2,-distance) = dis(2,-distance)+1;
    end
end

mindistance1 = 1;
mindistance2 = 1;
count = 0;
rate = 10;
num = 2;
for i = 1+rate:length-rate 
    right = 1;
    for j = 1:(rate*2+1) 
        if dis(1,i-rate-1+j)<dis(1,i)
            right=0;
        end
    end
    if right == 1 
        mindistance1 = i;
        count = count+1;
        if count==num
            break
        end
    end
end
count = 0;
for i = 1+rate:length-rate
    right = 1;
    for j = 1:(rate*2+1) 
        if dis(2,i-rate-1+j)<dis(2,i)
            right=0;
        end
    end
    if right == 1 
        mindistance2 = i;
        count = count+1;
        if count==num
            break
        end
    end
end


dis2 = zeros(1,length*2);
for i = 1:length
    dis2(i) = dis(2,length+1-i);
end
dis2=[dis2(1:length),dis(1,:)];
g=1:1:length*2;
figure(2),subplot(224),plot(g,dis2);

mindistance = (mindistance2+mindistance1);
R = atan(COLUMN/ROW)/pi*180;
if (THETA-90)/180>(90-R)
    N = abs(ROW/X);
elseif (THETA-90)/180>R-90
    N = abs(COLUMN/Y);
elseif (THETA-90)/180>=-90
    N = abs(ROW/X);
end
LEN = round(2*num*N./mindistance)-2

%% 恢复
%LEN=46+dlen;
NSR=0.012;% NSR<1
img2 = im2double(img);
PSF = fspecial('motion', LEN, THETA);
recov_img = deconvwnr(img2, PSF, NSR);

%% 后期处理
if RGB == 3
    recov_img = rgb2gray(recov_img);
end
imgstro2 = imadjust(recov_img,[0.15,0.85],[0,1],0.85);
figure(3),imshow(imgstro2);
recovered = imgstro2;
