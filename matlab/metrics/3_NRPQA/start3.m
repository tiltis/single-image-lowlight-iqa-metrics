% 작업 경로 설정
cd('C:/Users/PC00/Desktop/score/metrics/3_NRPQA'); % 실제 경로로 교체하세요

% 이미지가 저장된 폴더 경로
image_folder = 'C:/Users/PC00/Desktop/score/metrics/origtestresult/MITM';

% 파일 리스트 가져오기 (MITM으로 시작하는 jpg 파일들)
file_list = dir(fullfile(image_folder, 'MITM*.jpg'));

% 결과 저장을 위한 배열 초기화
results = zeros(length(file_list), 1);

% 파일을 하나씩 읽어서 처리
for i = 1:length(file_list)
    % 파일명 생성
    file_name = fullfile(image_folder, file_list(i).name);
    
    % 이미지 읽기
    img = imread(file_name);
    
    % 그레이스케일 변환 (이미지가 RGB인 경우에만)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    
    % jpeg_quality_score 함수 실행
    score = jpeg_quality_score(img);
    
    % 결과 저장
    results(i) = score;
    
    % 결과 출력
    fprintf('File: %s, Quality Score: %f\n', file_list(i).name, score);
end

% 전체 결과 출력
disp('Quality Scores for all images:');
disp(results);
