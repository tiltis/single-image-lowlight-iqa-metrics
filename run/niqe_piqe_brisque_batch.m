% 폴더 경로 설정
input_folder = 'C:\opencv\2mon\results\vs\기본(my real clahe)\sig';
output_file = 'C:\Users\tilti\Downloads\score\0928.xlsx';

% 이미지 목록 가져오기
img_files = dir(fullfile(input_folder, '*.jpg')); % 필요시 *.png로 수정

% 결과 저장용 cell 초기화
results = cell(length(img_files)+1, 4);
results(1,:) = {'Filename', 'NIQE Score', 'BRISQUE Score', 'PIQE Score'};

% 이미지 순회하면서 세 가지 스코어 계산
for i = 1:length(img_files)
    fname = img_files(i).name;
    fpath = fullfile(input_folder, fname);
    img = imread(fpath);
    
    % Grayscale 변환 (BRISQUE, NIQE, PIQE 모두 grayscale 기준)
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
    else
        img_gray = img;
    end

    % NIQE, BRISQUE, PIQE 계산
    score_niqe = niqe(img_gray);
    score_brisque = brisque(img_gray);
    score_piqe = piqe(img_gray);

    % 결과 저장
    results{i+1,1} = fname;
    results{i+1,2} = score_niqe;
    results{i+1,3} = score_brisque;
    results{i+1,4} = score_piqe;
end

% Excel 파일로 저장
writecell(results, output_file);
disp('🎯 NIQE, BRISQUE, PIQE 점수 계산 및 저장 완료!');
