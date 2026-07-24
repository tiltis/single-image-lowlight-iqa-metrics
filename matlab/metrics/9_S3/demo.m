img = imread('C:/Users/PC00/Desktop/score/metrics/DCT.jpg');
gray = rgb2gray(img);
[s_map1 s_map2 s3] = s3_map(double(gray),0);

s3_score = mean(s3(:));

disp(s3_score);