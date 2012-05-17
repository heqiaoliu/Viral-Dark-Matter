% DELEVENT  time series オブジェクトから event オブジェクトの削除
%
%   TS = DELEVENT(TS, EVENT)  EVENT はイベント名文字列で、TS.EVENTS 
%   プロパティから対応する tsdata.event オブジェクトを削除します。
%
%   TS = DELEVENT(TS, EVENTS)  EVENTS はイベント名文字列のセル配列で、
%   TS.EVENTS プロパティから tsdata.event オブジェクトを
%   削除します。
%
%   TS = DELEVENT(TS, EVENT, N) は、TS.EVENTS プロパティから、名前が 
%   EVENT である N 番目の tsdata.event オブジェクトを削除します。
%
%   例
%
%   時系列の作成:
%   ts=timeseries(rand(5,4))
%
%   時間 3 で発生するイベント 'test' と呼ばれる event オブジェクトを作成
%   e=tsdata.event('test',3)
%
%   event オブジェクトを時系列 TS に追加:
%   ts = addevent(ts,e)
%
%   時系列 TS から event オブジェクトを削除:
%   ts = delevent(ts,'test')
%
%   参考 TIMESERIES/TIMESERIES, TIMESERIES/ADDEVENT

 
% Author(s): Rong Chen, James Owen
% Copyright 2004-2005 The MathWorks, Inc.
