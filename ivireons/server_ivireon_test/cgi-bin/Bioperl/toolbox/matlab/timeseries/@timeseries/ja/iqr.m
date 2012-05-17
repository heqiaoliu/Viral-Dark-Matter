%IQR  時系列のデータ値の四分位レンジを出力
%
% IQR(TS) は、TS.Data の四分位レンジを返します。
%
% IQR(TS,'PropertyName1', PropertyValue1,...) は、オプションの入力引数を含みます。
%       'MissingData': 'remove' (デフォルト) または 'interpolate' は、計算中の
%           欠損データをどのように扱うかを示します
%       'Quality': どの特性コードが欠損サンプル (ベクトルの場合)、または、
%           欠損観測値 (2 より大きい次元の配列の場合) を表すのかを示す
%           整数のベクトル
%       'Weighting':'none' (デフォルト) または 'time'。
%           'time' が使われる場合、大きい時間値は、大きい重みに対応します。


%   Copyright 2005-2007 The MathWorks, Inc.
