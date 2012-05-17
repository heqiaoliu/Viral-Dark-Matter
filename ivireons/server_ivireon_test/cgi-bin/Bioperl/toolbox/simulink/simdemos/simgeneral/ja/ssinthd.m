%SSINTHD サンプル サイン波形の全高調波歪を計算
%
% 概要:
%
%  thd = ssinthd(is, delta, bn, a, outtype, bits)
%
%  補間または非補間デジタルサイン波形生成の全高調波歪 (THD)を計算する。
%  この THD アルゴリズムは正確な結果を導くために、整数個の波形に行なわれます。
%  波形サイクルの数は A、デルダは A/B で A 波形を横断すると全ての
% ポイントを一度はヒットするので、平均 THD を正確に見つけることが必要です。
%
%  THD の計算に使用する関係:
%
%      THD = (ET - EF) / ET
%
%  ここで ET = total energy
%        EF = fundamental frequency energy
%
%  thd = ssinthd(isin, delta, bn, a)
%
%
% オプション引数構成:
%
%  thd = ssinthd(is, delta, bn, a, outtype, bits)
%
%  IS      サインテーブル。長さは 2 の累乗。
%  DELTA   ポイント A/B 間のスペース で、A と B の比は素数。例えば、A=9, B=4 
%  の場合、DELTA = 2.25 で、出力ごとに 2.25 ポイントジャンプする。
%  BN      B*N。B はフルサイクルを合成するのに必要な最少サイクル数。
%          N はテーブル長。
%  A       デルタ比の分子。
%  OUTTYPE オプション: 'direct', 'linear', または 'fixptlinear':
%          'direct' は直接テーブルアクセス (floor index, 補間なし)
%          'linear' は浮動小数点線形補間
%          'fixptlinear' は固定少数点線形補間
%  BITS    オプション: fixptlinear に対し、少数ビットを選択する。
% 　　　　　　デフォルトは 24。
%
% 全高調波歪を、出力引数タイプに応じて、オプションテーブルに対して出力します:
%
%
%  参考:
%  "Digital Sine-Wave Synthesis Using the DSP56001/DAP56002",
%   Andreas Chrysafis, Motorola, Inc. 1988
%

% Copyright 1990-2006 The MathWorks, Inc.
