function [meanScore, stdScore] = predictNIMAScore_Custom(dlnet, image)
    % 디버깅을 위한 출력 추가
    fprintf('      [DEBUG] 이미지 크기: %dx%dx%d\n', size(image));
    
    % 입력 크기 확인
    if isa(dlnet, 'SeriesNetwork') || isa(dlnet, 'DAGNetwork')
        inputSize = dlnet.Layers(1).InputSize;
    elseif isa(dlnet, 'dlnetwork')
        inputSize = [224 224 3]; % 일반적인 NIMA 입력 크기
    else
        inputSize = [224 224 3];
    end
    
    fprintf('      [DEBUG] 모델 입력 크기: %dx%dx%d\n', inputSize);

    % 채널 보정 (grayscale → RGB)
    if size(image, 3) == 1
        image = repmat(image, [1 1 3]);
        fprintf('      [DEBUG] Grayscale을 RGB로 변환\n');
    end

    % 전처리 및 변환
    image = imresize(im2single(image), inputSize(1:2));
    fprintf('      [DEBUG] 전처리 후 이미지 크기: %dx%dx%d\n', size(image));
    
    % GPU 사용 가능 여부 확인
    useGPU = false;
    try
        if gpuDeviceCount() > 0
            useGPU = true;
            fprintf('      [DEBUG] GPU 사용\n');
        else
            fprintf('      [DEBUG] CPU 사용\n');
        end
    catch
        fprintf('      [DEBUG] GPU 확인 실패, CPU 사용\n');
        useGPU = false;
    end
    
    % dlarray 생성 및 예측
    try
        if isa(dlnet, 'dlnetwork')
            dlImg = dlarray(image, 'SSC');
            dlImg = reshape(dlImg, [inputSize 1]);
            
            if useGPU
                dlImg = gpuArray(dlImg);
            end
            
            fprintf('      [DEBUG] dlarray 크기: %s\n', mat2str(size(dlImg)));
            
            % 예측 수행
            prediction = predict(dlnet, dlImg);
            fprintf('      [DEBUG] 예측 결과 크기: %s\n', mat2str(size(prediction)));
            
        else
            % 일반적인 CNN의 경우
            if useGPU
                image = gpuArray(image);
            end
            
            % 배치 차원 추가 (필요한 경우)
            if ndims(image) == 3
                image = reshape(image, [size(image) 1]);
            end
            
            fprintf('      [DEBUG] 네트워크 입력 크기: %s\n', mat2str(size(image)));
            prediction = predict(dlnet, image);
            fprintf('      [DEBUG] 예측 결과 크기: %s\n', mat2str(size(prediction)));
        end
        
        % 예측 결과 처리
        prediction = extractdata(prediction(:));
        fprintf('      [DEBUG] 추출된 예측값 크기: %d, 첫 5개 값: %s\n', ...
                length(prediction), mat2str(prediction(1:min(5,end))'));
        
        % 정규화 확인
        predSum = sum(prediction);
        fprintf('      [DEBUG] 예측값 합계: %.6f\n', predSum);
        
        if predSum > 0
            prediction = prediction / predSum;
        else
            fprintf('      [WARNING] 예측값 합계가 0입니다!\n');
            prediction = ones(10,1) / 10; % 균등 분포로 대체
        end

        % NIMA 점수 계산 (1-10 스케일)
        scores = (1:length(prediction))';
        fprintf('      [DEBUG] 점수 범위: %d부터 %d까지 (%d개)\n', ...
                min(scores), max(scores), length(scores));
        
        meanScore = sum(prediction .* scores);
        variance = sum(prediction .* (scores - meanScore).^2);
        stdScore = sqrt(variance);
        
        fprintf('      [DEBUG] 계산된 평균: %.6f, 표준편차: %.6f\n', meanScore, stdScore);
        
        % 결과 검증
        if isnan(meanScore) || isnan(stdScore)
            fprintf('      [ERROR] NaN 값 발생!\n');
            meanScore = 5.0; % 기본값
            stdScore = 1.0;
        end
        
        if meanScore < 1 || meanScore > 10
            fprintf('      [WARNING] 비정상적인 평균 점수: %.2f\n', meanScore);
        end
        
    catch ME
        fprintf('      [ERROR] 예측 실행 중 오류: %s\n', ME.message);
        meanScore = NaN;
        stdScore = NaN;
    end
end