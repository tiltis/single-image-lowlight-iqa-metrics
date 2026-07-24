
% %1. Load the image, for example
%     image        = imread('img.bmp');
%     
% %2. Call this function to calculate the quality score:
%     qualityscore = SSEQ(image)




%% folder 이름 읽어오기
clc;
clear;

fake_cyclegan_unpaired_list = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230501\20 images (최종본)\unpaired_cyclegan_selected_roi\*.png');

fake_pix2pix_list = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230501\20 images (최종본)\pix2pix_selected_roi\*.png');

fake_todaygan_day_list = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230501\20 images (최종본)\todaygan_selected_roi\*.png');

fake_slat_day_list_1 = dir('E:\GAN\CycleGAN\thesis_result\thesis_result_final_230501\20 images (최종본)\slat_both_stevens_final_selected_roi\*.png');

fake_slat_day_list = fake_pix2pix_list;

%% score 저장 

list_slat_range = size(fake_slat_day_list);
list_slat_range = list_slat_range(:,1);

%% SSEQ
% Output: A quality score of the image. The score typically has a value between 0 and 100 (0 represents the best quality, 100 the worst).

sseq_score_list = [];
for i = 1:list_slat_range
    file_name = strcat(fake_slat_day_list(i).folder,'\', fake_slat_day_list(i).name);
    img = imread(file_name);
    sseq_score = SSEQ(img);
    sseq_score_list = [sseq_score_list, sseq_score];
end

sseq_avg_score = sum(sseq_score_list) ./ list_slat_range