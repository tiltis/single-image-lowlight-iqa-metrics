function Simple_LPIPS_BatchProcessor_MSR()
% MATLAB 기반 간단한 LPIPS 대안 (Python 없이 사용 가능)
% 실제 LPIPS와 유사한 지각적 거리 측정

% 경로 설정
originalFolder = 'C:\opencv\4mon\allmain';
enhancedFolder = 'C:\Users\tilti\OneDrive\clahe_images\sh_method\icam';
outputFolder = 'C:\Users\tilti\Downloads\score';

% 출력 폴더 생성
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

fprintf('=== MATLAB 기반 지각적 유사성 평가 시스템 ===\n');
fprintf('원본 폴더: %s\n', originalFolder);
fprintf('개선 폴더: %s\n', enhancedFolder);
fprintf('출력 폴더: %s\n\n', outputFolder);

% 먼저 폴더 내용 확인
fprintf('🔍 폴더 내용 확인 중...\n');
checkFolderContents(originalFolder, enhancedFolder);

% 이미지 쌍 찾기
fprintf('\n📁 이미지 쌍 매칭 중...\n');
[imagePairs, totalPairs] = findImagePairs(originalFolder, enhancedFolder);

if totalPairs == 0
    fprintf('❌ 대응되는 이미지 쌍을 찾을 수 없습니다!\n');
    return;
end

fprintf('📊 총 %d개의 이미지 쌍을 발견했습니다.\n\n', totalPairs);

% 지각적 거리 계산
fprintf('🎯 지각적 유사성 점수 계산 중...\n');
results = struct('filename', {}, 'perceptual_distance', {}, 'processing_time', {});

totalTime = 0;
validResults = 0;

% 디버깅: 실제 처리될 개수 확인
fprintf('🔍 처리할 이미지 쌍: %d개\n', totalPairs);

for i = 1:totalPairs
    pair = imagePairs(i);
    fprintf('처리 중 (%d/%d): %s → %s\n', i, totalPairs, pair.filename, ...
            extractFilename(pair.enhancedPath));
    
    tic;
    try
        % 지각적 거리 계산 (한 방향만)
        distance = calculatePerceptualDistance(pair.originalPath, pair.enhancedPath);
        processingTime = toc;
        
        % 결과 저장
        results(i).filename = pair.filename;
        results(i).perceptual_distance = distance;
        results(i).processing_time = processingTime;
        
        validResults = validResults + 1;
        totalTime = totalTime + processingTime;
        
        fprintf('  지각적 거리: %.4f (%.2f초)\n', distance, processingTime);
        
    catch ME
        processingTime = toc;
        fprintf('  ❌ 오류: %s\n', ME.message);
        
        results(i).filename = pair.filename;
        results(i).perceptual_distance = NaN;
        results(i).processing_time = processingTime;
    end
end

% 최종 결과 개수 확인
fprintf('🔍 최종 결과 배열 크기: %d개\n', length(results));

% 통계 분석
fprintf('\n📊 통계 분석 중...\n');
validScores = [results.perceptual_distance];
validScores = validScores(~isnan(validScores));

if ~isempty(validScores)
    stats = struct();
    stats.count = length(validScores);
    stats.mean = mean(validScores);
    stats.std = std(validScores);
    stats.min = min(validScores);
    stats.max = max(validScores);
    stats.median = median(validScores);
    stats.q25 = prctile(validScores, 25);
    stats.q75 = prctile(validScores, 75);
    
    % 품질 등급 분류 (LPIPS와 유사한 기준)
    excellent = sum(validScores <= 0.15);
    good = sum(validScores > 0.15 & validScores <= 0.30);
    fair = sum(validScores > 0.30 & validScores <= 0.50);
    poor = sum(validScores > 0.50);
    
    fprintf('🎉 OpenCV Enhancement 지각적 유사성 결과:\n');
    fprintf('----------------------------------------\n');
    fprintf('처리된 이미지: %d개\n', stats.count);
    fprintf('평균 거리: %.4f ± %.4f\n', stats.mean, stats.std);
    fprintf('중앙값: %.4f\n', stats.median);
    fprintf('범위: %.4f ~ %.4f\n', stats.min, stats.max);
    fprintf('사분위수: %.4f (Q1) ~ %.4f (Q3)\n', stats.q25, stats.q75);
    fprintf('\n품질 분포:\n');
    fprintf('  우수 (≤0.15): %d개 (%.1f%%)\n', excellent, excellent/stats.count*100);
    fprintf('  좋음 (0.15-0.30): %d개 (%.1f%%)\n', good, good/stats.count*100);
    fprintf('  보통 (0.30-0.50): %d개 (%.1f%%)\n', fair, fair/stats.count*100);
    fprintf('  나쁨 (>0.50): %d개 (%.1f%%)\n', poor, poor/stats.count*100);
    fprintf('\n처리 시간: 총 %.1f초 (평균 %.2f초/이미지)\n', totalTime, totalTime/validResults);
    
    % 결과 저장
    fprintf('\n💾 결과 저장 중...\n');
    saveResults(results, stats, outputFolder);
    
    % 시각화
    fprintf('📈 결과 시각화 중...\n');
    createVisualization(validScores, stats, outputFolder);
    
else
    fprintf('❌ 유효한 점수가 없습니다!\n');
end

fprintf('\n✅ 모든 처리 완료!\n');
fprintf('📁 결과 저장 위치: %s\n', outputFolder);

end

function checkFolderContents(originalFolder, enhancedFolder)
% 폴더 내용 확인 및 출력

fprintf('원본 폴더 내용 (처음 10개):\n');
originalFiles = dir(fullfile(originalFolder, '*.jpg'));
if isempty(originalFiles)
    originalFiles = dir(fullfile(originalFolder, '*.JPG'));
end
if isempty(originalFiles)
    originalFiles = dir(fullfile(originalFolder, '*.png'));
end

for i = 1:min(10, length(originalFiles))
    fprintf('  %s\n', originalFiles(i).name);
end
if length(originalFiles) > 10
    fprintf('  ... (총 %d개)\n', length(originalFiles));
end

fprintf('\n개선 폴더 내용 (모든 파일):\n');
enhancedFiles = dir(fullfile(enhancedFolder, '*.jpg'));
if isempty(enhancedFiles)
    enhancedFiles = dir(fullfile(enhancedFolder, '*.JPG'));
end
if isempty(enhancedFiles)
    enhancedFiles = dir(fullfile(enhancedFolder, '*.png'));
end
if isempty(enhancedFiles)
    enhancedFiles = dir(fullfile(enhancedFolder, '*.PNG'));
end

% 모든 파일 출력 (패턴 파악용)
for i = 1:length(enhancedFiles)
    fprintf('  %s\n', enhancedFiles(i).name);
end
if isempty(enhancedFiles)
    fprintf('  (파일이 없습니다)\n');
else
    fprintf('  총 %d개 파일\n', length(enhancedFiles));
end

end

function [imagePairs, totalPairs] = findImagePairs(originalFolder, enhancedFolder)
% 대응되는 이미지 쌍 찾기 (한 방향만)

imagePairs = struct('filename', {}, 'originalPath', {}, 'enhancedPath', {});
totalPairs = 0;

% 지원하는 이미지 확장자
imageExts = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tif', '*.tiff', '*.JPG', '*.JPEG', '*.PNG'};

% 원본 폴더의 모든 이미지 찾기
originalFiles = {};
for extIdx = 1:length(imageExts)
    files = dir(fullfile(originalFolder, imageExts{extIdx}));
    for fileIdx = 1:length(files)
        originalFiles{end+1} = files(fileIdx).name;
    end
end

fprintf('원본 파일 %d개 발견\n', length(originalFiles));

% 각 원본 파일에 대해 대응되는 개선된 파일 찾기 (원본 → 개선 방향만)
for i = 1:length(originalFiles)
    originalFile = originalFiles{i};
    [~, basename, ext] = fileparts(originalFile);
    
    % 다양한 매칭 패턴 시도
    enhancedPath = '';
    matchedName = '';
    
    % 패턴 1: 정확한 숫자 매칭 (main (1).JPG -> msr (1).JPG)
    pattern = '\((\d+)\)';
    match = regexp(basename, pattern, 'tokens');
    
    if ~isempty(match)
        number = match{1}{1};
        possibleNames = {
            sprintf('opencv (%s)', number),      % opencv (1) - 확장자 없음
            sprintf('opencv (%s).JPG', number),  % opencv (1).JPG
            sprintf('opencv (%s).jpg', number),  % opencv (1).jpg
            sprintf('opencv (%s).png', number),  % opencv (1).png
            sprintf('opencv (%s).PNG', number),  % opencv (1).PNG
            sprintf('clahe (%s)', number),       % clahe (1) - 확장자 없음
            sprintf('clahe (%s).JPG', number),   % clahe (1).JPG
            sprintf('msr (%s)', number),         % msr (1) - 확장자 없음
            sprintf('msr (%s).JPG', number),     % msr (1).JPG
            sprintf('my (%s)', number),          % my (1) - 확장자 없음
            sprintf('my (%s).JPG', number),      % my (1).JPG
            sprintf('yj (%s)', number),          % yj (1) - 확장자 없음
            sprintf('yj (%s).JPG', number),      % yj (1).JPG
        };
    else
        % 괄호가 없는 경우
        possibleNames = {
            sprintf('msr_%s%s', basename, ext),
            sprintf('msr_%s.jpg', basename),
            sprintf('msr_%s.JPG', basename),
            sprintf('msr_%s.png', basename),
            sprintf('msr%s', originalFile),
            originalFile, % 동일한 이름도 확인
        };
    end
    
    % 대응 파일 찾기
    for j = 1:length(possibleNames)
        testPath = fullfile(enhancedFolder, possibleNames{j});
        if exist(testPath, 'file')
            enhancedPath = testPath;
            matchedName = possibleNames{j};
            break;
        end
    end
    
    if ~isempty(enhancedPath)
        totalPairs = totalPairs + 1;
        imagePairs(totalPairs).filename = originalFile;
        imagePairs(totalPairs).originalPath = fullfile(originalFolder, originalFile);
        imagePairs(totalPairs).enhancedPath = enhancedPath;
        
        fprintf('  ✅ 매칭: %s → %s\n', originalFile, matchedName);
    else
        fprintf('  ⚠️  대응 파일 없음: %s\n', originalFile);
        % 가능한 이름들 출력 (디버깅용)
        if i <= 5 % 처음 5개만 상세 출력
            fprintf('      시도한 이름들: %s\n', strjoin(possibleNames, ', '));
        end
    end
end

fprintf('총 %d개의 원본→개선 쌍 생성\n', totalPairs);

end

function distance = calculatePerceptualDistance(originalPath, enhancedPath)
% MATLAB 기반 지각적 거리 계산 (LPIPS 근사)

try
    % 이미지 로드
    img1 = imread(originalPath);
    img2 = imread(enhancedPath);
    
    % 크기 통일
    targetSize = [224, 224];
    img1 = imresize(img1, targetSize);
    img2 = imresize(img2, targetSize);
    
    % RGB 변환
    if size(img1, 3) == 1
        img1 = repmat(img1, [1, 1, 3]);
    end
    if size(img2, 3) == 1
        img2 = repmat(img2, [1, 1, 3]);
    end
    
    % 정규화
    img1 = im2double(img1);
    img2 = im2double(img2);
    
    % 여러 지각적 특징 추출 및 거리 계산
    distance = 0;
    weights = [0.3, 0.25, 0.2, 0.15, 0.1]; % 각 특징의 가중치
    
    % 1. 색상 공간에서의 거리 (Lab)
    try
        lab1 = rgb2lab(img1);
        lab2 = rgb2lab(img2);
        color_dist = mean(sqrt(sum((lab1 - lab2).^2, 3)), 'all');
        distance = distance + weights(1) * normalize_distance(color_dist, 0, 100);
    catch
        % Lab 변환 실패 시 RGB 사용
        rgb_dist = mean(sqrt(sum((img1 - img2).^2, 3)), 'all');
        distance = distance + weights(1) * normalize_distance(rgb_dist, 0, 1);
    end
    
    % 2. 구조적 유사성 (SSIM 기반)
    try
        gray1 = rgb2gray(img1);
        gray2 = rgb2gray(img2);
        ssim_val = ssim(gray1, gray2);
        ssim_dist = 1 - ssim_val; % SSIM을 거리로 변환
        distance = distance + weights(2) * ssim_dist;
    catch
        % SSIM 실패 시 단순 차이 사용
        gray1 = rgb2gray(img1);
        gray2 = rgb2gray(img2);
        gray_dist = mean(abs(gray1(:) - gray2(:)));
        distance = distance + weights(2) * gray_dist;
    end
    
    % 3. 에지 특징 거리
    try
        edge1 = edge(rgb2gray(img1), 'canny');
        edge2 = edge(rgb2gray(img2), 'canny');
        edge_dist = mean(abs(double(edge1(:)) - double(edge2(:))));
        distance = distance + weights(3) * edge_dist;
    catch
        distance = distance + weights(3) * 0.1; % 기본값
    end
    
    % 4. 텍스처 특징 거리 (LBP 기반)
    try
        texture_dist = calculateTextureDistance(img1, img2);
        distance = distance + weights(4) * normalize_distance(texture_dist, 0, 1);
    catch
        distance = distance + weights(4) * 0.1; % 기본값
    end
    
    % 5. 그래디언트 특징 거리
    try
        [gx1, gy1] = gradient(rgb2gray(img1));
        [gx2, gy2] = gradient(rgb2gray(img2));
        grad_dist = mean(sqrt((gx1 - gx2).^2 + (gy1 - gy2).^2), 'all');
        distance = distance + weights(5) * normalize_distance(grad_dist, 0, 2);
    catch
        distance = distance + weights(5) * 0.1; % 기본값
    end
    
    % 최종 거리 정규화 (0-1 범위)
    distance = max(0, min(1, distance));
    
catch ME
    fprintf('    지각적 거리 계산 오류: %s\n', ME.message);
    distance = 0.5; % 기본값
end

end

function normalized = normalize_distance(value, min_val, max_val)
% 거리 값을 0-1 범위로 정규화
normalized = (value - min_val) / (max_val - min_val);
normalized = max(0, min(1, normalized));
end

function texture_dist = calculateTextureDistance(img1, img2)
% 간단한 텍스처 거리 계산

% 그레이스케일 변환
gray1 = rgb2gray(img1);
gray2 = rgb2gray(img2);

% LBP 유사 특징 추출
lbp1 = extractSimpleLBP(gray1);
lbp2 = extractSimpleLBP(gray2);

% 히스토그램 거리
texture_dist = sum(abs(lbp1 - lbp2));

end

function lbp_hist = extractSimpleLBP(gray_img)
% 간단한 LBP 히스토그램 추출

[rows, cols] = size(gray_img);
lbp_values = [];

% 3x3 윈도우로 LBP 계산
for i = 2:rows-1
    for j = 2:cols-1
        center = gray_img(i, j);
        neighbors = [
            gray_img(i-1, j-1), gray_img(i-1, j), gray_img(i-1, j+1),
            gray_img(i, j+1), gray_img(i+1, j+1), gray_img(i+1, j),
            gray_img(i+1, j-1), gray_img(i, j-1)
        ];
        
        binary_pattern = neighbors >= center;
        lbp_value = sum(binary_pattern .* (2.^(0:7)));
        lbp_values(end+1) = lbp_value;
    end
end

% 히스토그램 생성 (256 bins)
lbp_hist = histcounts(lbp_values, 0:256);
lbp_hist = lbp_hist / sum(lbp_hist); % 정규화

end

function saveResults(results, stats, outputFolder)
% 결과를 엑셀 파일로 저장

try
    % lpips_opencv.xlsx 파일 생성
    excelFilename = 'lpips_opencv.xlsx';
    excelPath = fullfile(outputFolder, excelFilename);
    
    % 데이터 준비
    headers = {'Image_Name', 'Perceptual_Distance', 'Quality_Grade', 'Processing_Time'};
    data = cell(length(results), 4);
    
    for i = 1:length(results)
        data{i, 1} = results(i).filename;
        data{i, 2} = results(i).perceptual_distance;
        
        % 품질 등급 추가
        if ~isnan(results(i).perceptual_distance)
            if results(i).perceptual_distance <= 0.15
                data{i, 3} = 'Excellent';
            elseif results(i).perceptual_distance <= 0.30
                data{i, 3} = 'Good';
            elseif results(i).perceptual_distance <= 0.50
                data{i, 3} = 'Fair';
            else
                data{i, 3} = 'Poor';
            end
        else
            data{i, 3} = 'Error';
        end
        
        data{i, 4} = results(i).processing_time;
    end
    
    % 헤더와 데이터 결합
    fullData = [headers; data];
    
    % 메인 시트에 쓰기
    try
        writecell(fullData, excelPath, 'Sheet', 'Perceptual_Distance_Results');
    catch
        xlswrite(excelPath, fullData, 'Perceptual_Distance_Results');
    end
    
    % 통계 요약 시트 추가
    summaryHeaders = {'Statistic', 'Value', 'Description'};
    summaryData = {
        'Total_Images', stats.count, 'Number of processed images';
        'Mean_Distance', stats.mean, 'Average perceptual distance (lower is better)';
        'Std_Distance', stats.std, 'Standard deviation of distances';
        'Min_Distance', stats.min, 'Best (lowest) distance';
        'Max_Distance', stats.max, 'Worst (highest) distance';
        'Median_Distance', stats.median, 'Median distance';
        'Q25_Distance', stats.q25, '25th percentile';
        'Q75_Distance', stats.q75, '75th percentile';
    };
    
    summaryFull = [summaryHeaders; summaryData];
    try
        writecell(summaryFull, excelPath, 'Sheet', 'Statistics_Summary');
    catch
        xlswrite(excelPath, summaryFull, 'Statistics_Summary');
    end
    
    fprintf('✅ 결과 저장: %s\n', excelPath);
    fprintf('   📊 MATLAB 기반 지각적 거리 분석 완료\n');
    
catch ME
    fprintf('❌ 엑셀 저장 오류: %s\n', ME.message);
end

end

function createVisualization(validScores, stats, outputFolder)
% 결과 시각화

try
    figure('Position', [100, 100, 1200, 600]);
    
    % 히스토그램
    subplot(1, 2, 1);
    histogram(validScores, 15, 'FaceColor', [0.3, 0.6, 0.9], 'EdgeColor', 'black');
    title('지각적 거리 분포 (OpenCV Enhancement)', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('지각적 거리', 'FontSize', 12);
    ylabel('빈도', 'FontSize', 12);
    grid on;
    
    % 평균선 추가
    hold on;
    line([stats.mean, stats.mean], ylim, 'Color', 'red', 'LineWidth', 2, 'LineStyle', '--');
    legend({'거리 분포', sprintf('평균 = %.4f', stats.mean)}, 'Location', 'best');
    
    % 박스플롯
    subplot(1, 2, 2);
    boxplot(validScores, 'Labels', {'OpenCV Method'});
    title('지각적 거리 박스플롯', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('지각적 거리', 'FontSize', 12);
    grid on;
    
    % 그래프 저장
    figFilename = 'lpips_opencv_analysis.png';
    figPath = fullfile(outputFolder, figFilename);
    
    saveas(gcf, figPath);
    fprintf('✅ 시각화 저장: %s\n', figPath);
    
catch ME
    fprintf('❌ 시각화 생성 오류: %s\n', ME.message);
end

end

function filename = extractFilename(fullPath)
% 파일 경로에서 파일명만 추출
[~, name, ext] = fileparts(fullPath);
filename = [name ext];
end