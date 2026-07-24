% 경로 설정
hdr_folder = 'C:\opencv\4mon\original\';  % 원본 이미지 폴더
ldr_folder = 'C:\opencv\4mon\score\';      % 개선 이미지 폴더
save_folder = 'C:\opencv\4mon\scoreimg\';  % 결과 저장 폴더

% 평가할 방법 리스트
methods = {'Jins', 'MSR', 'OpenCV', 'Yujung'};

% 이미지 개수
num_images = 36;

% 결과 저장용
psnr_a = zeros(num_images, length(methods));
psnr_b = zeros(num_images, length(methods));
psnr_mean = zeros(num_images, length(methods));  % a,b 평균 PSNR

% 메인 루프
for i = 1:num_images
    % 원본 읽기
    hdr_filename = sprintf('original (%d).jpg', i);
    hdr_path = fullfile(hdr_folder, hdr_filename);
    hdr_img = im2double(imread(hdr_path));  % imread + im2double

    % 원본을 LAB 색공간으로 변환
    hdr_lab = rgb2lab(hdr_img);

    for j = 1:length(methods)
        method = methods{j};

        % 개선된 결과 읽기
        ldr_filename = sprintf('%s (%d).jpg', method, i);
        ldr_path = fullfile(ldr_folder, ldr_filename);
        ldr_img = im2double(imread(ldr_path));

        % 결과를 LAB 색공간으로 변환
        ldr_lab = rgb2lab(ldr_img);

        % a*, b* 채널만 추출
        hdr_a = hdr_lab(:,:,2);
        hdr_b = hdr_lab(:,:,3);
        ldr_a = ldr_lab(:,:,2);
        ldr_b = ldr_lab(:,:,3);

        % PSNR 계산 (a*, b* 채널 별로)
        mse_a = mean((hdr_a(:) - ldr_a(:)).^2);
        mse_b = mean((hdr_b(:) - ldr_b(:)).^2);
        MAX_val = 100;  % LAB a*, b* 범위는 대략 -100 ~ +100

        psnr_a(i,j) = 10 * log10(MAX_val^2 / mse_a);
        psnr_b(i,j) = 10 * log10(MAX_val^2 / mse_b);
        psnr_mean(i,j) = mean([psnr_a(i,j), psnr_b(i,j)]);  % a,b 평균
    end
end

% 결과 테이블 만들기
image_ids = (1:num_images)';
T = table(image_ids, ...
    psnr_mean(:,1), psnr_mean(:,2), psnr_mean(:,3), psnr_mean(:,4), ...
    psnr_a(:,1), psnr_a(:,2), psnr_a(:,3), psnr_a(:,4), ...
    psnr_b(:,1), psnr_b(:,2), psnr_b(:,3), psnr_b(:,4), ...
    'VariableNames', {'Image', ...
    'PSNRmean_Jins', 'PSNRmean_MSR', 'PSNRmean_OpenCV', 'PSNRmean_Yujung', ...
    'PSNRa_Jins', 'PSNRa_MSR', 'PSNRa_OpenCV', 'PSNRa_Yujung', ...
    'PSNRb_Jins', 'PSNRb_MSR', 'PSNRb_OpenCV', 'PSNRb_Yujung'});

% 저장 경로 지정
save_path = fullfile(save_folder, 'psnr_ab_results.xlsx');

% 엑셀로 저장
writetable(T, save_path);

fprintf('\n모든 PSNR 계산 완료! 결과는 %s 에 저장되었습니다.\n', save_path);
