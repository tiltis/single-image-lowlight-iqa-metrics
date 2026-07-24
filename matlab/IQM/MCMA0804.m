% MCMA 배치 계산 및 엑셀 저장 스크립트
% 모든 이미지 쌍에 대해 MCMA 값을 계산하고 결과를 엑셀로 저장

% 폴더 경로 설정
original_folder = 'C:\opencv\4mon\allmain\';
enhanced_folder = 'C:\Users\tilti\OneDrive\clahe_images\sh_method\Reinhard_tool\result\2025.07.29.14.38.18\';
output_folder = 'C:\Users\tilti\OneDrive\논문\';
output_filename = 'MCMA_Results_reinhard.xlsx';

% 원본 이미지 파일 목록 가져오기
original_files = dir(fullfile(original_folder, '*.jpg'));
if isempty(original_files)
    original_files = dir(fullfile(original_folder, '*.png'));
end
if isempty(original_files)
    original_files = dir(fullfile(original_folder, '*.bmp'));
end

% 개선된 이미지 파일 목록 가져오기
enhanced_files = dir(fullfile(enhanced_folder, '*.jpg'));
if isempty(enhanced_files)
    enhanced_files = dir(fullfile(enhanced_folder, '*.png'));
end
if isempty(enhanced_files)
    enhanced_files = dir(fullfile(enhanced_folder, '*.tif'));
end

fprintf('원본 이미지 %d개, 개선 이미지 %d개 발견\n', length(original_files), length(enhanced_files));

% 결과 저장용 변수
results = [];
image_pairs = {};

% 각 원본 이미지에 대해 처리
for i = 1:length(original_files)
    original_name = original_files(i).name;
    
    % 괄호 안의 숫자 추출
    pattern = '\((\d+)\)';
    tokens = regexp(original_name, pattern, 'tokens');
    
    if ~isempty(tokens)
        number = str2double(tokens{1}{1});
        
        % 같은 번호를 가진 개선된 이미지 찾기
        enhanced_found = false;
        for j = 1:length(enhanced_files)
            enhanced_name = enhanced_files(j).name;
            enhanced_tokens = regexp(enhanced_name, pattern, 'tokens');
            
            if ~isempty(enhanced_tokens)
                enhanced_number = str2double(enhanced_tokens{1}{1});
                
                if number == enhanced_number
                    % 매칭되는 쌍 발견
                    fprintf('처리 중: (%d) %s <-> %s\n', number, original_name, enhanced_name);
                    
                    try
                        % 이미지 읽기
                        original_path = fullfile(original_folder, original_name);
                        enhanced_path = fullfile(enhanced_folder, enhanced_name);
                        
                        Ilow = imread(original_path);
                        Ienh = imread(enhanced_path);
                        
                        % MCMA 계산
                        mcma_value = MCMA(Ilow, Ienh);
                        
                        % 결과 저장
                        results = [results; number, mcma_value];
                        image_pairs{end+1, 1} = number;
                        image_pairs{end, 2} = original_name;
                        image_pairs{end, 3} = enhanced_name;
                        image_pairs{end, 4} = mcma_value;
                        
                        fprintf('  -> MCMA 값: %.6f\n', mcma_value);
                        
                    catch ME
                        fprintf('  -> 오류 발생: %s\n', ME.message);
                        results = [results; number, NaN];
                        image_pairs{end+1, 1} = number;
                        image_pairs{end, 2} = original_name;
                        image_pairs{end, 3} = enhanced_name;
                        image_pairs{end, 4} = NaN;
                    end
                    
                    enhanced_found = true;
                    break;
                end
            end
        end
        
        if ~enhanced_found
            fprintf('경고: (%d) %s에 대응하는 개선 이미지를 찾을 수 없습니다.\n', number, original_name);
        end
    else
        fprintf('경고: %s에서 괄호 안 숫자를 찾을 수 없습니다.\n', original_name);
    end
end

% 결과 정렬 (괄호 안 숫자 순서대로)
if ~isempty(results)
    [~, sort_idx] = sort(results(:, 1));
    results = results(sort_idx, :);
    image_pairs = image_pairs(sort_idx, :);
    
    % 엑셀 파일로 저장
    output_path = fullfile(output_folder, output_filename);
    
    % 헤더 생성
    headers = {'Image_Number', 'Original_Filename', 'Enhanced_Filename', 'MCMA_Value'};
    
    % 데이터 준비
    excel_data = [headers; image_pairs];
    
    % 엑셀 파일 쓰기
    try
        writecell(excel_data, output_path, 'Sheet', 'MCMA_Results');
        fprintf('\n결과가 성공적으로 저장되었습니다: %s\n', output_path);
        fprintf('총 %d개 이미지 쌍 처리 완료\n', size(results, 1));
        
        % 통계 정보 출력
        valid_results = results(~isnan(results(:, 2)), 2);
        if ~isempty(valid_results)
            fprintf('\n=== MCMA 통계 ===\n');
            fprintf('평균: %.6f\n', mean(valid_results));
            fprintf('표준편차: %.6f\n', std(valid_results));
            fprintf('최솟값: %.6f\n', min(valid_results));
            fprintf('최댓값: %.6f\n', max(valid_results));
            fprintf('중앙값: %.6f\n', median(valid_results));
        end
        
    catch ME
        fprintf('엑셀 파일 저장 중 오류 발생: %s\n', ME.message);
        
        % CSV로 대체 저장 시도
        csv_path = fullfile(output_folder, 'MCMA_Results.csv');
        try
            writematrix([results(:,1), results(:,2)], csv_path);
            fprintf('CSV 파일로 대체 저장: %s\n', csv_path);
        catch
            fprintf('CSV 저장도 실패했습니다.\n');
        end
    end
else
    fprintf('처리된 이미지 쌍이 없습니다. 파일 경로와 이름을 확인해주세요.\n');
end

% MCMA 함수 (기존 코드)
function MCMAval = MCMA(Ilow, Ienh)
% Comments:
% 1- This code only works for 8-bit gray-scale images

if numel( size( Ilow ) ) == 3
    Ilow = rgb2gray( Ilow );
end
if numel( size( Ienh ) ) == 3
    Ienh = rgb2gray( Ienh );
end

[hlow, henh] = denoise(Ilow, Ienh);

PUval = getPU(Ienh);
HSDval = getHSD(hlow, henh);
DROval = getDRO( henh );
a = -.7;
b = -.3;
c = .4;

MCMAval = ((a * PUval + b * HSDval + c * DROval) + 1) / 1.4;
end

%% ---------- DRO --------------
function DROval = getDRO( henh )
idx = find(henh);
dyn = idx(end) - idx(1);
maxDyn = 256;
DROval = dyn / maxDyn;
end

%% ---------- PU -------------
function PUval = getPU(Ienh)
Ienh = double(Ienh);
PUval = [];

for i = 2 : size( Ienh , 1 ) - 1
    for j = 2 : size( Ienh , 2 ) - 1
        block = Ienh( i - 1 : i + 1 , j - 1 : j + 1 );
        PUval( i , j ) = sum( sum( 1 ./ ( abs( Ienh( i , j ) - block ) + 1 ) ) ) / 9;        
    end
end

PUval = mean( mean( PUval ) );
end

%% ---------- HSD --------------
function HSDval = getHSD(hlow, henh)

values_low = find(hlow);
start_low = values_low(1);
end_low = values_low(end);

values_enh = find(henh);
start_enh = values_enh(1);
end_enh = values_enh(end);

dynamic_low = hlow(start_low:end_low)';
dynamic_enh = henh(start_enh:end_enh)';

% upsample
% low 
rate=256/length(dynamic_low);
stretched_low=zeros(1,256);
for i=1:length(dynamic_low)
    destidx=ceil((i-1)*rate+1);
    stretched_low(destidx)=dynamic_low(i);
end

% interpolate
stretch_low_nz=find(stretched_low);
i_stretched_low=interp1(stretch_low_nz, stretched_low(stretch_low_nz), 1:length(stretched_low));

rate=256/length(dynamic_enh);
stretched_enh=zeros(1,256);
for i=1:length(dynamic_enh)
    destidx=ceil((i-1)*rate+1);
    stretched_enh(destidx)=dynamic_enh(i);
end

% interpolate
stretch_enh_nz=find(stretched_enh);
i_stretched_enh=interp1(stretch_enh_nz, stretched_enh(stretch_enh_nz), 1:length(stretched_enh));

nanz=find(isnan(i_stretched_low));
for i=1:length(nanz)
    i_stretched_low(nanz(i))=i_stretched_low(nanz(i)-1);
end

nanz=find(isnan(i_stretched_enh));
for i=1:length(nanz)
    i_stretched_enh(nanz(i))=i_stretched_enh(nanz(i)-1);
end

out1 = [i_stretched_low;i_stretched_enh];

valsenh = length(dynamic_enh);

% out2 to be calculated 
% 8
stretched_low = stretched_low / sum(stretched_low);
stretched_enh = stretched_enh / sum(stretched_enh);
bin_length = 8;
diffs=[];
for j=1:bin_length
    for i=1:256/bin_length
        if (mod(j,bin_length)==1)
            bin_low=stretched_low((i-1)*bin_length+j:i*bin_length+j-1);
            bin_enh=stretched_enh((i-1)*bin_length+j:i*bin_length+j-1);            
        else
            if i==256/bin_length % exception
                bin_low=[stretched_low(end-bin_length+j:end), stretched_low(1:j-1)];
                bin_enh=[stretched_enh(end-bin_length+j:end), stretched_enh(1:j-1)];
            else % as usual
                bin_low=stretched_low((i-1)*bin_length+j:i*bin_length+j-1);
                bin_enh=stretched_enh((i-1)*bin_length+j:i*bin_length+j-1);
            end
        end
        diffs(j,i)=abs(sum(bin_enh)-sum(bin_low));
    end
end

HSDval = sum( sum( diffs ) ) / ( 8 * 2 ); % 8 * 2 is MAXHSD

end

%% ---------- De-noise -------------
function [denoisedHLow , denoisedHEnh] = denoise( Ilow , Ienh )

hlow = imhist(uint8(Ilow));
henh = imhist(uint8(Ienh));

% remove salt & pepper - threshold = 0.001
thr = 0.001;
pix_thr = round(prod(size(Ilow)) * thr);
% remove salt 
idx = 1;
for i = 2 : 256
    if sum(henh(end - i + 1 : end)) < pix_thr
        idx = i;
    else
        break;
    end
end
if idx > 1
    henh(end - idx + 1 : end) = 0;
end

idx = 1;
for i = 2 : 256
    if sum(hlow(end - i + 1 : end)) < pix_thr
        idx = i;
    else
        break;
    end
end
if idx > 1
    hlow(end - idx + 1 : end) = 0;
end

% remove pepper
idx = 1;
for i = 2 : 256
    if sum(henh(1 : i)) < pix_thr
        idx = i;
    else
        break
    end
end
if idx > 1
    henh(1 : idx) = 0;
end

idx = 1;
for i = 2 : 256
    if sum(hlow(1 : i)) < pix_thr
        idx = i;
    else
        break;
    end
end
if idx > 1
    hlow(1 : idx) = 0;
end

denoisedHLow = hlow;
denoisedHEnh = henh;

end