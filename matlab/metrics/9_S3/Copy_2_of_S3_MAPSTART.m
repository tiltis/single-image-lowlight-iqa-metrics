% 원하는 i 값을 설정 (예: 1, 2, ..., 12 등)
i = 1:12; % MITM1부터 MITM12까지 처리

% 이미지가 저장된 폴더 경로 (동적 경로 설정)
image_folder = 'C:/Users/PC00/Desktop/score/metrics/origtestresult/MITM'; % 경로 수정

% 처리할 이미지 파일 이름 리스트 (MITM으로 시작하는 파일)
image_files = arrayfun(@(x) sprintf('MITM%d', x), i, 'UniformOutput', false); 

% 메트릭 값을 저장할 배열
metrics = zeros(1, length(image_files));

% 폴더 내 모든 파일 정보 가져오기
all_files = dir(image_folder);
disp({all_files.name}); % 파일 이름 목록 출력

% 각 이미지 파일 불러오고 메트릭 계산
for idx = 1:length(image_files)
    % 파일 이름 패턴 생성 (예: MITM1.*, MITM2.*, ...)
    file_pattern = sprintf('%s', image_files{idx});
    
    % 해당 패턴에 맞는 파일 찾기
    file_info = all_files(~[all_files.isdir] & contains({all_files.name}, file_pattern, 'IgnoreCase', true));
    
    % 파일이 존재하는 경우에만 처리
    if ~isempty(file_info)
        file_path = fullfile(image_folder, file_info(1).name); % 첫 번째 일치하는 파일 경로
        
        % 디버깅: 파일 경로 확인
        fprintf('Processing file: %s\n', file_path);
        
        % 이미지 불러오기 및 그레이스케일 변환, double 타입으로 변환
        img = imread(file_path);
        if size(img, 3) == 3 % 컬러 이미지인 경우
            img = rgb2gray(img);
        end
        img = double(img);
        
        % s3_map 메트릭 계산
        [~, ~, metric] = s3_map(img, 0);
        metrics(idx) = mean(metric(:)); % 메트릭의 평균값 계산
    else
        fprintf('파일 %s를 찾을 수 없습니다.\n', file_pattern);
        metrics(idx) = NaN; % 파일이 없을 때 NaN 값으로 설정
    end
end

% 결과 출력
fprintf('Metrics for MITM images:\n');
fprintf('%.4f\n', metrics);
