% GETTSBEFOREATEVENT  指定したイベント時、またはその前に発生するすべての
%                     サンプルを持つ新規の timeseries オブジェクトを出力
%
%   GETTSBEFOREATEVENT(TS, EVENT) の EVENT は、tsdata.event オブジェクト、
%   または文字列のいずれかになります。EVENT が tsdata.event オブジェクトの場合、
%   EVENT で定義された時間が使われます。EVENT が文字列の場合、TS の Events 
%   プロパティ内の最初の tsdata.event オブジェクトは、その時間に指定するために
%   使われる EVENT 名と一致します。
%
%   GETTSBEFOREATEVENT(TS, EVENT, N) の N は、EVENT 名と N 番目に一致します。
%
%   注意:時系列 TS が日付文字列を含み、EVENT が相対時間を使う場合、EVENT で
%   選択された時間は、(TS.TimeInfo プロパティ内の StartDate プロパティを
%   基準として計算された) 日付として扱われます。TS が相対時間で、EVENT が
%   日付を使用する場合、EVENT で選択された時間は、相対値として扱われます。
%
%   参考 TIMESERIES/GETTSAFTEREVENT, TIMESERIES/GETTSBEFOREEVENT,
%        TIMESERIES/GETTSBETWEENEVENTS


% Copyright 2004-2007 The MathWorks, Inc.
