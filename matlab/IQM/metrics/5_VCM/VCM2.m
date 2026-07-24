
% Visual Contrast Measure (VCM)
function [vcm] = VCM2(orimg,cimg,refMean,refStd,xpixel,ypixel)

% orimg   : 원본 이미지
% cimg    : 비교 이미지, 원본 이미지와 비교 이미지의 크기는 동일한것을 사용.

% refMean : vcm 검출 시 제외 시키고자하는 영역의 평균 밝기
%           밝기가 어두운 영역은 retinex와 같은 영상 처리 이후 노이즈가 증가하는데
%           여기서 밝생한 노이즈가 vcm 값을 증가 시키게된다. 따라서 영상의 공간을 나눌때
%           평균 밝기가 refMean 이하의 블럭(영역)은 제외 시킨다.

% refStd : VCM 검출에 사용되는 표준편차값 refStd 이상의 값이 많을 수록 contrast 가 
%          좋은 영상!!

% xpixel, ypixel : vcm 에서 사용되는 영역의 크기를 나타낸다.

% vcm 은 로컬 영역의 표준편차를 이용하여 contrast를 비교하기 때문에 RGB 영상은
% gray 영상으로 변환해서 사용한다.

if ~(size(orimg,3)==1 && size(orimg,3)==1)
    % error('gray 이미지 또는 luminance 이미지로 변환이 필요합니다.')
    
    orimg = rgb2gray(orimg);
    cimg = rgb2gray(cimg);
end

if ~isequal(class(orimg),'double')
    orimg = double(orimg);
end

if ~isequal(class(cimg),'double')
    cimg = double(cimg);
end

if nargin < 3
    refMean = 0;
    refStd = [];
    xpixel = 50;
    ypixel = 50;
end



sizeimg = size(orimg);
ydiv = fix( sizeimg(1) / ypixel );
xdiv = fix( sizeimg(2) / xpixel );

meanAreaOri=zeros(sizeimg);
stdAreaOri=zeros(sizeimg);
stdAreaCom=zeros(sizeimg);

for i=1:xdiv
    for j=1:ydiv
        tempOri=orimg( ypixel*(j-1)+1 : ypixel*j  , xpixel*(i-1)+1 : xpixel*i ,1);
        tempCom=cimg( ypixel*(j-1)+1 : ypixel*j  , xpixel*(i-1)+1 : xpixel*i ,1);
        
        % 원본 이미지의 각 영역 별 평균값을 저장
        meanAreaOri(j,i) = mean(mean(tempOri));
        % 원본 이미지의 각 영역 별 표준편차값을 저장
        stdAreaOri(j,i) = std(tempOri(:));
        % 비교 이미지의 각 영역 별 표준편차값을 저장        
        stdAreaCom(j,i) = std(tempCom(:));
    end
end

clear tempOri, clear tmeCom

% 원본 이미지에서 refMean 이상의 영역의 위치를 찾아낸다. (어두운 영역은 제외시키기위해서)
selectedAreaPosition = find(meanAreaOri > refMean);
% 원본 이미지에서 선택된 영역의 표준편차 값을 구한다.
selectedAreaOri = stdAreaOri(selectedAreaPosition);

if isempty(refStd) == 1
    refStd = std(selectedAreaOri(:));
end

% 비교 이미지에서 refStd 이상의 값을 가지는 영역을 찾는다.
vcmArea = find(stdAreaCom(selectedAreaPosition) > 0.01*refStd);

Rv = size(vcmArea,1);
Rt = size(selectedAreaPosition,1);

vcm = 100 * ( Rv / Rt );







