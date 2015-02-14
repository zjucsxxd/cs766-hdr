% Implementation of Drago et al. tone mapping algorithm!
% Adaptive Logarithmic Mapping For Displaying High Contrast Scenes
% http://pages.cs.wisc.edu/~lizhang/courses/cs766-2012f/projects/hdr/Drago2003ALM.pdf
% BONUS!

% Note: Slower, but vivid recreation

% Input: radMap - the RGB radiance map; b - the bias parameter (0.85 works best typically)
% Output: image - the Low Dynamic Range, toned-mapped RGB image

function [image] = toneMapDrago(radMap, b)
%convert to Yxy color space
% [Yxy, logSum] = RGBtoYxy(radMap);
xyz = rgb2xyz(radMap);

W = sum(xyz,3);
Yxy(:,:,1) = xyz(:,:,2);     % Y
Yxy(:,:,2) = xyz(:,:,1) ./ W;	% x
Yxy(:,:,3) = xyz(:,:,2) ./ W;	% y

N = numel(Yxy(:,:,1));
maxLum = max(max(Yxy(:,:,1)));

logSum = sum(log(reshape(Yxy(:,:,1), [1 N] )));
logAvgLum = logSum / N;

avgLum = exp(logAvgLum);
maxLumW = (maxLum / avgLum);

%replace luminance values
coeff = (100 * 0.01) / log10(maxLumW + 1);
Yxy(:,:,1) = Yxy(:,:,1) ./ avgLum;
Yxy(:,:,1) = ( log(Yxy(:,:,1) + 1) ./ log(2 + bias((Yxy(:,:,1) ./ maxLumW), b) .* 8) ) .* coeff;

% convert back to RGB
newW = Yxy(:,:,1) ./ Yxy(:,:,3);
xyz(:,:,2) = Yxy(:,:,1);
xyz(:,:,1) = newW .* Yxy(:,:,2);
xyz(:,:,3) = newW -xyz(:,:,1) - xyz(:,:,2);
image = xyz2rgb(xyz);

% image = YxytoRGB(Yxy);

% correct gamma
image = fixGamma(image);
end

% Bias power function
function [bT] = bias(t ,b)
bT = t .^ ( log(b) / log(0.5) );
end

% RGB to Yxy
function [Yxy, total] = RGBtoYxy(RGB)
% convert to xyY
Yxy = nan(size(RGB));

% conversion matrix
RGB2Yxy = [ 0.5141364, 0.3238786, 0.16036376; ...
    0.265068, 0.67023428, 0.06409157; ...
    0.0241188, 0.1228178, 0.84442666];
total = 0.0;

for row = 1:size(RGB,1)
    for col = 1:size(RGB,2)
        
        result = zeros(1,3);
        for i = 1:3
            result(i) = result(i) + RGB2Yxy(i,1) * RGB(row,col,1) + ...
                RGB2Yxy(i,2) * RGB(row,col,2) + RGB2Yxy(i,3) * RGB(row,col,3);
        end
        
        W = sum(result);
        if W > 0.0
            Yxy(row,col,1) = result(2);     % Y
            Yxy(row,col,2) = result(1) / W;	% x
            Yxy(row,col,3) = result(2) / W;	% y
        else
            Yxy(row,col,:) = 0;	
        end
        total = total + log(2.3e-5 + Yxy(row,col,1));
    end
end
end

% Yxy to RGB
function [RGB] = YxytoRGB(Yxy)
EPSILON = eps(1); % machine epsilon

% convert to xyY
RGB = nan(size(Yxy));

% conversion matrix
Yxy2RGB = [ 2.5651, -1.1665, -0.3986; ...
    -1.0217, 1.9777, 0.0439; ...
    0.0753, -0.2543, 1.1892];

for row = 1:size(RGB,1)
    for col = 1:size(RGB,2)
        Y = Yxy(row,col,1);
        result(2) = Yxy(row,col,2);
        result(3) = Yxy(row,col,3);
        
        if ((Y > EPSILON) && (result(2) > EPSILON) && (result(3) > EPSILON))
            X = (result(2) * Y) / result(3);
            Z = (X / result(2)) - X - Y;
        else
            X = EPSILON;
            Z = EPSILON;
        end
        RGB(row,col,1) = X;
        RGB(row,col,2) = Y;
        RGB(row,col,3) = Z;
        result = zeros(1,3);
        for i = 1:3
            result(i) = result(i) + Yxy2RGB(i,1) * RGB(row,col,1) + ...
                Yxy2RGB(i,2) * RGB(row,col,2) + Yxy2RGB(i,3) * RGB(row,col,3);
        end
        RGB(row,col,1) = result(1);
        RGB(row,col,2) = result(2);
        RGB(row,col,3) = result(3);
    end
end
end

% fix gamma based on paper method
function [image] = fixGamma(oldImage)
slope = 4.5;
start = 0.018;
gammaval = 2.2; % fix?
fgamma = (0.45/gammaval)*2;

if gammaval >= 2.1
    start = 0.018 / ((gammaval - 2) * 7.5);
    slope = 4.5 * ((gammaval - 2) * 7.5);
elseif gammaval <= 1.9
    start = 0.018 * ((2 - gammaval) * 7.5);
    slope = 4.5 / ((2 - gammaval) * 7.5);
end

image = nan(size(oldImage));

for row = 1:size(oldImage,1)
    for col = 1:size(oldImage,2)
        %red
        if oldImage(row,col,1) <= start
            image(row,col,1) = oldImage(row,col,1) * slope;
        else
            image(row,col,1) = 1.099 * power(oldImage(row,col,1), fgamma) - 0.099;
        end
        
        %green
        if oldImage(row,col,2) <= start
            image(row,col,2) = oldImage(row,col,2) * slope;
        else
            image(row,col,2) = 1.099 * power(oldImage(row,col,2), fgamma) - 0.099;
        end
        
        %blue
        if oldImage(row,col,3) <= start
            image(row,col,3) = oldImage(row,col,3) * slope;
        else
            image(row,col,3) = 1.099 * power(oldImage(row,col,3), fgamma) - 0.099;
        end
        
    end
end
end