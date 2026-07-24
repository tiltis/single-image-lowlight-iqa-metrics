clc;
clear all;

% 입력 폴더 설정
image_path = 'input폴더이름'; % 입력 폴더 경로
if ~isfolder(image_path)
    error('The specified input folder does not exist. Please check the path.');
end

% 입력 폴더의 모든 파일 가져오기
image_files = dir(fullfile(image_path, '*.*'));
valid_extensions = {'.jpg', '.jpeg', '.png', '.bmp', '.tif', '.tiff'};

% 유효한 확장자를 가진 파일만 필터링
image_files = image_files(~[image_files.isdir]); % 폴더 제외

% 확장자 필터링 (파일 이름에서 추출)
filtered_files = [];
for i = 1:length(image_files)
    [~, ~, ext] = fileparts(image_files(i).name); % 파일 이름에서 확장자 추출
    if ismember(lower(ext), valid_extensions) % 확장자 확인
        filtered_files = [filtered_files; image_files(i)];
    end
end

if isempty(filtered_files)
    error('No valid image files found in the input folder. Supported formats: jpg, jpeg, png, bmp, tif, tiff');
end

% SSEQ 점수 계산 결과를 저장할 배열
metric_sseq = zeros(1, numel(filtered_files));

disp('Starting SSEQ metric computation...');

% 각 이미지 파일에 대해 SSEQ 계산
for i = 1:numel(filtered_files)
    % 파일 경로 가져오기
    image_file_path = fullfile(image_path, filtered_files(i).name);

    % 이미지 읽기 및 오류 처리
    try
        img = imread(image_file_path);
    catch
        warning(['Unable to read file: ', filtered_files(i).name, '. Skipping...']);
        metric_sseq(i) = NaN;
        continue;
    end

    % SSEQ 점수 계산
    try
        % SSEQ 함수 호출
        sseq_score = SSEQ(img);
        metric_sseq(i) = sseq_score; % 점수 저장
        fprintf('Processed: %s | SSEQ Score: %.2f\n', filtered_files(i).name, sseq_score);
    catch
        warning(['Error computing SSEQ for file: ', filtered_files(i).name, '. Skipping...']);
        metric_sseq(i) = NaN;
        continue;
    end
end

disp('SSEQ metric computation complete.');

% 결과 저장
output_data = cell(numel(filtered_files) + 1, 2);
output_data{1, 1} = 'Image Name';
output_data{1, 2} = 'SSEQ Score';

for i = 1:numel(filtered_files)
    output_data{i + 1, 1} = filtered_files(i).name; % 이미지 이름
    output_data{i + 1, 2} = metric_sseq(i);         % SSEQ 점수
end

% 엑셀 파일 저장
output_excel_file = 'SSEQ_Scores.xlsx';
try
    writecell(output_data, output_excel_file);
    disp(['Results saved to: ', output_excel_file]);
catch
    error('Failed to save results to Excel file. Ensure the file is not open in another program.');
end
