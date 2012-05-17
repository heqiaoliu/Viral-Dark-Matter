%SLDEMO_SWEEPTABLE_THD ssinthd を 1/(4*N) から N/2 周波数までスイープ
%
% 概要:
%    sldemo_sweeptable_thd(bits,N);
%
% bits は固定ワード内のビット数、N は正弦波全体のポイント数
% 
%
% 例:
%    sldemo_sweeptable_thd(24,256)
%
%  さまざまなジャンプサイズで256 ポイントのサインテーブル内の 24 ビット
% 部分ワードを、直接 および 補間モードでテーブル内に渡って計算し、
% 結果をプロットする。
%

% $Revision: 1.1.6.1 $
% 2002-Dec-23
% Copyright 1984-2006 The MathWorks, Inc.
