function Official_NIMA_BatchProcessor()
% 완전히 수정된 NIMA 배치 처리 시스템

% 경로 설정
inputFolder = 'C:\Users\tilti\OneDrive\clahe_images\sh_method\Reinhard_tool\result\2025.07.29.14.38.18';
outputFolder = 'C:\Users\tilti\Downloads\score';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

fprintf('=== NIMA 이미지 품질 평가 시스템 ===\n');
fprintf('입력 폴더: %s\n', inputFolder);
fprintf('출력 폴더: %s\n\n', outputFolder);

% 모델 다운로드 및 로드 (원본 방식으로 복원)
fprintf('NIMA 모델 다운로드 및 로드 중...\n');
dataDir = tempdir;
trainedNet_url = 'https://ssd.mathworks.com/supportfiles/image/data/trainedNIMA.zip';

try
    % 실제 다운로드 함수 호출
    downloadTrainedNIMANetwork(trainedNet_url, dataDir);
    
    % 모델 로드
    modelPath = fullfile(dataDir, 'trainedNIMA.mat');
    if ~exist(modelPath, 'file')
        error('모델 파일이 다운로드되지 않았습니다.');
    end
    
    loadedData = load(modelPath);
    
    % 실제 변수명 확인
    fieldNames = fieldnames(loadedData);
    fprintf('모델 파일의 변수들: %s\n', strjoin(fieldNames, ', '));
    
    if isfield(loadedData, 'dlnet')
        dlnet = loadedData.dlnet;
        fprintf('dlnet 변수 로드됨\n');
    elseif isfield(loadedData, 'net')
        dlnet = loadedData.net;
        fprintf('net 변수 로드됨\n');
    elseif isfield(loadedData, 'trainedNet')
        dlnet = loadedData.trainedNet;
        fprintf('trainedNet 변수 로드됨\n');
    else
        error('모델 변수를 찾을 수 없습니다. 사용 가능한 변수: %s', strjoin(fieldNames, ', '));
    end
    
    fprintf('NIMA 모델 로드 완료!\n');
    fprintf('모델 타입: %s\n\n', class(dlnet));
    
catch ME
    fprintf('NIMA 모델 로드 실패: %s\n', ME.message);
    fprintf('인터넷 연결을 확인하고 다시 시도하세요.\n');
    return;
end

% 이미지 수집
imageExts = {'*.jpg','*.jpeg','*.png','*.bmp','*.tif','*.tiff'};
allImageFiles = {};
for ext = imageExts
    files = dir(fullfile(inputFolder, ext{1}));
    for k = 1:length(files)
        allImageFiles{end+1} = fullfile(inputFolder, files(k).name);
    end
end
fprintf('총 %d개의 이미지를 발견했습니다.\n\n', numel(allImageFiles));

if isempty(allImageFiles)
    fprintf('처리할 이미지가 없습니다.\n');
    return;
end

% 파일명 기반 그룹 분류
methods = struct();
methodNames = {};
for i = 1:length(allImageFiles)
    [~, filename, ext] = fileparts(allImageFiles{i});
    methodName = extractMethodFromFilename(filename);

    if ~isfield(methods, methodName)
        methods.(methodName) = {};
        methodNames{end+1} = methodName;
    end
    methods.(methodName){end+1} = struct( ...
        'filepath', allImageFiles{i}, ...
        'filename', [filename ext]);
end

% NIMA 점수 계산
allResults = struct();
for methodIdx = 1:length(methodNames)
    method = methodNames{methodIdx};
    imageList = methods.(method);
    fprintf('%s 처리 중 (%d개)...\n', method, numel(imageList));

    results = struct('filename', {}, 'nima_mean', {}, 'nima_std', {});
    for j = 1:numel(imageList)
        fprintf('  처리 중 (%d/%d): %s\n', j, numel(imageList), imageList{j}.filename);

        try
            img = imread(imageList{j}.filepath);
            [meanScore, stdScore] = predictNIMAScore_Custom(dlnet, img);
            fprintf('    NIMA 점수: %.6f ± %.6f\n', meanScore, stdScore);
            fprintf('      [MAIN] 저장될 값: %.6f ± %.6f\n', meanScore, stdScore);
        catch ME
            fprintf('    오류 발생: %s\n', ME.message);
            meanScore = NaN;
            stdScore = NaN;
        end
        
        results(j).filename = imageList{j}.filename;
        results(j).nima_mean = meanScore;
        results(j).nima_std = stdScore;
    end

    % 정렬
    try
        extractIdx = @(name) sscanf(regexp(name, '\((\d+)\)', 'match', 'once'), '(%d)');
        indices = arrayfun(@(x) extractIdx(x.filename), results);
        [~, order] = sort(indices);
        allResults.(method) = results(order);
    catch
        allResults.(method) = results;
    end
    fprintf('  %s 완료: %d개 이미지\n\n', method, numel(results));
end

% 결과 저장
fprintf('엑셀 파일 생성 중...\n');
createExcelReport(allResults, methodNames, outputFolder);

% 요약
fprintf('\n모든 처리 완료!\n결과 저장 위치: %s\n', outputFolder);
totalImages = 0;
for i = 1:length(methodNames)
    m = methodNames{i};
    scores = [allResults.(m).nima_mean];
    valid = scores(~isnan(scores));
    if ~isempty(valid)
        fprintf('  - %s: %d개, 평균 %.2f점 (±%.2f)\n', m, length(valid), mean(valid), std(valid));
        totalImages = totalImages + length(valid);
    end
end
fprintf('총 처리된 이미지: %d개\n', totalImages);
end

% =============================================
function [meanScore, stdScore] = predictNIMAScore_Custom(dlnet, image)
    fprintf('      [DEBUG] === NIMA 예측 시작 ===\n');
    
    % 모델 정보 출력
    fprintf('      [DEBUG] 모델 클래스: %s\n', class(dlnet));
    
    % 입력 크기 확인
    if isa(dlnet, 'SeriesNetwork') || isa(dlnet, 'DAGNetwork')
        inputSize = dlnet.Layers(1).InputSize;
        fprintf('      [DEBUG] 네트워크 레이어에서 입력 크기: %s\n', mat2str(inputSize));
    elseif isa(dlnet, 'dlnetwork')
        inputSize = [224 224 3];
        fprintf('      [DEBUG] dlnetwork 기본 입력 크기: %s\n', mat2str(inputSize));
    else
        inputSize = [224 224 3];
        fprintf('      [DEBUG] 알 수 없는 모델 타입, 기본 입력 크기: %s\n', mat2str(inputSize));
    end

    % 원본 이미지 정보
    fprintf('      [DEBUG] 원본 이미지 크기: %s, 타입: %s\n', mat2str(size(image)), class(image));
    
    % 채널 보정 (grayscale → RGB)
    if size(image, 3) == 1
        image = repmat(image, [1 1 3]);
        fprintf('      [DEBUG] Grayscale을 RGB로 변환\n');
    end

    % 전처리 및 변환
    image = imresize(im2single(image), inputSize(1:2));
    fprintf('      [DEBUG] 전처리 후 이미지: 크기=%s, 타입=%s, 범위=[%.3f, %.3f]\n', ...
            mat2str(size(image)), class(image), min(image(:)), max(image(:)));
    
    % GPU 사용 가능 여부 확인
    useGPU = false;
    try
        if gpuDeviceCount() > 0
            useGPU = true;
            fprintf('      [DEBUG] GPU 사용 가능\n');
        else
            fprintf('      [DEBUG] GPU 없음, CPU 사용\n');
        end
    catch
        fprintf('      [DEBUG] GPU 확인 실패, CPU 사용\n');
        useGPU = false;
    end
    
    % 모델 타입에 따른 예측
    try
        fprintf('      [DEBUG] 예측 시작...\n');
        
        if isa(dlnet, 'dlnetwork')
            fprintf('      [DEBUG] dlnetwork 경로 사용\n');
            dlImg = dlarray(image, 'SSC');
            dlImg = reshape(dlImg, [inputSize 1]);
            fprintf('      [DEBUG] dlarray 생성: %s\n', mat2str(size(dlImg)));
            
            if useGPU
                dlImg = gpuArray(dlImg);
                fprintf('      [DEBUG] GPU로 이동\n');
            end
            
            prediction = predict(dlnet, dlImg);
            fprintf('      [DEBUG] dlnetwork 예측 완료\n');
            
        else
            fprintf('      [DEBUG] 일반 네트워크 경로 사용\n');
            % 일반적인 CNN의 경우 (배치 차원 추가)
            image = reshape(image, [size(image) 1]);
            fprintf('      [DEBUG] 배치 차원 추가: %s\n', mat2str(size(image)));
            
            if useGPU
                image = gpuArray(image);
                fprintf('      [DEBUG] GPU로 이동\n');
            end
            
            prediction = predict(dlnet, image);
            fprintf('      [DEBUG] 일반 네트워크 예측 완료\n');
        end
        
        % 예측 결과 분석
        fprintf('      [DEBUG] 원시 예측 결과: 크기=%s, 타입=%s\n', mat2str(size(prediction)), class(prediction));
        
        prediction = extractdata(prediction(:));
        fprintf('      [DEBUG] extractdata 후: 길이=%d\n', length(prediction));
        fprintf('      [DEBUG] 예측값 처음 5개: %s\n', mat2str(prediction(1:min(5,end))'));
        fprintf('      [DEBUG] 예측값 범위: [%.6f, %.6f]\n', min(prediction), max(prediction));
        
        % 정규화 (확률 분포로 변환)
        predSum = sum(prediction);
        fprintf('      [DEBUG] 예측값 합계: %.6f\n', predSum);
        
        if predSum > 1e-10
            prediction = prediction / predSum;
            fprintf('      [DEBUG] 정규화 완료, 새로운 합계: %.6f\n', sum(prediction));
        else
            fprintf('      [WARNING] 예측값 합계가 너무 작음! 균등 분포 사용\n');
            prediction = ones(10,1) / 10;
        end
        
        % NIMA 점수 계산 (1-10 스케일)
        if length(prediction) == 10
            scores = (1:10)';
            fprintf('      [DEBUG] 1-10 스케일 사용\n');
        else
            scores = (1:length(prediction))';
            fprintf('      [DEBUG] 사용자 정의 스케일: 1-%d\n', length(prediction));
        end
        
        fprintf('      [DEBUG] 정규화된 확률: %s\n', mat2str(prediction'));
        
        % 최종 계산 직전 상세 디버깅
        fprintf('      [FINAL CHECK] 계산 직전 prediction: [%.6f %.6f %.6f %.6f %.6f]\n', prediction(1:5));
        fprintf('      [FINAL CHECK] scores 벡터: [%d %d %d %d %d]\n', scores(1:5));
        
        meanScore = sum(prediction .* scores);
        fprintf('      [FINAL CHECK] 가중합 계산: %.6f\n', meanScore);
        
        variance = sum(prediction .* (scores - meanScore).^2);
        stdScore = sqrt(variance);
        
        fprintf('      [FINAL CHECK] 최종 meanScore: %.6f\n', meanScore);
        fprintf('      [FINAL CHECK] 최종 stdScore: %.6f\n', stdScore);
        
        fprintf('      [DEBUG] 계산 완료 - 평균: %.6f, 분산: %.6f, 표준편차: %.6f\n', ...
                meanScore, variance, stdScore);
        
        % 결과 검증
        if isnan(meanScore) || isnan(stdScore)
            fprintf('      [ERROR] NaN 값 발생!\n');
            meanScore = 5.0;
            stdScore = 1.0;
        elseif meanScore < 1 || meanScore > 10
            fprintf('      [WARNING] 비정상적인 평균 점수: %.6f\n', meanScore);
        end
        
        fprintf('      [DEBUG] 최종 결과: %.6f ± %.6f\n', meanScore, stdScore);
        fprintf('      [DEBUG] === NIMA 예측 완료 ===\n');
        
    catch ME
        fprintf('      [ERROR] 예측 실행 중 오류: %s\n', ME.message);
        fprintf('      [ERROR] 스택 트레이스:\n');
        for i = 1:length(ME.stack)
            fprintf('        %s (라인 %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        fprintf('      [ERROR] 기본값 사용: 5.0 ± 1.0\n');
        meanScore = 5.0;
        stdScore = 1.0;
    end
end

function methodName = extractMethodFromFilename(filename)
    tokens = regexp(filename, '^(.*?) \(\d+\)$', 'tokens');
    if ~isempty(tokens)
        methodName = matlab.lang.makeValidName(strtrim(lower(tokens{1}{1})));
    else
        methodName = 'unknown';
    end
end

function downloadTrainedNIMANetwork(url, dataDir)
    % 원본 다운로드 함수 복원
    zipFile = fullfile(dataDir, 'trainedNIMA.zip');
    matFile = fullfile(dataDir, 'trainedNIMA.mat');
    
    if ~exist(matFile, 'file')
        fprintf('NIMA 모델 다운로드 중... (시간이 걸릴 수 있습니다)\n');
        try
            websave(zipFile, url);
            fprintf('다운로드 완료, 압축 해제 중...\n');
            unzip(zipFile, dataDir);
            delete(zipFile);
            fprintf('압축 해제 완료\n');
        catch ME
            error('다운로드 실패: %s', ME.message);
        end
    else
        fprintf('기존 모델 파일 사용\n');
    end
end

function createExcelReport(allResults, methodNames, outputFolder)
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    excelFile = fullfile(outputFolder, ['NIMA_Results_' timestamp '.xlsx']);
    
    % 헤더 생성
    header = {'Index'};
    for i = 1:length(methodNames)
        header{end+1} = [methodNames{i} '_Mean'];
        header{end+1} = [methodNames{i} '_Std'];
    end

    % 데이터 준비
    maxLen = max(cellfun(@(m) length(allResults.(m)), methodNames));
    data = cell(maxLen, length(header));
    
    for row = 1:maxLen
        data{row, 1} = row;
        col = 2;
        for i = 1:length(methodNames)
            m = methodNames{i};
            if row <= length(allResults.(m))
                r = allResults.(m)(row);
                data{row, col} = r.nima_mean;
                data{row, col+1} = r.nima_std;
            else
                data{row, col} = NaN;
                data{row, col+1} = NaN;
            end
            col = col + 2;
        end
    end

    % 엑셀 저장
    try
        allData = [header; data];
        writecell(allData, excelFile);
    catch
        try
            xlswrite(excelFile, [header; data]);
        catch ME
            fprintf('엑셀 저장 실패: %s\n', ME.message);
            csvFile = strrep(excelFile, '.xlsx', '.csv');
            writecell([header; data], csvFile);
            fprintf('CSV로 대신 저장됨: %s\n', csvFile);
            return;
        end
    end
    
    fprintf(' 엑셀 저장 완료: %s\n', excelFile);
end