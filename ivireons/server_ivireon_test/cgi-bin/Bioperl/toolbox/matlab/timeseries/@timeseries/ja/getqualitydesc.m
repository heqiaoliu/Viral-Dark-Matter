%GETQUALITYDESC  time series オブジェクトに割り当てられた特性値に基づき
%                データの特性の説明を出力
%
%   例：
%
%   time series オブジェクトの作成:
%   ts = timeseries(rand(5,1),1:5,[1;0;1;0;1]);
%
%   QualityInfo を設定:
%   ts.QualityInfo.Code = [0 1];
%   ts.QualityInfo.Description = {'good' 'bad'};
%
%   このオブジェクトに対するデータの特性文字列を取得:
%   getqualitydesc(ts)


%   Copyright 2005-2007 The MathWorks, Inc.
