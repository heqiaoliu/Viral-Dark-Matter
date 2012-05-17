% SYNCHRONIZE  2 つの time series オブジェクトを共通の時間ベクトルに同期
%
%   [TS1 TS2] = SYNCHRONIZE(TS1, TS2, 'SYNCHRONIZEMETHOD') は、共通の
%   時間ベクトルへ time series オブジェクト TS1 と TS2 を同期することで
%   新規の time series オブジェクトを作成します。 SYNCHRONIZE は、オリジナルの 
%   time series オブジェクト TS1 と TS2 の両方を新たに同期を取った time series 
%   オブジェクトに置き換えます。 文字列 'SYNCHRONIZEMETHOD' は、時系列の
%   同期方法を定義し、つぎのいずれかになります。
%
%   'Union' - 時間ベクトル TS1, TS2 が重複する時間間隔上での 2 つの TS1, 
%             TS2 の結合である時間ベクトル上で時系列をリサンプルする。
%
%   'Intersection' - TS1 と TS2 の時間ベクトルの共通部分がある時間ベクトルで
%                    時系列をリサンプル。
%
%   'Uniform' - このメソッドはつぎの追加引数が必要です。
%   [TS1 TS2] = SYNCHRONIZE(TS1, TS2, 'UNIFORM', 'interval',VALUE) は、
%   VALUE で時間間隔を指定した等間隔の時間ベクトルで時系列をリサンプル。
%   等間隔の時間ベクトルの範囲は、TS1 と TS2 の時間ベクトルのオーバーラップ
%   する部分。 間隔の単位は、TS1 と TS2 のうち小さい方の単位であることを
%   前提とします。
%
%   プロパティ-値の組み合わせで追加の引数を指定することができます。
%
%       'interpmethod',VALUE: この SYNCHORNIZE 操作に対して指定した補間
%       方法 (デフォルトの方法に対し) を使用。 VALUE は 'linear' か 
%       'zoh' のいずれかの文字列、または、ユーザ定義の補間方法を含む 
%       tsdata.interpolation オブジェクト。
%
%       'qualitycode',VALUE: 同期後に両方の時系列に対する特性として使われる
%       VALUE で指定する整数 (-128 と 127 の間)。
%
%       'keepOriginalTimes',VALUE: 新規時系列がオリジナルの時間値を保持
%       するかどうかを示すのに使われる VALUE で指定する論理値 (TRUE 
%       または FALSE)。 たとえば、
%           ts1 = timeseries([1 2],[datestr(now); datestr(now+1)]);
%           ts2 = timeseries([1 2],[datestr(now-1); datestr(now)]);
%       ts1.timeinfo.StartDate は、ts2.timeinfo.StartDate 後の1日である
%       ことに注意してください。 もしつぎのように使用した場合、
%           [ts1 ts2] = synchronize(ts1,ts2,'union');
%       ts1.timeinfo.StartDate は、ts2.timeinfo.StartDate と同じになる
%       ように変更されます。 しかし、つぎのように使用する場合、
%       ts2.timeinfo.StartDate. But, if you use
%           [ts1 ts2] = synchronize(ts1,ts2,'union','KeepOriginalTimes',true);
%       ts1.timeinfo.StartDate は変更されません。
%
%       'tolerance',VALUE: TS1 と TS2 の時間ベクトルを比較する場合、
%       識別する 2 つの時間値に対する許容誤差として使われる VALUE で
%       指定する実数。 デフォルトの許容誤差は 1e-10。 たとえば、TS1 の
%       6番目の時間値が 5+(1e-12) で、TS2 の6番目の時間値が 5-(1e-13) の
%       場合、デフォルトでは、両方とも 5 として扱われます。 これらの
%       2 つの時間を識別するために、'tolerance' をより小さい値、たとえば
%       1e-15 のような小さい値に設定することができます。
%
%   参考 TIMESERIES/TIMESERIES, TSDATA.INTERPOLATION/INTERPOLATION


%   Author(s): Rong Chen, James Owen
%   Copyright 2004-2005 The MathWorks, Inc.
