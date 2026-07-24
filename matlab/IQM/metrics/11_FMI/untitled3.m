% 이미지 불러오기
ima = imread('image1.png');
imb = imread('image2.png');
imf = imread('fused_image.png');

% FMI 계산 (기본 설정)
nfmi = fmi(ima, imb, imf);

% 결과 출력
disp(['Normalized Feature Mutual Information: ', num2str(nfmi)]);
