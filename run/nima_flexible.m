function NIMA_FlexibleScorer()
% 유연한 NIMA 스코어링 시스템
% 하위 폴더가 있으면 폴더별로, 없으면 파일명 기준으로 분류

% 경로 설정
baseInputFolder = 'C:\opencv\5mon\final';
outputFolder = 'C:\opencv\4mon\scoreimg';

% 출력 폴더 생성
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

fprintf('=== NIMA 유연 점수 정리 시스템 ===\n');
fprintf('입력 폴더: %s\n', baseInputFolder);
fprintf('출력 폴더: %s\n\n', outputFolder);

% 폴더 내용 확인
folderContents = dir(baseInputFolder);

% 하위 폴더 찾기
subfolders = {};
for i = 1:length(folderContents)
    if folderContents(i).isdir && ~strcmp(folderContents(i).name, '.') && ~strcmp(folderContents(i).name, '..')
        subfolders{end+1} = folderContents(i).name;
    end
end

% 지원 이미지 형식
imageExts = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff'};

% 결과 저장용
allResults = struct();

if ~isempty(subfolders)
    % === 경우 1: 하위 폴더가 있는 경우 ===
    fprintf('📁 하위 폴더 발견: ');
    for i = 1:length(subfolders)
        fprintf('%s ', subfolders{i});
    end
    fprintf('\n\n');
    
    % 각 하위 폴더 처리
    for folderIdx = 1:length(subfolders)
        folderName = subfolders{folderIdx};
        folderPath = fullfile(baseInputFolder, folderName);
        
        fprintf('📁 처리 중: %s\n', folderName);
        
        % 해당 폴더의 이미지 파일 목록
        imageFiles = getImageFiles(folderPath, imageExts);
        
        if isempty(imageFiles)
            fprintf('  ❌ 이미지 파일 없음\n');
            continue;
        end
        
        % 파일명으로 정렬
        imageFiles = sort(imageFiles);
        fprintf('  📊 총 %d개 이미지 발견\n', length(imageFiles));
        
        % 이미지 처리
        results = processImages(imageFiles);
        allResults.(folderName) = results;
        
        fprintf('  ✅ %s 완료: %d개 이미지\n\n', folderName, length(results));
    end
    
else
    % === 경우 2: 하위 폴더가 없는 경우 - 파일명으로 분류 ===
    fprintf('📁 하위 폴더 없음. 파일명 기준으로 분류합니다.\n\n');
    
    % 모든 이미지 파일 가져오기
    allImageFiles = getImageFiles(baseInputFolder, imageExts);
    
    if isempty(allImageFiles)
        fprintf('❌ 이미지 파일을 찾을 수 없습니다!\n');
        return;
    end
    
    fprintf('📊 총 %d개 이미지 발견\n', length(allImageFiles));
    
    % 파일명 패턴으로 분류
    groups = classifyImagesByFilename(allImageFiles);
    
    % 각 그룹 처리
    groupNames = fieldnames(groups);
    for groupIdx = 1:length(groupNames)
        groupName = groupNames{groupIdx};
        imageFiles = groups.(groupName);
        
        fprintf('📁 그룹 처리 중: %s (%d개 파일)\n', groupName, length(imageFiles));
        
        % 파일명으로 정렬
        imageFiles = sort(imageFiles);
        
        % 이미지 처리
        results = processImages(imageFiles);
        allResults.(groupName) = results;
        
        fprintf('  ✅ %s 완료: %d개 이미지\n\n', groupName, length(results));
    end
end

% 엑셀 파일 생성
createExcelFile(allResults, outputFolder);

end

function imageFiles = getImageFiles(folderPath, imageExts)
% 폴더에서 이미지 파일 목록 가져오기
imageFiles = {};
for extIdx = 1:length(imageExts)
    files = dir(fullfile(folderPath, imageExts{extIdx}));
    for fileIdx = 1:length(files)
        imageFiles{end+1} = fullfile(folderPath, files(fileIdx).name);
    end
end
end

function groups = classifyImagesByFilename(imageFiles)
% 파일명 패턴으로 이미지 분류
groups = struct();

for i = 1:length(imageFiles)
    [~, filename, ~] = fileparts(imageFiles{i});
    
    % 파일명 패턴 분석
    groupName = 'Others'; % 기본 그룹
    
    % 패턴 1: mymy로 시작하는 파일들
    if contains(lower(filename), 'mymy') || startsWith(lower(filename), 'mymy')
        groupName = 'mymy';
    % 패턴 2: msr로 시작하는 파일들  
    elseif contains(lower(filename), 'msr') || startsWith(lower(filename), 'msr')
        groupName = 'msr';
    % 패턴 3: 숫자로 시작하는 파일들
    elseif ~isempty(regexp(filename, '^\d+', 'once'))
        groupName = 'numbered';
    % 패턴 4: 언더스코어로 구분된 첫 번째 부분
    elseif contains(filename, '_')
        parts = split(filename, '_');
        if ~isempty(parts)
            groupName = parts{1};
        end
    % 패턴 5: 첫 3글자로 그룹화
    elseif length(filename) >= 3
        groupName = filename(1:3);
    end
    
    % 그룹에 파일 추가
    if ~isfield(groups, groupName)
        groups.(groupName) = {};
    end
    groups.(groupName){end+1} = imageFiles{i};
end

% 그룹 정보 출력
groupNames = fieldnames(groups);
fprintf('🔍 파일명 분석 결과:\n');
for i = 1:length(groupNames)
    fprintf('  - %s: %d개 파일\n', groupNames{i}, length(groups.(groupNames{i})));
end
fprintf('\n');

end

function results = processImages(imageFiles)
% 이미지 목록 처리
results = struct('filename', {}, 'nima_score', {});

for imgIdx = 1:length(imageFiles)
    [~, filename, ext] = fileparts(imageFiles{imgIdx});
    fullFilename = [filename ext];
    
    fprintf('    처리 중 (%d/%d): %s\n', imgIdx, length(imageFiles), fullFilename);
    
    try
        % 이미지 로드 및 NIMA 점수 계산
        image = imread(imageFiles{imgIdx});
        nimaScore = calculateNIMAScore(image);
        
        % 결과 저장
        results(imgIdx).filename = fullFilename;
        results(imgIdx).nima_score = nimaScore;
        
    catch ME
        fprintf('      ❌ 오류: %s\n', ME.message);
        results(imgIdx).filename = fullFilename;
        results(imgIdx).nima_score = 5.0; % 기본값
    end
end

% 점수 기준으로 내림차순 정렬
if ~isempty(results)
    scores = [results.nima_score];
    [~, sortIdx] = sort(scores, 'descend');
    results = results(sortIdx);
end

end

function createExcelFile(allResults, outputFolder)
% 엑셀 파일 생성
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
excelFilename = sprintf('NIMA_Vertical_Scores_%s.xlsx', timestamp);
excelPath = fullfile(outputFolder, excelFilename);

groupNames = fieldnames(allResults);

% 각 그룹별로 시트 생성
for groupIdx = 1:length(groupNames)
    groupName = groupNames{groupIdx};
    results = allResults.(groupName);
    
    if isempty(results)
        continue;
    end
    
    % 데이터 준비 (세로 형태)
    headers = {'Image', 'NIMA_Score'};
    data = cell(length(results), 2);
    
    for i = 1:length(results)
        data{i, 1} = results(i).filename;
        data{i, 2} = results(i).nima_score;
    end
    
    % 헤더와 데이터 합치기
    fullData = [headers; data];
    
    % 시트명 설정 (MATLAB 시트명 제한 고려)
    sheetName = groupName;
    if length(sheetName) > 31
        sheetName = sheetName(1:31);
    end
    
    try
        xlswrite(excelPath, fullData, sheetName);
        fprintf('✅ 시트 생성: %s (%d개 이미지)\n', sheetName, length(results));
    catch ME
        fprintf('❌ 시트 생성 오류 (%s): %s\n', sheetName, ME.message);
    end
end

% 요약 시트 생성
if ~isempty(groupNames)
    summaryHeaders = {'Group', 'Image_Count', 'Average_Score', 'Max_Score', 'Min_Score', 'Std_Dev'};
    summaryData = cell(length(groupNames), length(summaryHeaders));
    
    for groupIdx = 1:length(groupNames)
        groupName = groupNames{groupIdx};
        results = allResults.(groupName);
        
        if ~isempty(results)
            scores = [results.nima_score];
            summaryData{groupIdx, 1} = groupName;
            summaryData{groupIdx, 2} = length(results);
            summaryData{groupIdx, 3} = mean(scores);
            summaryData{groupIdx, 4} = max(scores);
            summaryData{groupIdx, 5} = min(scores);
            summaryData{groupIdx, 6} = std(scores);
        end
    end
    
    summaryFull = [summaryHeaders; summaryData];
    
    try
        xlswrite(excelPath, summaryFull, 'Summary');
        fprintf('✅ 요약 시트 생성 완료\n');
    catch ME
        fprintf('❌ 요약 시트 오류: %s\n', ME.message);
    end
end

% 전체 데이터 통합 시트 생성
try
    allHeaders = {'Group', 'Image', 'NIMA_Score'};
    allData = {};
    
    for groupIdx = 1:length(groupNames)
        groupName = groupNames{groupIdx};
        results = allResults.(groupName);
        
        for i = 1:length(results)
            allData{end+1, 1} = groupName;
            allData{end+1, 2} = results(i).filename;
            allData{end+1, 3} = results(i).nima_score;
        end
    end
    
    if ~isempty(allData)
        allFull = [allHeaders; allData];
        xlswrite(excelPath, allFull, 'All_Images');
        fprintf('✅ 전체 통합 시트 생성 완료\n');
    end
    
catch ME
    fprintf('❌ 통합 시트 오류: %s\n', ME.message);
end

% 최종 결과 출력
fprintf('\n🎉 모든 처리 완료!\n');
fprintf('📁 결과 파일: %s\n', excelPath);

totalImages = 0;
for groupIdx = 1:length(groupNames)
    groupName = groupNames{groupIdx};
    results = allResults.(groupName);
    if ~isempty(results)
        scores = [results.nima_score];
        fprintf('  - %s: %d개, 평균 %.2f점\n', groupName, length(results), mean(scores));
        totalImages = totalImages + length(results);
    end
end

fprintf('📊 총 처리된 이미지: %d개\n', totalImages);

end

function score = calculateNIMAScore(image)
% NIMA 점수 계산 함수

try
    % 이미지 전처리
    if size(image, 3) == 3
        grayImage = rgb2gray(image);
        colorImage = image;
        isColor = true;
    else
        grayImage = image;
        colorImage = repmat(image, [1, 1, 3]);
        isColor = false;
    end
    
    % double 변환 및 정규화
    if isa(grayImage, 'uint8')
        grayImage = double(grayImage) / 255;
        colorImage = double(colorImage) / 255;
    else
        grayImage = double(grayImage);
        colorImage = double(colorImage);
        if max(grayImage(:)) > 1
            grayImage = grayImage / 255;
            colorImage = colorImage / 255;
        end
    end
    
    % 1. 밝기 점수
    brightness = mean2(grayImage);
    brightness_score = 1.0 - abs(brightness - 0.5) * 2;
    brightness_score = max(0, min(1, brightness_score));
    
    % 2. 대비 점수
    contrast = std2(grayImage);
    contrast_score = min(contrast / 0.3, 1.0);
    
    % 3. 채도 점수
    if isColor
        hsv = rgb2hsv(colorImage);
        saturation = mean2(hsv(:,:,2));
        saturation_score = min(saturation * 1.5, 1.0);
    else
        saturation_score = 0.5;
    end
    
    % 4. 선명도 점수
    laplacian_kernel = [0 -1 0; -1 4 -1; 0 -1 0];
    laplacian_response = conv2(grayImage, laplacian_kernel, 'same');
    sharpness = var(laplacian_response(:));
    sharpness_score = min(sharpness * 1000, 1.0);
    
    % 5. 구도 점수
    [h, w] = size(grayImage);
    h_third = round(h/3);
    w_third = round(w/3);
    
    region_means = zeros(3,3);
    for i = 1:3
        for j = 1:3
            row_start = (i-1) * h_third + 1;
            row_end = min(i * h_third, h);
            col_start = (j-1) * w_third + 1;
            col_end = min(j * w_third, w);
            
            region = grayImage(row_start:row_end, col_start:col_end);
            region_means(i,j) = mean2(region);
        end
    end
    
    composition = std2(region_means);
    composition_score = min(composition / 0.3, 1.0);
    
    % 6. 엣지 점수
    edges = edge(grayImage, 'canny');
    edge_density = sum(edges(:)) / numel(edges);
    edge_score = min(edge_density * 10, 1.0);
    
    % 최종 점수 계산
    weights = [0.15, 0.20, 0.15, 0.25, 0.15, 0.10];
    scores = [brightness_score, contrast_score, saturation_score, ...
              sharpness_score, composition_score, edge_score];
    
    weighted_score = sum(weights .* scores);
    score = 1 + (weighted_score * 9);
    score = max(1.0, min(10.0, score));
    
catch ME
    fprintf('NIMA 계산 오류: %s\n', ME.message);
    score = 5.0;
end

end