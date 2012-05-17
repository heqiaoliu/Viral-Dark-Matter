% TSTOOL  時系列ツール GUI を開く
% 
% V = TSTOOL は、tsviewer へのハンドルを返します。
% V = TSTOOL(OBJ) は、GUI 内にオブジェクト OBJ をインポートします。 OBJ は
% timeseries, tscollection, TsArray, あるいは、データのロギングが有効で
% ある場合に Simulink モデルで作成された ModelDataLogs オブジェクトの
% ような Simulink Data Logs オブジェクトです。
% 
% ロギングした Simulink 信号に対する REPLACE オプション:
% V = TSTOOL(OBJ,'replace') は、GUI 内に既にオブジェクトが存在している場合、
% 時系列ツール内のオブジェクト OBJ を置き換えます。 このシンタックスは、
% ModelDataLogs オブジェクトのみサポートされます。 他のオブジェクトに
% ついては、'replace' オプションは無視されます。


% Copyright 2004-2005 The MathWorks, Inc.
