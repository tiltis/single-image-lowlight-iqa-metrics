function [res] = blk_amp_spec_slope_eo_toy(blk)

persistent N;
persistent wnd;

if (nargin == 0)
  N = [];
  wnd = [];
  return;
end

if (nargin == 2 || isempty(N))
  N = size(blk, 1);
  wnd = hann(N); % hanning을 hann으로 대체
  wnd = wnd * wnd'; % 2D 창 생성
end

if (~isa(blk, 'double'))
  blk = double(blk);
end
blk_wnd_prod = blk .* wnd;
% blk_wnd_prod = blk;
[fs, as] = eo_polaraverage(abs(fft2(blk_wnd_prod)));
fs = fs(1:end);
as = as(1:end);

p = polyfit(log(fs), log(as), 1); % 주파수 스펙트럼의 기울기 계산
res(1) = -p(1); % Spectral slope
res(2) = p(2); % Offset
end
