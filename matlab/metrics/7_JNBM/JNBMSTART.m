% 동적으로 i 값을 받기
i = 1; % 원하는 i 값을 설정 (예: 1, 2 등)

% 이미지가 저장된 폴더 경로
image_folder = sprintf('C:/Users/PC00/Desktop/score/metrics/newtestresult/test%d', i); % 동적 경로 설정

% 처리할 이미지 파일 이름 리스트 (확장자 무관)
image_files = {'aMSR', 'DCT', 'EF', 'FMMR', 'GRW', 'MITM'}; % HE와 LE는 제외

% 메트릭 값을 저장할 배열
metrics = zeros(1, length(image_files)); 

% 폴더 내 모든 파일 정보 가져오기
all_files = dir(image_folder);
disp({all_files.name}); % 파일 이름 목록 출력

% 각 이미지 파일 불러오고 메트릭 계산
for idx = 1:length(image_files)
    % 파일 이름 패턴 생성 (예: aMSR1.*, DCT1.*, ...)
    file_pattern = sprintf('%s%d', image_files{idx}, i); 
    
    % 해당 패턴에 맞는 파일 찾기
    file_info = all_files(~[all_files.isdir] & contains({all_files.name}, file_pattern, 'IgnoreCase', true));
    
    % 파일이 존재하는 경우에만 처리
    if ~isempty(file_info)
        file_path = fullfile(image_folder, file_info(1).name); % 첫 번째 일치하는 파일 경로
        
        % 디버깅: 파일 경로 확인
        fprintf('Processing file: %s\n', file_path);
        
        % 이미지 불러오기 및 메트릭 계산
        img = imread(file_path);
        metrics(idx) = JNBM_compute(img);
    else
        fprintf('파일 %s를 찾을 수 없습니다.\n', file_pattern);
        metrics(idx) = NaN; % 파일이 없을 때 NaN 값으로 설정
    end
end

% 결과 출력
fprintf('Metrics for i=%d:\n', i);
fprintf('%.4f\n', metrics);
