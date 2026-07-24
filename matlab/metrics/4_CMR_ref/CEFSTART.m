% 작업 경로 설정
cd('C:/Users/PC00/Desktop/score/metrics/4_CMR'); % 실제 경로로 교체하세요

% 이미지가 저장된 폴더 경로
image_folder = 'C:/Users/PC00/Desktop/score/metrics/resultimg/test1';

% 이미지 불러오기
test_image = imread(fullfile(image_folder, 'test_image.png'));
original_image = imread(fullfile(image_folder, 'original_image.png'));

% 이미지는 컬러 이미지여야 함
if size(test_image, 3) ~= 3
    error('Test image는 컬러 이미지여야 합니다.');
end
if size(original_image, 3) ~= 3
    error('Original image는 컬러 이미지여야 합니다.');
end

% CEF 함수 실행
CEFscore = CEF(test_image, original_image);

% 결과 출력
disp(['CEF 점수: ', num2str(CEFscore)]);
