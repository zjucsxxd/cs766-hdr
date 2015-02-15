%% Load exposure time
expTimes = 1 ./ load('TestImages/Test1-ExpTime.txt');
B = log(expTimes);
%% Load images
imgFiles = {'TestImages/Test1-1.jpg', 'TestImages/Test1-2.jpg', 'TestImages/Test1-3.jpg', 'TestImages/Test1-4.jpg', 'TestImages/Test1-5.jpg'};
imgs = loadImages(imgFiles);
gImgs(:,:,:) = imgs(:,:,2,:);
%% Sample pixels
imgNum = size(imgs,4);
height = size(imgs,1);
width = size(imgs,2);
smpNumSqrt = round(sqrt(5*256/(imgNum - 1)));
smpNum = smpNumSqrt*smpNumSqrt;
k = 1;
Z = zeros(smpNum,imgNum);
for i=1:smpNumSqrt
   for j=1:smpNumSqrt
       y = round(i*height/(smpNumSqrt+1));
       x = round(j*width/(smpNumSqrt+1));
       Z(k,:) = gImgs(y,x,:);
       k = k+1;
   end
end
%% Construct weighting function
w = zeros(256,1);
for i=1:128
    w(i) = i - 1;
end
for i=129:256
    w(i) = 256 - i;
end
%% Assign lamda value
l = 20;
%% Solve for g and lE
[g,lE] = gSolve(Z,B,l,w);
%% Plot results
pxVals = zeros(smpNum*imgNum,1);
lgExps = zeros(length(pxVals),1);
k = 1;
for i=1:smpNum
    for j=1:imgNum
        pxVals(k) = Z(i,j);
        lgExps(k) = B(j) + lE(i);
        k = k+1;
    end
end
figure;
hold on;
scatter(lgExps,pxVals,12,[0.6 0.6 1]);
plot(g,1:256,'r');
xlim([-8 8]);
ylim([0 255]);
xlabel('log exposure X');
ylabel('pixel value Z');