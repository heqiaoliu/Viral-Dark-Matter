%GETSAMPLEUSINGTIME  新規の time series オブジェクトに指定された開始時間と
%                    終了時間の値の間の time series オブジェクトからサンプルを抽出
%
% TS2 = GETSAMPLEUSINGTIME(TS1,TIME) は、TS1 の時間 TIME に対応する 1 つの
% サンプルを持つ新規の時系列 TS2 を返します。
%
% TS2 = GETSAMPLEUSINGTIME(TS1,START,END) は、TS1 の時間 START と END 間の
% サンプルを持つ新規の時系列 TS2 を返します。
%
% 注意:
% (1) TS1 の時間ベクトルが数値の場合、START と END は、数値でなければ
%     なりません。
% (2) TS1 の時間が日付文字列であるけれども、START と END の値が数値
%     の場合、START と END の値は、DATENUM の値として扱われます。


%   Copyright 2005-2007 The MathWorks, Inc.
