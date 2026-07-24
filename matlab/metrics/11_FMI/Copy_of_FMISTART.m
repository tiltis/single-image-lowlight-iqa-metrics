% 원하는 i 값을 설정 (예: 1, 2 등)
i = 13;

% 이미지가 저장된 폴더 경로 (동적 경로 설정)
image_folder = sprintf('C:/Users/PC00/Desktop/score/metrics/newtestresult/test%d', i);

% 처리할 이미지 파일 이름 리스트 (확장자 무관)
image_files = {'LE', 'HE', 'aMSR', 'DCT', 'EF', 'FMMR', 'GRW', 'MITM'};

% 메트릭 값을 저장할 배열
metrics = zeros(1, length(image_files) - 2); % LE, HE는 융합이 아니므로 제외

% 폴더 내 모든 파일 정보 가져오기
all_files = dir(fullfile(image_folder, '*.*')); % 모든 파일을 검색
disp({all_files.name}); % 파일 이름 목록 출력

% LE와 HE 이미지를 먼저 불러오기
ima_info = all_files(~[all_files.isdir] & contains({all_files.name}, 'LE', 'IgnoreCase', true));
imb_info = all_files(~[all_files.isdir] & contains({all_files.name}, 'HE', 'IgnoreCase', true));

% LE와 HE 이미지 로드 및 그레이스케일 변환
if ~isempty(ima_info) && ~isempty(imb_info)
    ima_path = fullfile(image_folder, ima_info(1).name);
    imb_path = fullfile(image_folder, imb_info(1).name);
    
    fprintf('Processing LE file: %s\n', ima_path);
    fprintf('Processing HE file: %s\n', imb_path);
    
    ima = imread(ima_path);
    imb = imread(imb_path);
    
    if size(ima, 3) == 3 % 컬러 이미지인 경우
        ima = rgb2gray(ima);
    end
    
    if size(imb, 3) == 3 % 컬러 이미지인 경우
        imb = rgb2gray(imb);
    end
    
    ima = double(ima);
    imb = double(imb);
else
    error('LE 또는 HE 파일을 찾을 수 없습니다.');
end

% 각 이미지 파일 불러오고 FMI 계산
for idx = 3:length(image_files) % LE와 HE는 제외하고 처리
    % 파일 이름 패턴 생성 (예: aMSR13.*, DCT13.*, ...)
    file_pattern = sprintf('%s%d', image_files{idx}, i);

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
        
        % FMI 메트릭 계산
        metrics(idx - 2) = fmi(ima, imb, img); % FMI 함수 사용
    else
        fprintf('파일 %s를 찾을 수 없습니다.\n', file_pattern);
        metrics(idx - 2) = NaN; % 파일이 없을 때 NaN 값으로 설정
    end
end

% 결과 출력
fprintf('Metrics for i=%d:\n', i);
fprintf('%.4f\n', metrics);
