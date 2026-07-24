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

% 결과를 저장할 엑셀 파일 이름 설정
output_excel_file = 'JNBM_Scores.xlsx';

% JNBM 계산
metric_jnbm = zeros(1, numel(filtered_files)); % JNBM 결과를 저장할 배열

disp('Starting JNBM metric computation...');

for i = 1:numel(filtered_files)
    % 이미지 읽기
    image_file_path = fullfile(image_path, filtered_files(i).name);
    try
        A = imread(image_file_path);
    catch
        warning(['Unable to read file: ', filtered_files(i).name, '. Skipping...']);
        continue;
    end
    
    % 이미지를 흑백으로 변환
    if size(A, 3) == 3
        A = rgb2gray(A);
    end
    
    % JNBM 계산
    metric_jnbm(i) = JNBM_compute(A);
    
    disp(['Processed: ', filtered_files(i).name, ' | JNBM Score: ', num2str(metric_jnbm(i))]);
end

disp('JNBM metric computation complete.');

% 결과 저장
output_data = cell(numel(filtered_files) + 1, 2);
output_data{1, 1} = 'Image Name';
output_data{1, 2} = 'JNBM Score';

for i = 1:numel(filtered_files)
    output_data{i + 1, 1} = filtered_files(i).name; % 이미지 이름
    output_data{i + 1, 2} = metric_jnbm(i);        % JNBM 점수
end

% 엑셀 파일로 저장
try
    writecell(output_data, output_excel_file);
    disp(['Results saved to: ', output_excel_file]);
catch
    error('Failed to save results to Excel file. Ensure the file is not open in another program.');
end
