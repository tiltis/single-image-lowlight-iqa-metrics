function MOS = jpeg_2000(img)
    % MOS 계산 초기화
    MOS = NaN;
    
    try
        % 그레이스케일 변환 (컬러 이미지일 경우)
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
    catch
        disp('Error converting to grayscale. Skipping image...');
        return;
    end

    try
        % 이미지를 [0, 1] 범위로 정규화
        img = im2double(img);
    catch
        disp('Error converting image to double. Skipping image...');
        return;
    end

    try
        % First Distortion Measure 계산
        S = FirstDistortionMeasure(img);
        if isnan(S) || S < 0
            disp('Invalid First Distortion Measure value.');
            return;
        end
        disp(['First Distortion Measure (S): ', num2str(S)]);
    catch
        disp('Error in FirstDistortionMeasure calculation.');
        return;
    end

    try
        % Second Distortion Measure 계산
        A = SecondDistortionMeasure(img);
        if isnan(A) || A < 0
            disp('Invalid Second Distortion Measure value.');
            return;
        end
        disp(['Second Distortion Measure (A): ', num2str(A)]);
    catch
        disp('Error in SecondDistortionMeasure calculation.');
        return;
    end

    try
        % Zero-Crossing Rate 계산
        Z = ZCRate(img);
        if isnan(Z) || Z < 0
            disp('Invalid Zero-Crossing Rate value.');
            return;
        end
        disp(['Zero-Crossing Rate (Z): ', num2str(Z)]);
    catch
        disp('Error in Zero-Crossing Rate calculation.');
        return;
    end

    try
        % 히스토그램 기반 특징 계산
        [H, Hf, V, Vf] = HistogramFeatures(img);
        if any([H, Hf, V, Vf] < 0)
            disp('Invalid Histogram Features values.');
            return;
        end
        disp(['Histogram Features: H=', num2str(H), ', Hf=', num2str(Hf), ...
              ', V=', num2str(V), ', Vf=', num2str(Vf)]);
    catch
        disp('Error in HistogramFeatures calculation.');
        return;
    end

    try
        % 품질 점수 C 계산
        gamma1 = 2.8507;  gamma2 = -3.4735; gamma3 = 22.1784;
        gamma4 = 2.2957;  gamma5 = 0.0096;  gamma6 = 0.3619;
        gamma7 = -0.3168; gamma8 = 0.0452;  gamma9 = 2.7841;

        C = (gamma1 * log(S+1) + gamma2 * log(A+1) + gamma3 * log(Z+gamma4)) * ...
            (gamma5 * log(Hf+1) + gamma6 * log(Vf+1) + gamma7 * log(H+1) + ...
             gamma8 * log(V+1) + gamma9);
        disp(['Combined Quality Metric (C): ', num2str(C)]);
    catch
        disp('Error in Combined Quality Metric calculation.');
        return;
    end

    try
        % 최종 MOS 계산
        b1 = 78.0058; b2 = 1.0346; b3 = 49.6925; b4 = 2.2622;

        MOS = (b1) / (1 + exp(-b2 * (C - b3))) + b4;
        disp(['MOS: ', num2str(MOS)]);
    catch
        disp('Error in MOS calculation.');
        MOS = NaN;
    end
end
