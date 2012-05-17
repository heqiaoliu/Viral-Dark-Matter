%DETREND  平均、または最適な適合線を削除
%
%   TS2 = DETREND(TS1,TYPE) は、通常、FFT 処理に対して時系列データから
%   平均、または最適な適合線を削除します。TYPE は、トレンド除去の方法を
%   指定する文字列で、'constant' または 'linear' です。
%
%   TS2 = DETREND(TS1,TYPE,INDEX) は、TS1.IsTimeFirst が true の場合は
%   特定の列を、または、TS1.IsTimeFirst が false の場合は行をトレンド除去
%   するためにオプションの INDEX 値を使用します。INDEX は、整数配列として
%   指定されます。
%
%   注意:DETREND は、2 より大きい次元で時系列に適用できません。
%
%   参考 TIMESERIES/TIMESERIES


%   Copyright 2005-2007 The MathWorks, Inc.
