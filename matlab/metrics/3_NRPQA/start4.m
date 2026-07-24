% 작업 경로 설정
cd('C:/Users/PC00/Desktop/score/metrics/3_NRPQA'); % 실제 경로로 교체하세요

% 변수 i의 값 설정
i = 13; % 예를 들어, i가 1이라고 가정

% 이미지가 저장된 폴더 경로
image_folder = sprintf('C:/Users/PC00/Desktop/score/metrics/newtestresult/test%d', i);

% 파일명 패턴 설정 (LE와 HE 제외)
file_names = {'aMSR', 'DCT', 'EF', 'FMMR', 'GRW', 'MITM'};

% 결과 저장을 위한 배열 초기화
results = zeros(length(file_names), 1);

% 파일을 하나씩 읽어서 처리
for j = 1:length(file_names)
    % 파일명 생성 (확장자에 관계없이 파일 찾기)
    base_name = sprintf('%s%d', file_names{j}, i);
    possible_files = dir(fullfile(image_folder, [base_name, '.*'])); % 모든 확장자 파일 검색
    
    % 파일이 존재하는지 확인
    if ~isempty(possible_files)
        % 첫 번째로 찾은 파일 사용
        full_path = fullfile(image_folder, possible_files(1).name);
        
        % 이미지 읽기
        img = imread(full_path);
        
        % 그레이스케일 변환 (이미지가 RGB인 경우에만)
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
        
        % jpeg_quality_score 함수 실행
        score = jpeg_quality_score(img);
        
        % 결과 저장
        results(j) = score;
        
        % 결과 출력
        fprintf('File: %s, Quality Score: %f\n', possible_files(1).name, score);
    else
        fprintf('File not found for: %s\n', base_name);
        results(j) = NaN; % 파일이 없는 경우 NaN으로 처리
    end
end

% 전체 결과 출력
disp('Quality Scores for all images:');
disp(results);
