% 원하는 i 값을 설정 (예: 1, 2 등)
i = 1;  % test1 폴더를 대상으로 합니다.

% 이미지가 저장된 폴더 경로 (동적 경로 설정)
image_folder = 'C:/Users/PC00/Desktop/score/metrics/origtestresult/MITM'; % 실제 폴더 경로로 설정

% 처리할 이미지 파일 이름 리스트 (확장자 무관)
image_files = {'MITM1', 'MITM2', 'MITM3', 'MITM4', 'MITM5', 'MITM6', 'MITM7', 'MITM8', 'MITM9', 'MITM10', 'MITM11', 'MITM12'}; 

% MOS 값을 저장할 배열
mos_scores = zeros(1, length(image_files));

% 폴더 내 모든 파일 정보 가져오기
all_files = dir(fullfile(image_folder, '*')); % 모든 파일 목록 가져오기
disp({all_files.name}); % 파일 이름 목록 출력

% 각 이미지 파일 불러오고 MOS 계산
for idx = 1:length(image_files)
    % 파일 이름 패턴 생성 (예: MITM1, MITM2, ...)
    file_pattern = image_files{idx};  % 확장자 없이 이름만 사용
    
    % 해당 패턴에 맞는 파일 찾기
    file_info = all_files(~[all_files.isdir] & contains({all_files.name}, file_pattern, 'IgnoreCase', true));

    % 파일이 존재하는 경우에만 처리
    if ~isempty(file_info)
        file_path = fullfile(image_folder, file_info(1).name); % 첫 번째 일치하는 파일 경로
        
        % 디버깅: 파일 경로 확인
        fprintf('Processing file: %s\n', file_path);
        
        % 이미지 불러오기
        img = imread(file_path);
        
        % jpeg_2000 함수 호출하여 MOS 계산
        mos_score = jpeg_2000(img);
        mos_scores(idx) = mos_score; % MOS 점수 저장
    else
        fprintf('파일 %s를 찾을 수 없습니다.\n', file_pattern);
        mos_scores(idx) = NaN; % 파일이 없을 때 NaN 값으로 설정
    end
end

% 결과 출력
fprintf('MOS Scores for i=%d:\n', i);
fprintf('%.4f\n', mos_scores);

% 엑셀 파일로 결과 저장
excel_file = 'MOS_Scores_MITM.xlsx';  % 저장할 파일명
header = image_files;  % 데이터 헤더 설정
data = num2cell(mos_scores);  % MOS 스코어를 셀 배열로 변환
xlswrite(excel_file, [header; data]);  % 엑셀로 내보내기
