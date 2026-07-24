% 폴더 경로 설정
base_folder = 'C:/Users/PC00/Desktop/score/metrics/origtestresult/';
num_tests = 12;  % test1부터 test13까지 처리

% 처리할 이미지 파일 이름 리스트 (확장자 무관)
image_files = {'MSR', 'DCT', 'EF', 'FMMR', 'GRW', 'MITM'}; % LE와 HE는 제외

% 엑셀 파일 저장을 위한 변수
excel_file = 'FSIM_Quality_Scores.xlsx';  
header = arrayfun(@num2str, 1:num_tests, 'UniformOutput', false);  % 엑셀 헤더 설정
row_names = {'aMSR', 'DCT', 'EF', 'FMMR', 'GRW', 'MITM'};  % 행 이름 설정

% FSIM 및 FSIMc 값을 저장할 행렬
fsim_scores_le = NaN(length(row_names), num_tests);  
fsim_scores_he = NaN(length(row_names), num_tests);  
fsimc_scores_le = NaN(length(row_names), num_tests);  
fsimc_scores_he = NaN(length(row_names), num_tests);  

% 각 폴더에 대해 FSIM 품질 점수 계산
for i = 1:num_tests
    % 각 test 폴더 경로 설정
    ssim_folder = sprintf('%stest%d/SSIM/', base_folder, i);
    
    % LE 및 HE 이미지 경로 설정
    le_folder = fullfile(ssim_folder, 'LE');
    he_folder = fullfile(ssim_folder, 'HE');
    
    % LE 이미지 불러오기 (예: LE1.png, LE2.png, ..., LE13.png)
    le_img_path = fullfile(le_folder, sprintf('LE%d.png', i));
    le_img = imread(le_img_path);
    
    % LE 폴더 내 각 이미지와 FSIM 비교
    for idx = 1:length(row_names)
        file_pattern = sprintf('%s%d.png', row_names{idx}, i);  % 예: MSR1.png, DCT2.png, ...
        file_path = fullfile(le_folder, file_pattern);
        
        if isfile(file_path)
            img = imread(file_path);
            [fsim, fsimc] = FeatureSIM(le_img, img); % FSIM 및 FSIMc 계산
            fsim_scores_le(idx, i) = fsim;
            fsimc_scores_le(idx, i) = fsimc;
        else
            fprintf('LE 파일 %s를 찾을 수 없습니다.\n', file_pattern);
        end
    end
    
    % HE 이미지 불러오기 (예: HE1.png, HE2.png, ..., HE13.png)
    he_img_path = fullfile(he_folder, sprintf('HE%d.png', i));
    he_img = imread(he_img_path);
    
    % HE 폴더 내 각 이미지와 FSIM 비교
    for idx = 1:length(row_names)
        file_pattern = sprintf('%s%d.png', row_names{idx}, i);  % 예: MSR1.png, DCT2.png, ...
        file_path = fullfile(he_folder, file_pattern);
        
        if isfile(file_path)
            img = imread(file_path);
            [fsim, fsimc] = FeatureSIM(he_img, img); % FSIM 및 FSIMc 계산
            fsim_scores_he(idx, i) = fsim;
            fsimc_scores_he(idx, i) = fsimc;
        else
            fprintf('HE 파일 %s를 찾을 수 없습니다.\n', file_pattern);
        end
    end
end

% 엑셀 파일로 결과 저장
xlswrite(excel_file, [['FSIM(LE)', header]; [row_names', num2cell(fsim_scores_le)]], 'Sheet1', 'A19');  % LE FSIM 결과 엑셀로 내보내기
xlswrite(excel_file, [['FSIM(HE)', header]; [row_names', num2cell(fsim_scores_he)]], 'Sheet1', 'A29');  % HE FSIM 결과 엑셀로 내보내기
xlswrite(excel_file, [['FSIMc(LE)', header]; [row_names', num2cell(fsimc_scores_le)]], 'Sheet1', 'A38');  % LE FSIMc 결과 엑셀로 내보내기
xlswrite(excel_file, [['FSIMc(HE)', header]; [row_names', num2cell(fsimc_scores_he)]], 'Sheet1', 'A48');  % HE FSIMc 결과 엑셀로 내보내기

disp('모든 결과가 엑셀 파일에 저장되었습니다.');
