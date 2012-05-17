% ADDEVENT  event オブジェクトを time series オブジェクトに追加
%
%   ADDEVENT(TS,E) は、tsdata.event オブジェクト E の配列を時系列 TS の
%   EVENTS プロパティに追加します。
%
%   ADDEVENT(TS,NAME,TIME) は、いくつかの tsdata.event オブジェクトを
%   作成し、時系列 TSの EVENTS プロパティにそれらを追加します。 NAME は、
%   イベント名の文字列のセル配列です。 TIME はイベント時間のセル配列です。
%
%   例
%
%   time series オブジェクトの作成:
%   ts = timeseries(rand(5,4))
%
%   イベントが時間 3 と 4 でそれぞれ発生する 'e1' と 'e2' と呼ばれる
%   event オブジェクトの作成: 
%   e1 = tsdata.event('e1',3)
%   e2 = tsdata.event('e2',4)
%
%   event オブジェクトのプロパティ (EventData, Name, Time, Units, StartDate) 
%   の表示: 
%   get(e1)
%
%   event オブジェクトを time series オブジェクト TS に追加:
%   ts = ts.addevent([e1 e2])
%   
%   代わりにイベントを追加するつぎの方法があります。
%   ts = ts.addevent({'e1' 'e2'},{3 4})
%
%   参考 TIMESERIES/TIMESERIES


%   Author(s): Rong Chen, James Owen
%   Copyright 2004-2005 The MathWorks, Inc.
