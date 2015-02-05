%
% radiance.m
% 
% Arguments:
%
% Z(y,x,j)
% B(j)
% g(z)
% w(z)
%
function [E] = radiance(Z,B,g,w)
%% Read image information
height = size(Z,1);
width = size(Z,2);
imgNum = size(Z,3);
%% Construct radiance map
E = zeros(height,width);
for y=1:height
    for x=1:width
        rSum = 0;
        wSum = 0;
        for j=1:imgNum
            z = Z(y,x,j)+1;
            rSum = rSum+w(z)*(g(z)-B(j));
            wSum = wSum+w(z);
        end
        E(y,x) = exp(rSum/wSum);
    end
end
end

