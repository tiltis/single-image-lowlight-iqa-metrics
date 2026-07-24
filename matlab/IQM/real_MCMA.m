%% complete_MCMA_run.m - 전체 164개 파일 처리 완료 버전
clear; clc;

%% 경로 설정
original_dir  = 'C:\opencv\4mon\allmain';
enhanced_dir  = 'C:\opencv\2mon\results\vs\기본(my real clahe)\allmain_for_LLE';
output_excel  = 'C:\Users\tilti\OneDrive\journal\0922(리비전)\MCMA_LLE_sorted.xlsx';

%% 이미지 확장자
image_ext = {'.jpg','.jpeg','.png','.bmp','.tif','.tiff', ...
             '.JPG','.JPEG','.PNG','.BMP','.TIF','.TIFF'};

%% 유틸: 괄호 안 숫자 추출
extract_idx = @(s) local_extract_index(s);

%% 폴더 스캔
fprintf('파일 스캔 중...\n');
orig_files = dir(original_dir);  orig_files = orig_files(~[orig_files.isdir]);
enh_files  = dir(enhanced_dir);  enh_files = enh_files(~[enh_files.isdir]);

orig_files = local_filter_images(orig_files, image_ext);
enh_files  = local_filter_images(enh_files,  image_ext);

orig_names = {orig_files.name};
enh_names  = {enh_files.name};

orig_idx = cellfun(extract_idx, orig_names);
enh_idx  = cellfun(extract_idx, enh_names);

% 유효 인덱스만 남기기
valid_orig = ~isnan(orig_idx);
valid_enh  = ~isnan(enh_idx);
orig_files = orig_files(valid_orig);  orig_idx = orig_idx(valid_orig);
enh_files  = enh_files(valid_enh);    enh_idx  = enh_idx(valid_enh);

% 인덱스 → 파일 경로 매핑 (중복 인덱스가 있으면 첫 번째 파일 사용)
orig_map = containers.Map('KeyType','double','ValueType','char');
for i = 1:numel(orig_files)
    id = orig_idx(i);
    p  = fullfile(original_dir, orig_files(i).name);
    if ~isKey(orig_map, id), orig_map(id) = p; end
end
enh_map = containers.Map('KeyType','double','ValueType','char');
for i = 1:numel(enh_files)
    id = enh_idx(i);
    p  = fullfile(enhanced_dir, enh_files(i).name);
    if ~isKey(enh_map, id), enh_map(id) = p; end
end

% 1~164 전체 아이디 생성 후, 둘 다 있는 교집합만 처리
target_ids = 1:164;
common_ids = target_ids( ismember(target_ids, intersect(cell2mat(keys(orig_map)), cell2mat(keys(enh_map)))) );

fprintf('매칭된 인덱스 수: %d / 164\n', numel(common_ids));

%% MCMA 계산 시작
fprintf('\n=== MCMA 계산 시작 ===\n');
results = nan(numel(common_ids), 2);
n_ok = 0; n_err = 0;

% 진행상황 표시를 위한 변수
total_files = numel(common_ids);
progress_step = max(1, floor(total_files / 10)); % 10% 단위로 진행상황 표시

for k = 1:numel(common_ids)
    idx = common_ids(k);
    orig_path = orig_map(idx);
    enh_path  = enh_map(idx);

    % 진행상황 표시
    if mod(k-1, progress_step) == 0 || k == total_files
        fprintf('진행: %d/%d (%.1f%%) - 현재 인덱스: %d\n', k, total_files, 100*k/total_files, idx);
    end

    try
        Ilow_raw = imread(orig_path);
        Ienh_raw = imread(enh_path);

        % 일부 이미지가 4채널(CMYK/alpha)일 수 있어 3채널로 축소
        if ndims(Ilow_raw)==3 && size(Ilow_raw,3)>3, Ilow_raw = Ilow_raw(:,:,1:3); end
        if ndims(Ienh_raw)==3 && size(Ienh_raw,3)>3, Ienh_raw = Ienh_raw(:,:,1:3); end

        % 해상도 맞추기(향상본을 원본 크기로)
        if any(size(Ilow_raw,1:2) ~= size(Ienh_raw,1:2))
            Ienh_raw = imresize(Ienh_raw, [size(Ilow_raw,1), size(Ilow_raw,2)]);
        end

        % MCMA가 요구하는 8bit 그레이스케일로 안전 변환
        Ilow_u8 = local_to_uint8_gray(Ilow_raw);
        Ienh_u8 = local_to_uint8_gray(Ienh_raw);

        % 점수 계산
        MCMAval = MCMA(Ilow_u8, Ienh_u8);

        n_ok = n_ok + 1;
        
        % 첫 번째와 마지막 몇 개는 점수 표시
        if k <= 3 || k > total_files - 3
            fprintf('  인덱스 %d: MCMA = %.4f\n', idx, MCMAval);
        end
        
    catch ME
        warning('Error at index %d (%s | %s): %s', idx, orig_path, enh_path, ME.message);
        MCMAval = NaN;
        n_err   = n_err + 1;
    end

    results(k,:) = [idx, MCMAval];
end

%% 결과 정리 및 저장
fprintf('\n=== 결과 정리 중 ===\n');

% 결과를 1~164 순서로 테이블화 (없는 항목은 NaN)
T = table((1:164)', NaN(164,1), 'VariableNames', {'Index','MCMA_Score'});
[lia, loc] = ismember((1:164)', common_ids');
T.MCMA_Score(lia) = results(loc(lia), 2);

% 저장 폴더 생성 보장
[out_dir,~,~] = fileparts(output_excel);
if ~isempty(out_dir) && ~exist(out_dir,'dir')
    fprintf('출력 폴더 생성: %s\n', out_dir);
    mkdir(out_dir); 
end

fprintf('엑셀 파일 저장 중: %s\n', output_excel);
writetable(T, output_excel, 'FileType','spreadsheet');

%% 최종 결과 요약
fprintf('\n=== 최종 결과 요약 ===\n');
fprintf('완료! 저장: %s\n', output_excel);
fprintf('성공: %d, 에러: %d, 누락(원본/개선 중 한쪽 없음): %d\n', n_ok, n_err, 164 - numel(common_ids));

% 통계 정보 출력
valid_scores = T.MCMA_Score(~isnan(T.MCMA_Score));
if ~isempty(valid_scores)
    fprintf('\nMCMA 점수 통계:\n');
    fprintf('  평균: %.4f\n', mean(valid_scores));
    fprintf('  표준편차: %.4f\n', std(valid_scores));
    fprintf('  최소: %.4f (인덱스 %d)\n', min(valid_scores), T.Index(T.MCMA_Score == min(valid_scores)));
    fprintf('  최대: %.4f (인덱스 %d)\n', max(valid_scores), T.Index(T.MCMA_Score == max(valid_scores)));
end

fprintf('\n처리 완료!\n');

%% -------------------- 로컬 유틸 함수들 --------------------

function files = local_filter_images(files, image_ext)
    keep = false(size(files));
    for i = 1:numel(files)
        [~,~,e] = fileparts(files(i).name);
        keep(i) = ismember(lower(e), lower(image_ext));
    end
    files = files(keep);
end

function idx = local_extract_index(filename)
    tok = regexp(filename, '\((\d+)\)', 'tokens', 'once');
    if isempty(tok), idx = NaN; else, idx = str2double(tok{1}); end
end

function Iu8 = local_to_uint8_gray(I)
    % 그레이스케일화
    if ndims(I)==3
        I = rgb2gray(I);
    end
    % 다양한 타입을 안전하게 uint8(0..255)로 변환
    switch class(I)
        case 'uint8'
            Iu8 = I;
        case 'uint16'
            Iu8 = uint8(round(double(I) / 257));   % 0..65535 → 0..255
        case 'double'
            % double이 [0,1] 또는 [0,255]일 수 있으니 자동 판별
            mx = max(I(:)); mn = min(I(:));
            if mx<=1.0 && mn>=0.0
                Iu8 = im2uint8(I);                 % [0,1] → 0..255
            else
                Iu8 = uint8(round(I));             % 가정: 이미 0..255 범위
            end
        case 'single'
            mx = max(I(:)); mn = min(I(:));
            if mx<=1.0 && mn>=0.0
                Iu8 = uint8(round(255*I));
            else
                Iu8 = uint8(round(I));
            end
        otherwise
            % 기타 정수형 등은 double로 올린 뒤 클리핑
            Id = double(I);
            Id = max(0, min(255, Id));
            Iu8 = uint8(round(Id));
    end
end

%% -------------------- 수정된 MCMA 함수들 --------------------

function MCMAval = MCMA(Ilow, Ienh)
    % 입력 타입 확인 및 변환
    if numel(size(Ilow))==3
        Ilow = rgb2gray(Ilow);
    end
    if numel(size(Ienh))==3
        Ienh = rgb2gray(Ienh);
    end
    
    % uint8로 명시적 변환
    Ilow = uint8(Ilow);
    Ienh = uint8(Ienh);
    
    try
        [hlow, henh] = denoise(Ilow, Ienh);
        PUval = getPU(Ienh);
        HSDval = getHSD(hlow, henh);
        DROval = getDRO(henh);
        
        a = -0.7; b = -0.3; c = 0.4;
        MCMAval = ((a * PUval + b * HSDval + c * DROval) + 1) / 1.4;
    catch ME
        warning('MCMA 계산 중 오류: %s', ME.message);
        MCMAval = NaN;
    end
end

function DROval = getDRO(henh)
    idx = find(henh);
    if isempty(idx)
        DROval = 0;
        return;
    end
    dyn = idx(end) - idx(1);
    maxDyn = 256;
    DROval = dyn / maxDyn;
end

function PUval = getPU(Ienh)
    Ienh = double(Ienh);
    PUval = [];
    for i = 2:size(Ienh,1)-1
        for j = 2:size(Ienh,2)-1
            block = Ienh(i-1:i+1, j-1:j+1);
            PUval(i,j) = sum(sum( 1./(abs(Ienh(i,j)-block)+1) ))/9;
        end
    end
    if isempty(PUval)
        PUval = 0;
    else
        PUval = mean(mean(PUval));
    end
end

function HSDval = getHSD(hlow, henh)
    try
        values_low = find(hlow);
        values_enh = find(henh);
        
        if isempty(values_low) || isempty(values_enh)
            HSDval = 0;
            return;
        end
        
        start_low = values_low(1); end_low = values_low(end);
        start_enh = values_enh(1); end_enh = values_enh(end);

        dynamic_low = hlow(start_low:end_low)';   % 열→행
        dynamic_enh = henh(start_enh:end_enh)';
        
        if isempty(dynamic_low) || isempty(dynamic_enh)
            HSDval = 0;
            return;
        end

        % upsample to 256 length (low)
        rate = 256/length(dynamic_low);
        stretched_low = zeros(1,256);
        for i=1:length(dynamic_low)
            destidx = ceil((i-1)*rate + 1);
            if destidx <= 256
                stretched_low(destidx) = dynamic_low(i);
            end
        end
        
        stretch_low_nz = find(stretched_low);
        if length(stretch_low_nz) < 2
            HSDval = 0;
            return;
        end
        i_stretched_low = interp1(stretch_low_nz, stretched_low(stretch_low_nz), 1:length(stretched_low), 'linear', 'extrap');

        % upsample to 256 length (enh)
        rate = 256/length(dynamic_enh);
        stretched_enh = zeros(1,256);
        for i=1:length(dynamic_enh)
            destidx = ceil((i-1)*rate + 1);
            if destidx <= 256
                stretched_enh(destidx) = dynamic_enh(i);
            end
        end
        
        stretch_enh_nz = find(stretched_enh);
        if length(stretch_enh_nz) < 2
            HSDval = 0;
            return;
        end
        i_stretched_enh = interp1(stretch_enh_nz, stretched_enh(stretch_enh_nz), 1:length(stretched_enh), 'linear', 'extrap');

        % NaN 보간 (안전한 방법)
        nanz = find(isnan(i_stretched_low));
        for i=1:length(nanz)
            if nanz(i) > 1
                i_stretched_low(nanz(i)) = i_stretched_low(nanz(i)-1);
            else
                i_stretched_low(nanz(i)) = 0;
            end
        end
        
        nanz = find(isnan(i_stretched_enh));
        for i=1:length(nanz)
            if nanz(i) > 1
                i_stretched_enh(nanz(i)) = i_stretched_enh(nanz(i)-1);
            else
                i_stretched_enh(nanz(i)) = 0;
            end
        end

        % 정규화 및 8-bin 블록 비교
        stretched_low = stretched_low / (sum(stretched_low) + eps);
        stretched_enh = stretched_enh / (sum(stretched_enh) + eps);
        
        bin_length = 8;
        diffs = zeros(bin_length, 256/bin_length);
        
        for j=1:bin_length
            for i=1:256/bin_length
                start_idx = (i-1)*bin_length + j;
                end_idx = i*bin_length + j - 1;
                
                if end_idx > 256
                    % 순환 처리
                    overflow = end_idx - 256;
                    bin_low = [stretched_low(start_idx:256), stretched_low(1:overflow)];
                    bin_enh = [stretched_enh(start_idx:256), stretched_enh(1:overflow)];
                else
                    bin_low = stretched_low(start_idx:end_idx);
                    bin_enh = stretched_enh(start_idx:end_idx);
                end
                
                diffs(j,i) = abs(sum(bin_enh)-sum(bin_low));
            end
        end
        
        HSDval = sum(diffs(:)) / (8 * 2); % MAXHSD=16 가정
        
    catch ME
        warning('HSD 계산 중 오류: %s', ME.message);
        HSDval = 0;
    end
end

function [denoisedHLow, denoisedHEnh] = denoise(Ilow, Ienh)
    try
        % 확실히 uint8로 변환
        Ilow = uint8(Ilow);
        Ienh = uint8(Ienh);
        
        hlow = imhist(Ilow);
        henh = imhist(Ienh);
        
        thr = 0.001; 
        pix_thr = round(numel(Ilow) * thr);

        % remove salt (high end)
        idx = 1;
        for i = 2:256
            if sum(henh(end-i+1:end)) < pix_thr
                idx = i; 
            else
                break; 
            end
        end
        if idx > 1
            henh(end-idx+1:end) = 0; 
        end

        idx = 1;
        for i = 2:256
            if sum(hlow(end-i+1:end)) < pix_thr
                idx = i; 
            else
                break; 
            end
        end
        if idx > 1
            hlow(end-idx+1:end) = 0; 
        end

        % remove pepper (low end)
        idx = 1;
        for i = 2:256
            if sum(henh(1:i)) < pix_thr
                idx = i; 
            else
                break; 
            end
        end
        if idx > 1
            henh(1:idx) = 0; 
        end

        idx = 1;
        for i = 2:256
            if sum(hlow(1:i)) < pix_thr
                idx = i; 
            else
                break; 
            end
        end
        if idx > 1
            hlow(1:idx) = 0; 
        end

        denoisedHLow = hlow;
        denoisedHEnh = henh;
        
    catch ME
        warning('denoise 함수에서 오류: %s', ME.message);
        % 오류 시 원본 히스토그램 반환
        denoisedHLow = imhist(uint8(Ilow));
        denoisedHEnh = imhist(uint8(Ienh));
    end
end