% MATLAB 실행

% 현재 디렉토리를 s3_map.m 파일이 있는 위치로 변경
image_folder = 'C:/Users/PC00/Desktop/score/metrics/9_S3';

% 이미지를 불러오고 그레이스케일로 변환한 후 double 형식으로 변환
image_folder = 'C:/Users/PC00/Desktop/score/metrics/resultimg/test1';
img = imread(fullfile(image_folder, 'MSR.png'));


% img = imread('MSR.png');       % 이미지 불러오기
img = rgb2gray(img);             % 그레이스케일로 변환
img = double(img);               % double 형식으로 변환

% s3_map 함수 실행
[s_map1, s_map2, s3] = s3_map(img, 1);  % show_res를 1로 설정하여 결과 표시

% 결과 확인
imshow(s3, []);  % 최종 sharpness map을 표시
