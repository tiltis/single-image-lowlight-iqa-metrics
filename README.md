# 단일영상 저조도 개선 정량적 평가 지표

GT(Ground Truth)가 없는 단일 영상 저조도 개선 결과를 평가하기 위한 **무참조(No-Reference) 화질 평가 지표** 모음이다. 저조도 개선 논문 실험에 사용한 MATLAB 코드, 원저자 공식 구현, 최신 딥러닝 기반 지표 실행 스크립트를 포함한다.

## 폴더 구조

```
run/        실행 스크립트 모음
matlab/     논문 실험에 사용한 MATLAB 코드 원본
  IQM/        IQM 통합 GUI 툴 및 개별 지표 함수
  metrics/    지표별 원본 코드 (번호별 폴더)
official/   원저자 공식 구현 (IL-NIQE, MUSIQ, MANIQA 등)
```

## run/ : 실행 스크립트

- 실행 가능한 스크립트는 전부 이 폴더에 위치
- MATLAB 스크립트는 파일 상단의 `input_folder`, `output_file` 경로를 환경에 맞게 수정 후 실행

| 스크립트 | 언어 | 기능 |
|---|---|---|
| `niqe_piqe_brisque_batch.m` | MATLAB | 폴더 내 이미지 전체의 NIQE, BRISQUE, PIQE 일괄 계산 후 엑셀 저장. MATLAB 내장 함수 사용 |
| `niqe_piqe_brisque_sorted.m` | MATLAB | 위와 동일하되 파일명 속 숫자 기준 정렬 저장. 오류 발생 시 NaN 처리 |
| `nima_batch.m` | MATLAB | MathWorks 사전학습 NIMA 네트워크 자동 다운로드 후 폴더별 미학 점수 계산 |
| `nima_flexible.m` | MATLAB | NIMA 점수를 하위 폴더 유무에 따라 폴더별/파일명별로 분류 정리 |
| `predictNIMAScore_Custom.m` | MATLAB | NIMA 점수 계산 함수 (위 두 스크립트가 호출) |
| `mcma_batch.m` | MATLAB | 여러 개선 기법 결과에 대한 MCMA 일괄 계산 |
| `MCMA.m` | MATLAB | MCMA 함수 본체. 저조도 원본과 개선 결과 쌍을 입력 |
| `lpips_batch.m` | MATLAB | LPIPS 유사도 일괄 계산 (자체 구현) |
| `modern_metrics.py` | Python | 최신 지표 일괄 계산. NIQE부터 MANIQA, CLIP-IQA, MUSIQ, TOPIQ까지 CSV로 출력 |

Python 스크립트 실행 예:

```bash
pip install pyiqa
python run/modern_metrics.py <이미지_폴더> --metrics niqe brisque piqe ilniqe musiq maniqa clipiqa topiq_nr
```

## 지표 설명

### 전통 무참조(NR) 지표

점수가 **낮을수록** 좋은 지표이다.

| 지표 | 위치 | 설명 |
|---|---|---|
| NIQE | `run/niqe_piqe_brisque_batch.m` | 자연 영상 통계(NSS)와의 거리로 평가. 학습 불필요 |
| BRISQUE | `run/niqe_piqe_brisque_batch.m` | NSS 특징 + SVM 회귀. LIVE DB로 학습 |
| PIQE | `run/niqe_piqe_brisque_batch.m` | 블록 단위 왜곡 분석. 학습 불필요 |
| IL-NIQE | `official/ILNIQE/` | NIQE 개선판. 색상, 그래디언트, 주파수 특징 추가 (Zhang et al., TIP 2015) |
| SSEQ | `matlab/metrics/16_SSEQ/` | 공간/스펙트럼 엔트로피 기반 |
| ENIQA | `matlab/metrics/13_ENIQA/` | 엔트로피 기반 NR-IQA |
| CPBDM | `matlab/metrics/6_CPBDM/` | 블러 검출 확률 기반 선명도 평가 |
| JNBM | `matlab/metrics/7_JNBM/` | Just Noticeable Blur 기반 선명도 평가 |
| S3 | `matlab/metrics/9_S3/` | 스펙트럼 기울기 + 공간 대비 기반 선명도 맵 생성 |
| LPC-SI | `matlab/metrics/8_LPC_SI/` | 국소 위상 일관성 기반 선명도 평가 |

### 대비/개선 특화 지표

| 지표 | 위치 | 설명 |
|---|---|---|
| MCMA | `run/MCMA.m` | 대비 개선 품질 평가. 원본과 개선 결과 쌍 입력. 높을수록 좋음 |
| CEIQ | `matlab/metrics/15_CEIQ/` | 대비 개선 영상 품질 평가 (SVM 모델 포함). 높을수록 좋음 |
| NIMA | `run/nima_batch.m` | CNN 기반 미학 점수 (1~10). 높을수록 좋음 |

### 최신 딥러닝 NR 지표 (2021 이후)

점수가 **높을수록** 좋은 지표이다. 전부 `run/modern_metrics.py`(pyiqa)로 계산 가능하다.

| 지표 | 발표 | 논문 | 원저자 코드 |
|---|---|---|---|
| MUSIQ | ICCV 2021 | [arXiv:2108.05997](https://arxiv.org/abs/2108.05997) | `official/MUSIQ/` |
| MANIQA | CVPRW 2022 | [arXiv:2204.08958](https://arxiv.org/abs/2204.08958) | `official/MANIQA/` |
| CLIP-IQA | AAAI 2023 | [arXiv:2207.12396](https://arxiv.org/abs/2207.12396) | `official/CLIP-IQA/` |
| LIQE | CVPR 2023 | [arXiv:2303.14968](https://arxiv.org/abs/2303.14968) | `official/LIQE/` |
| TOPIQ | TIP 2024 | [arXiv:2308.03060](https://arxiv.org/abs/2308.03060) | `official/IQA-PyTorch/` |
| ARNIQA | WACV 2024 | [arXiv:2310.14918](https://arxiv.org/abs/2310.14918) | `official/ARNIQA/` |
| Q-Align | ICML 2024 | [arXiv:2312.17090](https://arxiv.org/abs/2312.17090) | pyiqa `qalign` |

### 참조(FR) 지표 (보조)

GT 또는 비교 대상이 있을 때 사용하는 지표이다.

| 지표 | 위치 | 설명 |
|---|---|---|
| SSIM | `matlab/IQM/ssim_index.m` | 구조적 유사도 |
| PSNR | `matlab/IQM/PSNR.m` | 신호 대 잡음비 |
| FSIM | `matlab/metrics/2_FSIM/` | 위상 일관성 기반 유사도 |
| LPIPS | `run/lpips_batch.m` | 딥러닝 지각 유사도 (자체 구현) |
| TMQI | `matlab/IQM/TMQI.m` | 톤매핑 품질 평가 |
| MEF-SSIM | `matlab/metrics/10_MEF_ref/` | 다중 노출 융합 품질 평가 |
| FMI | `matlab/metrics/11_FMI/` | 특징 상호정보량 기반 융합 평가 |

## official/ : 원저자 공식 코드

- 각 지표의 원저자 공개 코드를 그대로 수록
- 사전학습 가중치는 용량 문제로 제외. 각 폴더의 README 안내에 따라 다운로드
- 라이선스는 각 폴더의 LICENSE 파일을 따름

| 폴더 | 내용 |
|---|---|
| `official/ILNIQE/` | IL-NIQE 충실 구현 (Python). 계산에 필요한 pristine 템플릿 모델(.mat) 포함 |
| `official/MUSIQ/` | Google Research 공식 MUSIQ (TensorFlow/JAX) |
| `official/MANIQA/` | MANIQA 원저자 코드 (PyTorch) |
| `official/LIQE/` | LIQE 원저자 코드 (PyTorch) |
| `official/ARNIQA/` | ARNIQA 원저자 코드 (PyTorch) |
| `official/CLIP-IQA/` | CLIP-IQA 원저자 코드 (PyTorch) |
| `official/IQA-PyTorch/` | pyiqa 패키지 소스. NIQE, BRISQUE, IL-NIQE, MUSIQ, TOPIQ 등 대부분 지표의 PyTorch 구현 포함 |

## Requirement

- MATLAB + Image Processing Toolbox (`niqe`, `piqe`, `brisque` 내장 함수)
- NIMA는 Deep Learning Toolbox 추가 필요
- 최신 지표는 Python 3.9+ 및 `pyiqa` (PyTorch)
- 상세 내용은 `Requirement.txt` 참고
