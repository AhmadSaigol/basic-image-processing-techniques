clear

%Figures
f1 = figure;
f2 = figure;
f3 = figure;

%% -------- Input -------

disp('Template Matching')

disp('Which function would you like to use? ')
lib = input('I for Image Processing Toolbox, C for custom function (in single quotes) ');

%Image Processing Toolbox function
if lib == 'I'
    disp('Zero mean Normalized Cross Correlation will be used as Similarity Measure')
    SM = 'Z';

%Custom function
elseif lib == 'C'
    disp('Which Similarity Measure do you want to use? ')
    SM = input('N for Normalized Cross Correlation and Z for Zero Mean Normalized Cross Correlation (in single quotes): ');
    
    %error check
    if SM ~= 'N' && SM ~= 'Z'
        error('Invalid Value. Enter N or Z only (in capital, in single quotes)')
        
    end
    
else
    
    %error chekc
    error('Invalid Value. Enter I or C only (in capital, in single quotes)')

end

%% ------- Main loop ------

for k = 1 : 3
    
    %Case 1: Template from and Search on the same image of human
    if k == 1
        
        % read images, convert it to grayscale and map it to [0, 1]
        Image = im2double( rgb2gray( imread('Picture.jpg')));
        
        %Templates
        EyeLeft = Image( 540:665, 650:850);
        EarLeft = Image( 600:833, 540:647);
        Nose = Image( 560:800, 780:912);
        
        %for custom function, scale down the image by a factor of 5 and
        %find corresponding templates
        if lib == 'C'
            
            T = affine2d([1/5 0 0;0 1/5 0; 0 0 1]);
            
            Image = imwarp(Image, T);
            
            %Templates
            EyeLeft = Image(108:133,130:170);
            EarLeft = Image(120:166, 108:129);
            Nose = Image(112:160, 156:182);          

        end
        
        % Transformation for reflection of features
        T= affine2d([-1 0 0; 0 1 0; 0 0 1]);
        
        %Templates
        EyeRight = imwarp(EyeLeft, T);
        EarRight = imwarp(EarLeft,T);
        
        Features = {EarLeft, EyeLeft, Nose, EyeRight, EarRight};
        Names = ["Left Ear", "Left Eye", "Nose", "Right Eye", "Right Ear"];
    end
    
    %Case 2: Search for SMME, RD, and ET
    if k == 2
        
        % read images, convert it to grayscale and map it to [0, 1]
        Image = im2double( rgb2gray( imread('Sample.jpg')));
        SMME = im2double( rgb2gray( imread('SMME.jpg')));
        RD = im2double( rgb2gray( imread('RD.jpg')));
        ET = im2double( rgb2gray( imread('ET.jpg')));
        
        %for custom function, scale down the images by a factor of 6 
        if lib == 'C'
            
            T = affine2d([1/6 0 0;0 1/6 0; 0 0 1]);
            
            Image = imwarp(Image, T);
            SMME = imwarp(SMME, T);
            RD = imwarp(RD, T);
            ET = imwarp(ET, T);
            
        end
        
        %Transformation for scaling templates
        T = affine2d([2.1 0 0;0 2.1 0; 0 0 1]);
        
        %Templates
        SMME = imwarp(SMME, T, 'FillValues', SMME(1,1));
        RD = imwarp(RD, T, 'FillValues', RD(1,1));
        
        Features = {SMME, RD, ET};
        Names = ["SMME", "RoboDog", "Eiffel Tower"];
    end
    
    %Case 3: Templates from one image and Search on another image of human
    if k == 3
        
        % read images, convert it to grayscale and map it to [0,1]
        Image = im2double(rgb2gray(imread('SearchImg.jpg')));
        
        %for custom function, scale down the images by a factor of 5 
        if lib == 'C'
            
            T = affine2d([1/5 0 0;0 1/5 0; 0 0 1]);   
            Image = imwarp(Image, T);
            
        end
        
        %Transformations for scaling templates
        T = affine2d([1.5 0 0; 0 1.12 0; 0 0 1]);
        
        %Template
        Nose= imwarp(Nose, T);
        Features = {EarLeft, EyeLeft, Nose, EyeRight, EarRight};
        Names = ["Left Ear", "Left Eye", "Nose", "Right Eye", "Right Ear"];
        
    end
    
    % different colors for bounding boxes
    Color = ['y','r','g','b','k'];
    
    noOfTemp = size(Names);
    
    %Show Image for Searching
    figure(f1);
    imshow(Image);
    
    for i = 1:noOfTemp(2)
        
        %Plot Template
        figure(f2);
        subplot(1,noOfTemp(2), i)
        imshow(Features{i})
        title(Names(i))
        
        %Find Similarity Matrix
        if lib == 'I'
            score = normxcorr2(Features{i}, Image);
        else
            score = mycustomfnt(Features{i}, Image, SM);
        end
        
        %Plot Similarity Measure
        figure(f3);
        subplot(1,noOfTemp(2),i)
        imshow(score)
        title(Names(i))
        
        %Find cordinates with max value
        [y,x] = find( score == max (score(:)));
        
        %Removing Zero padding
        y = y - size( Features{i}, 1);
        x = x - size( Features{i}, 2);
        
        % draw bounding boxes
        figure(f1);
        drawrectangle(gca,'Position', [x,y,size(Features{i},2), size(Features{i},1)], 'Color', Color(i), 'FaceAlpha', 0);
        
    end
    
    % save figures
    saveas(f1,['fig1_Case ', num2str(k),'_','lib_', lib, '_', 'SM_', SM,'.jpg']);
    saveas(f2,['fig2_Case ', num2str(k),'_','lib_', lib, '_', 'SM_', SM,'.jpg']);
    saveas(f3,['fig3_Case ', num2str(k),'_','lib_', lib, '_', 'SM_', SM,'.jpg']);
end


%% ------- My Custom Function ------

function new_img = mycustomfnt (temp, img, sm)

%zero centering for ZNCC
if sm == 'Z'
    T = temp - mean( temp(:));
else
    T = temp;
end

%store size of template and image
temp_size = size(temp);
img_size = size(img);

%calculate size of new image
new_img_size = [temp_size(1)+img_size(1)-1, temp_size(2) + img_size(2)-1];

%create new image of zeros
new_img = zeros(new_img_size);

%apply zero padding
Img = zeros(new_img_size+temp_size-1);
Img(temp_size(1):new_img_size(1), temp_size(2):new_img_size(2))=img;

%NCC/ZNCC
for i = 1:new_img_size(1)
    
    for j = 1:new_img_size(2)
        
        %extract part of image
        p = Img(i:i+temp_size(1)-1, j:j+temp_size(2)-1);
        
        %zero center for ZNCC
        if sm == 'Z'
            P = p - mean(p(:));
        else
            P = p;
        end
        
        %find cross correlation coefficients
        C = P.*T;
        new_img(i,j) = sum(C(:)) / ((sum(P(:).^2)) * (sum(T(:).^2))) .^0.5;
    end
end
end
