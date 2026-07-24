% 그룹 정의
groups = {'Jins', 'Yujung', 'MSR', 'OpenCV'};
num_per_group = 35;

% 결과 저장용 cell (헤더 포함)
results = cell(num_per_group * numel(groups) + 1, 3);
results(1, :) = {'파일명', 'ENIQA 점수', '그룹'};

% 인덱스 시작
row = 2;

% 루프 돌며 점수 계산
for g = 1:length(groups)
    group = groups{g};
    for n = 1:num_per_group
        filename = sprintf('%s (%d).JPG', group, n);
        filepath = fullfile('C:/opencv/4mon/score', filename);

        try
            score = ENIQA(filepath);
        catch ME
            score = NaN;
            warning('%s 읽는 중 오류: %s', filename, ME.message);
        end

        results{row, 1} = filename;
        results{row, 2} = score;
        results{row, 3} = group;
        row = row + 1;
    end
end

% 셀 → 테이블 → 엑셀 저장
T = cell2table(results(2:end,:), 'VariableNames', results(1,:));
writetable(T, 'C:/opencv/4mon/eniqa_scores.xlsx');


fprintf("✅ ENIQA 점수 140장 계산 완료, 'eniqa_scores.xlsx' 저장됨\n");
