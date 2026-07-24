% 폴더 경로 설정
base_folder = 'C:/Users/PC00/Desktop/score/metrics/origtestresult/';
num_tests = 13;  % test1부터 test13까지 처리

% 처리할 이미지 파일 이름 리스트 (확장자 무관)
image_files = {'aMSR', 'DCT', 'EF', 'FMMR', 'GRW', 'MITM'}; % HE와 LE는 제외

% 엑셀 파일 저장을 위한 변수
excel_file = 'SSEQ_Quality_Scores.xlsx';  
header = [{'SSEQ'}, arrayfun(@num2str, 1:num_tests, 'UniformOutput', false)];  % 엑셀 헤더 설정
row_names = {'MSR', 'DCT', 'EF', 'FMMR', 'GRW', 'MITM'};  % 행 이름 설정
sseq_scores_matrix = NaN(length(image_files), num_tests);  % 결과를 저장할 행렬

% 각 폴더에 대해 SSEQ 품질 점수 계산
for i = 1:num_tests
    % 각 폴더 경로 설정
    image_folder = sprintf('%stest%d', base_folder, i);
    
    % 폴더 내 모든 파일 정보 가져오기
    all_files = dir(image_folder);
    disp({all_files.name}); % 파일 이름 목록 출력
    
    % 각 이미지 파일 불러오고 SSEQ 품질 점수 계산
    for idx = 1:length(image_files)
        % 파일 이름 패턴 생성 (예: aMSR1, DCT1, ...)
        file_pattern = sprintf('%s%d', image_files{idx}, i);
        
        % 해당 패턴에 맞는 파일 찾기
        file_info = all_files(~[all_files.isdir] & contains({all_files.name}, file_pattern, 'IgnoreCase', true));
        
        % 파일이 존재하는 경우에만 처리
        if ~isempty(file_info)
            file_path = fullfile(image_folder, file_info(1).name); % 첫 번째 일치하는 파일 경로
            
            % 디버깅: 파일 경로 확인
            fprintf('Processing file: %s\n', file_path);
            
            % 이미지 불러오기
            img = imread(file_path);
            
            % SSEQ 함수 호출하여 품질 점수 계산
            sseq_score = SSEQ(img);
            sseq_scores_matrix(idx, i) = sseq_score; % 품질 점수 저장
        else
            fprintf('파일 %s를 찾을 수 없습니다.\n', file_pattern);
        end
    end
end

% 엑셀 파일로 결과 저장
xlswrite(excel_file, [header; [row_names', num2cell(sseq_scores_matrix)]]);  % 엑셀로 내보내기
disp('모든 결과가 엑셀 파일에 저장되었습니다.');
