clc,clear,close all
% img loasd
img = imread("river_map/river_map_02.jpg");
% gray scale
gray_img = rgb2gray(img);
% gausianblur
Iblur = imgaussfilt(gray_img,3);
% canny edge1
BW1 = edge(Iblur,'Canny',[0.1,0.3],5);


figure(1)
montage({Iblur,BW1})
title("gausianblur         canny edge")

%% mask a region of interest
[img_col,img_row]= size(gray_img);
for i=1:img_row
    for j=1:img_col
        if i>=-(img_row*0.15)/img_col*j + img_row*0.15 && ...
            i<=(img_row*0.15)/img_col*j + img_row*0.85
            BW1(j,i)=BW1(j,i)*225;
        else
            BW1(j,i)=BW1(j,i)*0;
        end
    end
end


figure(2)
imshow(BW1) 
hold on
plot([0,img_row*0.15],[img_col,0])
hold on
plot([img_row*0.85,img_row],[0,img_col])
title("mask line")

%% hough line detect
figure(3)
[H,T,R] = hough(BW1,'Theta',-30:0.5:30);
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
lines = houghlines(BW1,T,R,P,'FillGap',30,'MinLength',10);
title("hough trans form")

figure(4)
imshow(BW1), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
title("hough line")

%% drowed line(linearization)
img_center = 0.5*img_row;
left = [];
rigth = [];
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    for i=1:2
        if img_center > xy(i,1)
            left(end+1,:) = xy(i,:);
        elseif img_center < xy(i,1)
            rigth(end+1,:) = xy(i,:);
        end
    end
end
figure(1)
imshow(img), hold on;
left_x = 1:img_row/2;

plot(left(:,1),left(:,2),"or"); hold on;
[left_poly,s] = polyfit(left(:,1),left(:,2),1);
left_line = polyval(left_poly,left_x,s);
plot(left_x,left_line,"r","LineWidth",3); hold on;

rigth_x = img_row/2+1:img_row;
plot(rigth(:,1),rigth(:,2),"ob"); hold on;
rigth_poly = polyfit(rigth(:,1),rigth(:,2),1);
rigth_line = polyval(rigth_poly,rigth_x);
plot(rigth_x,rigth_line,"b","LineWidth",3);hold on;

l_1 = ([0,img_col]-left_poly(2))/left_poly(1);
r_1 = ([0,img_col]-rigth_poly(2))/rigth_poly(1);
mid_line = 0.5*(r_1+l_1);
plot(mid_line,[0,img_col],"w","LineWidth",3);hold on;

  


















