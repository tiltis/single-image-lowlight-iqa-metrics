visible = imread('C:/Users/D M SON/Documents/photos/result/20/NIR sharpness/vis_20_trim.jpg');
nir = imread('C:/Users/D M SON/Documents/photos/result/20/NIR sharpness/nir_20_trim_sharp.jpg');
nir = gray2rgb(nir);

proposed_result = imread('C:/Users/D M SON/Documents/photos/result/20/NIR sharpness/Blending_radiance_result_20_nir.jpg');
vanmali_result =  imread('C:/Users/D M SON/Documents/photos/result/20/NIR sharpness/Blending_result_20_vanmali_nir.jpg');

% input_vis = double(imread('C:/Users/D M SON/Documents/photos/result/14/NIR sharpness/vis_14_trim.bmp')) / 255;
input_vis = double(visible)/255;
% input_nir = double(imread('C:/Users/D M SON/Documents/photos/result/14/NIR sharpness/nir_14_trim_sharp.bmp')) / 255;
input_nir = double(nir)/255;

% proposed = double(imread('C:/Users/D M SON/Documents/photos/result/14/NIR sharpness/Blending radiance result_14_nir.bmp')) / 255;
proposed= double(proposed_result)/255;
% vanmali = double(imread('C:/Users/D M SON/Documents/photos/result/14/NIR sharpness/Blending_result_14_vanmali_nir.bmp')) / 255;
vanmali = double(vanmali_result)/255;

% proposed2 = imread('C:/Users/D M SON/Documents/photos/result/14/NIR sharpness/Blending radiance result_14_nir.bmp');
% vanmali2 = imread('C:/Users/D M SON/Documents/photos/result/14/NIR sharpness/Blending_result_14_vanmali_nir.bmp');
proposed_gray = rgb2gray(proposed_result);
vanmali_gray = rgb2gray(vanmali_result);


vanmali_jpeg_score = jpeg_quality_score(vanmali)
proposed_jpeg_score = jpeg_quality_score(proposed)

fmi_van = fmi(input_vis, input_nir, vanmali, 'none', 3)
fmi_prop = fmi(input_vis, input_nir, proposed, 'none', 3)


[s_map1_1 s_map2_1 s3_1] = s3_map(double(vanmali_gray),1);
s3_score1 = mean(s3_1(:))
[s_map1_2 s_map2_2 s3_2] = s3_map(double(proposed_gray),1);
s3_score2 = mean(s3_2(:))