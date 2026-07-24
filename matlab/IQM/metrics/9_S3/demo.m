img = imread(' D:\HyukJu\2019\hdr image data set\1_hdr.jpg');
gray = rgb2gray(img);
[s_map1 s_map2 s3] = s3_map(double(gray),1);

s3_score = mean(s3(:));