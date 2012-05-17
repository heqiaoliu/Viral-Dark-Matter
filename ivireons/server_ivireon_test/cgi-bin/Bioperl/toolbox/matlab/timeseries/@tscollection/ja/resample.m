%RESAMPLE  新規時間ベクトルで tscollection オブジェクトを再定義
%
%   TSC = RESAMPLE(TSC,TIMEVEC) は、新規ベクトル TIMEVEC で tscollection 
%   オブジェクト TSC をリサンプルします。TIMEVEC は数値で、TSC.TimeInfo.StartDate 
%   プロパティを基準として指定され、tscollection TSC で使われるものと同じ単位で
%   あることを前提とします。TIMEVEC が日付文字列の配列である場合、直接使われます。
%
%   TSC = RESAMPLE(TSC,TIMEVEC,INTERP_METHOD) は、文字列 INTERP_METHOD で
%   与えられた補間手法を使って tscollection TSC をリサンプルします。
%   有効な補間方法は 'linear' と 'zoh' です。
%
%   TSC = RESAMPLE(TSC,TIMEVEC,INTERP_METHOD,CODE) は、文字列 INTERP_METHOD 
%   で与えられた補間手法を使って tscollection TSC をリサンプルします。
%   整数 CODE は、リサンプルのためのユーザ定義の特性コードで、すべての
%   サンプルに適用されます。
%
%   参考 TSCOLLECTION/SYNCHRONIZE, TSCOLLECTION/TSCOLLECTION


%   Copyright 2005-2007 The MathWorks, Inc.
