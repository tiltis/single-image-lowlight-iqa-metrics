% run_MCMA_all_methods.m

% 경로 설정
originalPath   = 'C:\Users\tilti\Downloads\score\original';
enhancedRoot   = 'C:\opencv\4mon\score';
outputFolder   = 'C:\opencv\4mon\scoreimg';
outputFile     = fullfile(outputFolder,'mcma_results_by_number.xlsx');

% 평가할 번호와 방법 리스트
N       = 35;
methods = {'jins','msr','opencv','yujung'};

% 결과 행렬 미리 할당
scores = zeros(N, numel(methods));

% MCMA 계산 루프
for m = 1:numel(methods)
    method = methods{m};
    for i = 1:N
        % 원본 영상 파일 (original (i).jpg)
        origFile = fullfile(originalPath, sprintf('original (%d).jpg', i));
        if ~exist(origFile,'file')
            error('원본 파일이 없습니다: %s', origFile);
        end

        % 향상된 영상 파일 (예: jins (i).jpg)
        enhFile  = fullfile(enhancedRoot, sprintf('%s (%d).jpg', method, i));
        if ~exist(enhFile,'file')
            error('향상 파일이 없습니다: %s', enhFile);
        end

        % 읽기
        Ilow = imread(origFile);
        Ienh = imread(enhFile);

        % MCMA 계산
        scores(i,m) = MCMA(Ilow, Ienh);
    end
end

% 테이블로 변환: 첫 열 Number, 나머지 열은 methods 순서대로 MCMA
T = array2table(scores, 'VariableNames', methods);
T = addvars(T, (1:N)', 'Before', 1, 'NewVariableNames', 'Number');

% 폴더 없으면 생성
if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end

% 엑셀로 저장
writetable(T, outputFile);

fprintf('MCMA 결과를 엑셀로 저장했습니다:\n%s\n', outputFile);
