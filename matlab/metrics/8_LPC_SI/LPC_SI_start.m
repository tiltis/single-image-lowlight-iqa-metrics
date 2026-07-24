clc;
clear all;

% 입력 폴더 설정
image_path = 'C:\opencv\4mon\score'; % 입력 폴더 경로
if ~isfolder(image_path)
    error('The specified input folder does not exist. Please check the path.');
end

% 입력 폴더의 모든 파일 가져오기
image_files = dir(fullfile(image_path, '*.*'));
valid_extensions = {'.jpg', '.jpeg'};

% 유효한 확장자를 가진 파일만 필터링
image_files = image_files(~[image_files.isdir]); % 폴더 제외

% 확장자 필터링
filtered_files = [];
for i = 1:length(image_files)
    [~, ~, ext] = fileparts(image_files(i).name);
    if ismember(lower(ext), valid_extensions)
        filtered_files = [filtered_files; image_files(i)];
    end
end

if isempty(filtered_files)
    error('No valid image files found in the input folder. Supported formats: jpg, jpeg, png, bmp, tif, tiff');
end

% 결과를 저장할 엑셀 파일 이름 설정
output_excel_file = 'C:\opencv\4mon\scoreimg\LPC_SI_Scores.xlsx';


% LPC-SI 계산
metric_lpc_si = zeros(1, numel(filtered_files));

disp('Starting LPC-SI metric computation...');

for i = 1:numel(filtered_files)
    image_file_path = fullfile(image_path, filtered_files(i).name);
    try
        A = imread(image_file_path);
    catch
        warning(['Unable to read file: ', filtered_files(i).name, '. Skipping...']);
        continue;
    end
    
    if size(A, 3) == 3
        A = rgb2gray(A);
    end

    lpc_score = lpc_si(A);  % LPC-SI 함수 호출
    metric_lpc_si(i) = lpc_score;
    
    disp(['Processed: ', filtered_files(i).name, ' | LPC-SI Score: ', num2str(lpc_score)]);
end

disp('LPC-SI metric computation complete.');

output_data = cell(numel(filtered_files) + 1, 2);
output_data{1, 1} = 'Image Name';
output_data{1, 2} = 'LPC-SI Score';

for i = 1:numel(filtered_files)
    output_data{i + 1, 1} = filtered_files(i).name;
    output_data{i + 1, 2} = metric_lpc_si(i);
end

try
    writecell(output_data, output_excel_file);
    disp(['Results saved to: ', output_excel_file]);
catch
    error('Failed to save results to Excel file. Ensure the file is not open in another program.');
end
