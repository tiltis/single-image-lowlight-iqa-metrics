%==========================================================================
% J. Yan, J. Li, X. Fu, "No-Reference Quality Assessment of Contrast-Distorted Images using Contrast Enhancement"
% 
% Please try your own contrast distorted images with different levels.
% Larger predicted score means better contrast quality.
%==========================================================================

clear;
clc;

% addpath('utils', 'data', 'images');
% 
% im0 = imread('C:\Users\HERO\Downloads\CEIQ-master\images\1.png');
% im1 = imread('C:\Users\HERO\Downloads\CEIQ-master\images\2.png');
% im2 = imread('C:\Users\HERO\Downloads\CEIQ-master\images\3.png');
% 
% pred(1) = CEIQ(im0);
% pred(2) = CEIQ(im1);
% pred(3) = CEIQ(im2);
% 
% pred

%% folder 이름 읽어오기
clc;
clear;

fake_cyclegan_unpaired_list = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230424\crop_image\unpaired_cyclegan_crop_selected\*.png');

fake_pix2pix_list = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230424\crop_image\pix2pix_crop_selected\*.png');

fake_todaygan_day_list = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230424\crop_image\todaygan_resize_crop_selected\*.png');

fake_todaygan_day_stevens_list = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230424\crop_image\todaygan_resize_crop_stevens_selected\*.png');

fake_slat_day_list_no_stevens = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230424\crop_image\slat_day_selected_crop\*.png');

fake_slat_day_list_1 = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230424\crop_image\slat_day_stevens_crop_selected\*.png');

list_rgb_base_detail_input = dir('D:\sanddust\동민\RGB_LAB_train_FIX_Results_231212\Final_result_base_detail_synthesis_231206\bilateral_FINAL_FIX\*.png');
% N_rgb_base_detail = size(list_rgb_base_detail_input, 1);

fake_slat_day_list = list_rgb_base_detail_input;


%% score 저장 

list_slat_range = size(fake_slat_day_list);
list_slat_range = list_slat_range(:,1);

%% CEIQ
% Larger predicted score means better contrast quality.

ceiq_score_list = [];
for i = 1:list_slat_range
    file_name = strcat(fake_slat_day_list(i).folder,'\', fake_slat_day_list(i).name);
    img = imread(file_name);
    ceiq_score = CEIQ(img);
    ceiq_score_list = [ceiq_score_list, ceiq_score];
end

ceiq_avg_score = sum(ceiq_score_list) ./ list_slat_range