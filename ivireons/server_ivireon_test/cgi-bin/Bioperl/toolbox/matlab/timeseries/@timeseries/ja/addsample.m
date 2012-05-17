% ADDSAMPLE  1 つまたは複数のサンプルを time series オブジェクトに追加
%
%   TS = ADDSAMPLE(TS, 'FIELD1', VALUE1, 'FIELD2', VALUE2) は、フィールド
%   の1つは 'Time' で、他のフィールドは 'Data' でなければなりません。
%   時間 VALUE は有効な時間ベクトルでなければなりません。 データ VALUE の
%   サイズは、getSampleSize(TS) と等しくなければなりません。 TS.IsTimeFirst 
%   が真の場合、データのサイズは N×SampleSize です。 TS.IsTimeFirst が
%   false の場合、データのサイズは SampleSize×N です。 たとえば、
%
%   ts=ts.addsample('Time',3,'Data',3.2);
%
%   TS = ADDSAMPLE(TS,S) は、構造体 S に格納された新規のサンプルを時系列
%   TS に追加します。 S は変数の 名前/値 の組み合わせの集合として新規の
%   サンプルを指定します。
%
%   TS = ADDSAMPLE(TS, 'FIELD1', VALUE1, 'FIELD2', VALUE2, ...) は、
%   つぎの FIELDS を使って追加の FIELD-VALUE の組み合わせを指定します。
%       'Quality': 特性コードの配列 (詳細については、help tsprops をタイプ)
%       'OverwriteFlag': 重複する時間をどのように扱うかをコントロールする
%                        論理値。 真の場合、新規サンプルは同じ時間で定義
%                        された古いサンプルを上書き。
%   たとえば:         
%
%   ts=ts.addsample('Data',3.2,'Quality',1,'OverwriteFlag',true,'Time',3);
%
%   参考 TIMESERIES/TIMESERIES, TIMESERIES/DELSAMPLE


% Author(s): Rong Chen, James Owen
% Copyright 2004-2005 The MathWorks, Inc.
