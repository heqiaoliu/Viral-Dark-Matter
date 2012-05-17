% RESAMPLE  新規の時間ベクトルをベースに時系列を再定義
%
%   TS = RESAMPLE(TS,TIMEVEC) は、新規の時間ベクトル TIMEVEC で time series 
%   オブジェクト TS をリサンプルします。 TIMEVEC が数値の場合、
%   TS.TimeInfo.StartDate プロパティを基準に指定され、時系列 TS と同じ
%   単位であることを前提とします。 TIMEVEC が日付文字列の配列である場合、
%   直接使用されます。
%
%   TS = RESAMPLE(TS,TIMEVEC,INTERP_METHOD) は、文字列 INTERP_METHOD で
%   与えられた補間方法を使って 時系列 TS をリサンプルします。 有効な補間
%   方法は 'linear' と 'zoh' です。
%
%   TS = RESAMPLE(TS,TIMEVEC,INTERP_METHOD,CODE) は、文字列 INTERP_METHOD 
%   で与えられた補間方法を使って時系列 TS をリサンプルします。 整数 CODE は
%   リサンプルのためのユーザ定義の特性コードで、すべてのサンプルに適用されます。
%
%   参考 TIMESERIES/SYNCHRONIZE, TIMESERIES/TIMESERIES


%   Authors: Rong Chen, James G. Owen
%   Copyright 2004-2005 The MathWorks, Inc.
