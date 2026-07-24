% 폴더 경로 설정
input_folder = 'C:\Users\tilti\OneDrive\clahe_images\sh_method\proposed';
output_file = 'C:\Users\tilti\Downloads\score\image_quality_sorted_pro.xlsx';

% 출력 폴더 확인 및 생성
output_dir = fileparts(output_file);
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% 이미지 목록 가져오기
img_files = dir(fullfile(input_folder, '*.tif'));

fprintf('총 %d개 이미지 파일 발견\n', length(img_files));

if isempty(img_files)
    error('지정된 폴더에서 .tif 파일을 찾을 수 없습니다: %s', input_folder);
end

% 파일명에서 숫자 추출 및 정렬
file_info = struct('name', {}, 'number', {}, 'index', {});

for i = 1:length(img_files)
    fname = img_files(i).name;
    
    % 괄호 안 숫자 추출 - 여러 패턴 지원
    number_match = regexp(fname, '\((\d+)\)', 'tokens');
    
    if ~isempty(number_match)
        file_number = str2double(number_match{1}{1});
    else
        % 괄호가 없으면 파일명에서 숫자 찾기
        number_match = regexp(fname, '(\d+)', 'tokens');
        if ~isempty(number_match)
            file_number = str2double(number_match{1}{1});
        else
            file_number = i; % 숫자가 없으면 순서대로
        end
    end
    
    file_info(i).name = fname;
    file_info(i).number = file_number;
    file_info(i).index = i;
end

% 숫자 순서대로 정렬
[~, sort_idx] = sort([file_info.number]);
sorted_files = file_info(sort_idx);

fprintf('파일 정렬 완료 (숫자 순서대로)\n');

% 결과 저장용 cell 초기화 (가로 형태)
results = cell(length(img_files)+1, 4);

% 헤더 설정
results(1,:) = {'Image_Number', 'NIQE', 'BRISQUE', 'PIQE'};

% 정렬된 순서대로 이미지 처리
for i = 1:length(sorted_files)
    try
        fname = sorted_files(i).name;
        fpath = fullfile(input_folder, fname);
        img_number = sorted_files(i).number;
        
        % 파일 존재 확인
        if ~exist(fpath, 'file')
            warning('파일을 찾을 수 없습니다: %s', fname);
            continue;
        end
        
        fprintf('처리 중: (%d) %s\n', img_number, fname);
        
        img = imread(fpath);
        
        % Grayscale 변환
        if size(img, 3) == 3
            img_gray = rgb2gray(img);
        else
            img_gray = img;
        end
        
        % 점수 계산
        score_niqe = niqe(img_gray);
        score_brisque = brisque(img_gray);
        score_piqe = piqe(img_gray);
        
        % 가로로 데이터 입력 (행: 이미지 번호, 열: 각 지표)
        results{i+1, 1} = img_number;           % 이미지 번호
        results{i+1, 2} = score_niqe;           % NIQE 점수
        results{i+1, 3} = score_brisque;        % BRISQUE 점수
        results{i+1, 4} = score_piqe;           % PIQE 점수
        
        fprintf('  └─ NIQE: %.3f, BRISQUE: %.3f, PIQE: %.3f\n', ...
                score_niqe, score_brisque, score_piqe);
                
    catch ME
        warning('이미지 처리 실패: %s - %s', fname, ME.message);
        
        % 에러 발생시에도 구조 유지
        results{i+1, 1} = img_number;
        results{i+1, 2} = NaN;
        results{i+1, 3} = NaN;
        results{i+1, 4} = NaN;
    end
end

% Excel 파일로 저장
writecell(results, output_file);

fprintf('\n🎯 숫자 순서대로 정렬된 품질 점수 저장 완료!\n');
fprintf('📁 저장 위치: %s\n', output_file);
fprintf('📊 총 %d개 이미지 처리 완료\n', length(sorted_files));

% 결과 미리보기 (처음 5개)
fprintf('\n📋 결과 미리보기:\n');
fprintf('%-12s %-8s %-10s %-8s\n', 'Image_Number', 'NIQE', 'BRISQUE', 'PIQE');
fprintf('%-12s %-8s %-10s %-8s\n', '============', '========', '==========', '========');

for i = 2:min(7, size(results,1)) % 헤더 제외하고 처음 5개만
    if isnumeric(results{i,1})
        fprintf('%-12d %-8.3f %-10.3f %-8.3f\n', ...
                results{i,1}, results{i,2}, results{i,3}, results{i,4});
    end
end

if size(results,1) > 7
    fprintf('... (총 %d개 이미지)\n', length(sorted_files));
end