%[filename, pathname] = uigetfile ({'*.jpg'},'Pick a Image file','MultiSelect','on');

%refFileName_1 = 'C:\Users\D M SON\Desktop\hdrvdp-2.2.1\hdrvdp-2.2.1\test_images\I1_1_RGB.jpg';
%refFileName_2 = 'C:\Users\D M SON\Desktop\hdrvdp-2.2.1\hdrvdp-2.2.1\test_images\I1_2_NIR.jpg';

%refFileName_1 = 'C:\Users\D M SON\Desktop\hdrvdp-2.2.1\hdrvdp-2.2.1\test_images\I2_1_RGB.jpg';
%refFileName_2 = 'C:\Users\D M SON\Desktop\hdrvdp-2.2.1\hdrvdp-2.2.1\test_images\I2_2_NIR.jpg';

%refFileName_1 = 'C:\Users\D M SON\Desktop\hdrvdp-2.2.1\hdrvdp-2.2.1\test_images\I10_1_RGB.jpg';
%refFileName_2 = 'C:\Users\D M SON\Desktop\hdrvdp-2.2.1\hdrvdp-2.2.1\test_images\I10_2_NIR.jpg';

%refFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I3_1_RGB.jpg';
%refFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\I3_2_NIR.jpg';

%refFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\\I9_1_RGB.jpg';
%refFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\\I9_2_NIR.jpg';

refFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\\I6_1_RGB.jpg';
refFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\\I6_2_NIR.jpg';

%refFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\\I4_1_RGB.jpg';
%refFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\\I4_2_NIR.jpg';




%testFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I1_10_Our_results_with_CSC.jpg';
%testFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\daytime, result_0113(11x11)_8.jpg';

%testFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I2_10_Our_results_with_CSC.jpg';
%testFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\daytime, result_0113(11x11)_3.jpg';

%testFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I10_10_Our_results_with_CSC.jpg';
%testFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\daytime, result_0113(11x11)_4.jpg';

%testFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I3_10_Our_results_with_CSC.jpg';
%testFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\daytime, result_0113(11x11)_7.jpg';

%testFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I9_10_Our_results_with_CSC.jpg';
%testFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\daytime, result_0113(11x11)_6.jpg';

testFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I6_10_Our_results_with_CSC.jpg';
testFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\daytime, result_0113(11x11)_2.jpg';

%testFileName_1 = 'C:\Users\D M SON\Desktop\IQM\test_images\I4_10_Our_results_with_CSC.jpg';
%testFileName_2 = 'C:\Users\D M SON\Desktop\IQM\test_images\daytime, result_0113(11x11)_5.jpg';

ref_img_1=double(imread(refFileName_1))/255;
ref_img_2=double(imread(refFileName_2))/255;

test_img_1=double(imread(testFileName_1))/255;
test_img_2=double(imread(testFileName_2))/255;


figure(); imshow(test_img_1);
figure(); imshow(test_img_2);

%img1 = test_img_1;
%img2 = test_img_2;

%luminance_1 = img1(:,:,1) * 0.212656 + img1(:,:,2) * 0.715158 + img1(:,:,3) * 0.072186;
%luminance_2 = img2(:,:,1) * 0.212656 + img2(:,:,2) * 0.715158 + img2(:,:,3) * 0.072186;



%jpeg_quality_van = jpeg_quality_score(test_img_1)
%jpeg_quality_prop = jpeg_quality_score(test_img_2)

%fmi_van = fmi(ref_img_1, ref_img_2, test_img_1, 'none', 3)
%fmi_prop = fmi(ref_img_1, ref_img_2, test_img_2, 'none', 3)

%[Q1, S1, N1, s_maps_1, s_local_1] = TMQI(test_img_1, ref_img_1);
%[Q2, S2, N2, s_maps_2, s_local_2] = TMQI(test_img_2, ref_img_1);

van = imread(testFileName_1);
prop = imread(testFileName_2);
van = rgb2gray(van);
prop = rgb2gray(prop);

% CPBD_van = CPBD_compute(van)
% CPBD_prop = CPBD_compute(prop)
% 
% JNBM_van = JNBM_compute(van)
% JNBM_prop = JNBM_compute(prop)
% 
% [lpc_si1 lpc_map1] = lpc_si(van);
% [lpc_si2 lpc_map2] = lpc_si(prop);

[s_map1_1 s_map2_1 s3_1] = s3_map(double(van),1);
s3_score1 = mean(s3_1(:))
[s_map1_2 s_map2_2 s3_2] = s3_map(double(prop),1);
s3_score2 = mean(s3_2(:))

