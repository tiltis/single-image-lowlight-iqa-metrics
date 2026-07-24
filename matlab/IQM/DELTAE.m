% 경로 설정
hdr_folder = 'C:\opencv\4mon\original\';  % 원본 이미지 폴더
ldr_folder = 'C:\opencv\4mon\score\';      % 개선 이미지 폴더
save_folder = 'C:\opencv\4mon\scoreimg\';  % 결과 저장 폴더

% 평가할 방법 리스트
methods = {'Jins', 'MSR', 'OpenCV', 'Yujung'};

% 이미지 개수
num_images = 36;

% 결과 저장용
deltaE_mean = zeros(num_images, length(methods));

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

        % ΔE 계산
        deltaE_map = sqrt( (hdr_lab(:,:,1) - ldr_lab(:,:,1)).^2 + ...
                           (hdr_lab(:,:,2) - ldr_lab(:,:,2)).^2 + ...
                           (hdr_lab(:,:,3) - ldr_lab(:,:,3)).^2 );

        % ΔE 평균 저장
        deltaE_mean(i,j) = mean(deltaE_map(:));
    end
end

% 결과 테이블 만들기
image_ids = (1:num_images)';
T = table(image_ids, ...
    deltaE_mean(:,1), deltaE_mean(:,2), deltaE_mean(:,3), deltaE_mean(:,4), ...
    'VariableNames', {'Image', 'DeltaE_Jins', 'DeltaE_MSR', 'DeltaE_OpenCV', 'DeltaE_Yujung'});

% 저장 경로 지정
save_path = fullfile(save_folder, 'deltaE_results.xlsx');

% 엑셀로 저장
writetable(T, save_path);

fprintf('\n모든 ΔE 계산 완료! 결과는 %s 에 저장되었습니다.\n', save_path);
