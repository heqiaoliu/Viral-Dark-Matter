% EVENT  時系列に対する event オブジェクトの作成
%
%   E=TSDATA.EVENT(NAME,TIME) は、時間 TIME で発生する指定した NAME を
%   もつ event オブジェクトを作成します。 TIME は実数値か日付文字列の
%   いずれかになります。 この event オブジェクトを time series オブジェクト
%   に追加するには、ADDEVENT メソッドを使用してください。 たとえば、
%   ADDEVENT(TS,E) です。
%
%   E=TSDATA.EVENT(NAME,TIME,'DATENUM') は、'DATENUM' を使用して、TIME 値が
%   datenum 関数で生成されたシリアル日付数であり、日付文字列に変更することを
%   指示します。
%
%   event オブジェクトはつぎのプロパティをもちます。
%     EventData: イベントについての任意の情報を格納する MATLAB 配列
%     Name: イベント名を定義する文字列
%     Time: StartDate に対するイベントの時間を指定する実数
%     Units: 時間単位
%     StartDate: 日付文字列、または空
%
%   参考 TSDATA.TIMESERIES/TIMESERIES, TSDATA.TIMESERIES/ADDEVENT


%   Authors: James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
