clear all

f1=figure;
f2=figure;
f3=figure;
f4=figure;
f5=figure;
f6=figure;
f7=figure;
f8=figure;

% ------Read and Display Image -----

% read the picture
mypicture=imread('mypicture.jpg');

%map the intensity values in range [0 1]
mypicture=im2double(mypicture);

%Resizing the image
mypicture=imresize(mypicture,[1200, 800]);

%convert image to grayscale
mypicture_gray=rgb2gray(mypicture);

%display both images (RGB and Grayscale)
figure(f1)

subplot(1,4,1)
imshow(mypicture)
title('Colored Image - Original')

subplot(1,4,3)
imshow(mypicture_gray)
title('Gray Scaled Image - Original')

% ------ Histogram Normalization -----

figure(f2)

subplot(2,4,1)
imhist(mypicture(:,:,1))
title('Before Normalizaiton - Red Color')

subplot(2,4,2)
imhist(mypicture(:,:,2))
title('Blue Color')

subplot(2,4,3)
imhist(mypicture(:,:,3))
title('Green Color')

subplot(2,4,4)
imhist(mypicture_gray)
title('Gray Scale Image')


%another way to visualise distributions

[Rcount, Rloc]=imhist(mypicture(:,:,1));
[Bcount, Bloc]=imhist(mypicture(:,:,2));
[Gcount, Gloc]=imhist(mypicture(:,:,3));
[Blcount, Blloc]=imhist(mypicture_gray);

figure(f3)
subplot(2,1,1)
plot(Rloc, Rcount, 'r',Bloc, Bcount, 'b', Gloc, Gcount, 'g', Blloc, Blcount, 'k');
title('Before Normalization')
legend('Red', 'Blue','Green','GrayScale')

% Applying histogram equalization
%colored image
R=histeq(mypicture(:,:,1),256);
B=histeq(mypicture(:,:,2),256);
G=histeq(mypicture(:,:,3),256);
picture_hist=cat(3,R,G,B);

%grayscale image
picture_hist_gray=histeq(mypicture_gray,256);

%display both images (RGB and Grayscale)
figure(f1)

subplot(1,4,2)
imshow(picture_hist)
title('Normalized')

subplot(1,4,4)
imshow(picture_hist_gray)
title('Normalized')

figure(f2)

subplot(2,4,5)
imhist(R)
title('After Normalizaiton - Red Color')

subplot(2,4,6)
imhist(B)
title('Blue Color')

subplot(2,4,7)
imhist(G)
title('Green Color')

subplot(2,4,8)
imhist(picture_hist_gray)
title('Gray Scale Image')


%another way to visualise distributions

[Rcount, Rloc]=imhist(R);
[Bcount, Bloc]=imhist(B);
[Gcount, Gloc]=imhist(G);
[Blcount, Blloc]=imhist(picture_hist_gray);

figure(f3)
subplot(2,1,2)
plot(Rloc, Rcount, 'r',Bloc, Bcount, 'b', Gloc, Gcount, 'g', Blloc, Blcount, 'k');
title('After Normalization')
legend('Red', 'Blue','Green','GrayScale')

% ------ Brightness ------
%colored
picture_bright=mypicture+reshape([0.2, 0.5, 0.3], [1 1 3]);

%grayscale
picture_bright_gray=mypicture_gray+0.4;

%display results

figure(f4)

subplot(1,4,1)
imshow(mypicture)
title('Colored Image - Original')

subplot(1,4,3)
imshow(mypicture_gray)
title('Gray Scaled Image - Original')

subplot(1,4,2)
imshow(picture_bright)
title('Increased Brightness (0.2,0.5,0.3)')

subplot(1,4,4)
imshow(picture_bright_gray)
title('Increased Brightness (0.4)')

% ------- Contrast ----
%colored
picture_con=mypicture.*reshape([1.2, 1.8, 2.1], [1 1 3]);

%grayscale
picture_con_gray=mypicture_gray.*1.5;

%display results

figure(f5)

subplot(1,4,1)
imshow(mypicture)
title('Colored Image - Original')

subplot(1,4,3)
imshow(mypicture_gray)
title('Gray Scaled Image - Original')

subplot(1,4,2)
imshow(picture_con)
title('Contrast (1.2,1.8,2.1)')

subplot(1,4,4)
imshow(picture_con_gray)
title('Contrast (1.5)')

% -------Gamma Correction -----
%colored
picture_gam=mypicture.^(1/2.4);

%grayscale
picture_gam_gray=mypicture_gray.^(1/2.2);

%display results

figure(f6)

subplot(1,4,1)
imshow(mypicture)
title('Colored Image - Original')

subplot(1,4,3)
imshow(mypicture_gray)
title('Gray Scaled Image - Original')

subplot(1,4,2)
imshow(picture_gam)
title('Gamma Correction (1/2.4)')

subplot(1,4,4)
imshow(picture_gam_gray)
title('Gamma Correction (1/2.2)')

% ----- Negative ----
%colored
picture_neg=1-mypicture;

%grayscale
picture_neg_gray=1-mypicture_gray;

%display results

figure(f7)

subplot(1,4,1)
imshow(mypicture)
title('Colored Image - Original')

subplot(1,4,3)
imshow(mypicture_gray)
title('Gray Scaled Image - Original')

subplot(1,4,2)
imshow(picture_neg)
title('Negative')

subplot(1,4,4)
imshow(picture_neg_gray)
title('Negative')

% ------ Diadic Image Operation -----

%read the robot image
robot=imread('robot.jpg');

%map the image to range [0, 1]
robot=im2double(robot);

figure(f8)
subplot(2,4,1)
imshow(robot)
title('Original Robot')

%temporary variable used for translating the robot 
temp=zeros(size(robot));
temp=temp+robot(1,1,:);

%translation of robot
transl_transf=affine2d([1 0 0; 0 1 0; 150 0 1]);
temp(70:end,350+150:560+150,:)=imwarp(robot(70:end,350:560,:),transl_transf);
robot=temp;

%projective transformation
rotate_transf_robot=projective2d([1 0 -0.0001; 0 1 0.00005; 0 0 1.3]);
robot=imwarp(robot, rotate_transf_robot, 'FillValues', reshape(robot(1,1,:),[1 3]));

%resize the image
robot=imresize([zeros(30,578,3)+robot(1,1,:); robot], [1200 800]);

subplot(2,4,2)
imshow(robot)
title('After Preprocessing')

%RGB to gray conversion
gray_robot=rgb2gray(robot);

subplot(2,4,3)
imshow(gray_robot)
title('Grayscale Robot')

%dims
s=size(gray_robot);

%mask creation
mask=gray_robot;


for j=1:s(1)
    for k=1:s(2)
        if ((gray_robot(j,k)<=(0.47)) && (gray_robot(j,k)>=(0.4)))
           mask(j,k)=0;
        else
           mask(j,k)=1;
        end
    end
end

mask(:,:,2)=mask;
mask(:,:,3)=mask(:,:,1);

subplot(2,4,3)
imshow(mask)
title('Mask')

%creation of robot with black background
robot_black_bg=(robot.*mask);

subplot(2,4,4)
imshow(robot_black_bg)
title('Robot with Black Background')

%negative of mask
maskforImg=1-mask;

subplot(2,4,5)
imshow(mypicture)
title('Original Picture')

subplot(2,4,6)
imshow(maskforImg)
title('Negative of Mask')

%Mask imprinting on the picture
imgWithMask=mypicture.*maskforImg;

subplot(2,4,7)
imshow(imgWithMask)
title('Mask on Picture')

%Finalizing image
finalImg=imgWithMask+robot_black_bg;

subplot(2,4,8)
imshow(finalImg)
title('Final Image')