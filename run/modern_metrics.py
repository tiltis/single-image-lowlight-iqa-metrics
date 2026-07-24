"""최신 무참조(NR) 화질 지표 일괄 계산 스크립트 (pyiqa 기반).

단일 영상 저조도 개선 결과처럼 GT가 없는 이미지 폴더에 대해
NIQE, BRISQUE, PIQE 및 최신 지표(MANIQA, CLIP-IQA, MUSIQ, TOPIQ 등)를
한 번에 계산하여 CSV로 저장한다.

사용법:
    pip install pyiqa
    python modern_metrics.py <이미지_폴더> --metrics niqe brisque piqe musiq maniqa clipiqa
    python modern_metrics.py <이미지_폴더> -o scores.csv

지표 이름은 pyiqa 등록 이름을 그대로 사용한다.
    niqe, brisque, piqe, ilniqe          (전통 NR 지표, 공식 구현 포트)
    musiq, maniqa, clipiqa, liqe,
    topiq_nr, arniqa, qalign             (딥러닝 기반 최신 NR 지표)
전체 목록: python -c "import pyiqa; print(pyiqa.list_models())"

점수 방향: niqe/brisque/piqe/ilniqe는 낮을수록 좋고,
musiq/maniqa/clipiqa/liqe/topiq_nr/arniqa/qalign은 높을수록 좋다.
"""

import argparse
import csv
from pathlib import Path

import torch
import pyiqa

IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".tif", ".tiff"}

DEFAULT_METRICS = ["niqe", "brisque", "piqe", "musiq", "maniqa", "clipiqa"]


def main():
    parser = argparse.ArgumentParser(description="NR-IQA batch scoring with pyiqa")
    parser.add_argument("input_dir", type=Path, help="평가할 이미지 폴더")
    parser.add_argument("--metrics", nargs="+", default=DEFAULT_METRICS,
                        help="pyiqa 지표 이름 목록 (기본: %(default)s)")
    parser.add_argument("-o", "--output", type=Path, default=Path("nr_iqa_scores.csv"),
                        help="결과 CSV 경로 (기본: %(default)s)")
    args = parser.parse_args()

    images = sorted(p for p in args.input_dir.iterdir()
                    if p.suffix.lower() in IMAGE_EXTS)
    if not images:
        raise SystemExit(f"이미지를 찾을 수 없습니다: {args.input_dir}")

    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"device: {device}, images: {len(images)}, metrics: {args.metrics}")

    scorers = {name: pyiqa.create_metric(name, device=device) for name in args.metrics}

    rows = []
    for img_path in images:
        row = {"filename": img_path.name}
        for name, scorer in scorers.items():
            try:
                with torch.no_grad():
                    row[name] = float(scorer(str(img_path)).item())
            except Exception as e:
                print(f"  [실패] {img_path.name} / {name}: {e}")
                row[name] = float("nan")
        rows.append(row)
        printed = ", ".join(f"{m}={row[m]:.3f}" for m in args.metrics)
        print(f"{img_path.name}: {printed}")

    with open(args.output, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=["filename", *args.metrics])
        writer.writeheader()
        writer.writerows(rows)
    print(f"저장 완료: {args.output}")


if __name__ == "__main__":
    main()
