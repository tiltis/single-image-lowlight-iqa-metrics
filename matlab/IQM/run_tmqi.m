% 경로 설정
hdr_folder = 'C:\opencv\4mon\original\';
ldr_folder = 'C:\opencv\4mon\score\';
save_folder = 'C:\opencv\4mon\scoreimg\';  % 결과 저장할 폴더

% 평가할 방법 리스트
methods = {'Jins', 'MSR', 'OpenCV', 'Yujung'};

% 이미지 개수
num_images = 36;

% 결과 저장 배열 초기화
tmqi_scores = zeros(num_images, length(methods));
structural_scores = zeros(num_images, length(methods));
naturalness_scores = zeros(num_images, length(methods));

% 메인 루프
for i = 1:num_images
    % HDR 파일 경로
    hdr_filename = sprintf('original (%d).jpg', i);
    hdr_path = fullfile(hdr_folder, hdr_filename);
    
    % HDR 이미지 읽기
    hdr_img = im2double(imread(hdr_path)); 
    
    for j = 1:length(methods)
        method = methods{j};
        
        % LDR 파일 경로
        ldr_filename = sprintf('%s (%d).jpg', method, i);
        ldr_path = fullfile(ldr_folder, ldr_filename);
        
        % LDR 이미지 읽기
        ldr_img = im2double(imread(ldr_path));
        
        % TMQI 계산
        [Q, S, N, ~, ~] = TMQI(hdr_img, ldr_img);
        
        % 결과 저장
        tmqi_scores(i, j) = Q;
        structural_scores(i, j) = S;
        naturalness_scores(i, j) = N;
        
        % 현재 진행 상황 출력
        fprintf('Image (%d) - %s: TMQI = %.4f, S = %.4f, N = %.4f\n', i, method, Q, S, N);
    end
end

% 결과 테이블 생성
image_ids = (1:num_images)';  % (1) ~ (36)
T = table(image_ids, ...
    tmqi_scores(:,1), tmqi_scores(:,2), tmqi_scores(:,3), tmqi_scores(:,4), ...
    structural_scores(:,1), structural_scores(:,2), structural_scores(:,3), structural_scores(:,4), ...
    naturalness_scores(:,1), naturalness_scores(:,2), naturalness_scores(:,3), naturalness_scores(:,4), ...
    'VariableNames', {'Image', ...
    'TMQI_Jins', 'TMQI_MSR', 'TMQI_OpenCV', 'TMQI_Yujung', ...
    'S_Jins', 'S_MSR', 'S_OpenCV', 'S_Yujung', ...
    'N_Jins', 'N_MSR', 'N_OpenCV', 'N_Yujung'});

% 저장 경로와 파일명 지정
save_path = fullfile(save_folder, 'tmqi_all_results.xlsx');

% 결과를 엑셀 파일로 저장
writetable(T, save_path);

fprintf('\n모든 평가 완료! 결과는 %s에 저장되었습니다.\n', save_path);
