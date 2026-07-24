% 이미지가 저장된 폴더 경로
image_folder = 'C:/Users/PC00/Desktop/score/metrics/origtestresult/test2';

% 이미지 불러오기
MSR = imread(fullfile(image_folder, 'aMSR2.png'));
DCT = imread(fullfile(image_folder, 'DCT2.jpg'));
EF = imread(fullfile(image_folder, 'EF2.png'));
FMMR = imread(fullfile(image_folder, 'FMMR2.jpg'));
GRW = imread(fullfile(image_folder, 'GRW2.jpg'));
KIIT = imread(fullfile(image_folder, 'KIIT.png'));


A = rgb2gray(MSR); % 이미지를 그레이스케일로 변환
metric_cpbd = CPBD_compute(A); % CPBD 메트릭 계산
disp(metric_cpbd); % 결과 출력
