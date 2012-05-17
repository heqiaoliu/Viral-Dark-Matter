%TIME SERIES オブジェクトのプロパティ:
%
%      イベント: 時系列と関連するイベントについての情報。
%               以下のプロパティを含みます。(イベントを time series 
%               オブジェクトに追加するための詳細は ADDEVENT を参照して
%               ください)
%
%               EventData: イベントに関する追加のユーザ定義情報を含めるには
%                          このプロパティを使用します
%               Name: イベント名を示す文字列
%               Time: このイベントが発生する時間
%               Units: 時間単位
%               StartDate: 基準日
%
%      Name:time series オブジェクト名を定義する文字列
%
%      Data: データの数値配列
%
%      DataInfo: データについてのメタ情報。以下のプロパティを含みます。
%
%               Unit: データの単位を記述するユーザ定義文字列
%               Interpolation: 時系列で使われるデフォルトの補間方法を
%                              定義する tsdata.interpolation オブジェクト。
%                              interpolation オブジェクトは、以下の
%                              プロパティを含みます。
%                       Fhandle: 補間関数への関数ハンドル
%                       Name: 補間方法名。
%                             通常 'zoh' あるいは 'linear' (デフォルト) 
%                             のいずれか。
%               UserData: 任意のユーザ定義追加情報を格納
%
%      Time: 時間のベクトル
%
%      TimeInfo: 時間についてのメタ情報。以下のプロパティを含みます。
%
%               Units: 'weeks','days','hours','minutes','seconds', ...
%                      'milliseconds', 'microseconds', 'nanoseconds'
%               Start: 開始時間
%               End: 終了時間
%               Increment: 連続する 2 つの時間値の間隔
%               Length: 時間ベクトルの時間の数
%               Format: 日付文字列の表示書式を定義する文字列
%                       利用可能なオプションについては DATESTR を参照。
%               Startdate: 基準日を定義する日付文字列。時間ベクトルの時間は、
%                          すべてこの日付を基準とします。詳細については 
%                          SETABSTIME を参照。
%               UserData: 任意のユーザ定義追加情報を格納
%
%      Quality: データの特性を記述する整数の配列
%
%      QualityInfo: 特性コードについてのメタ情報。以下のプロパティを含みます。
%               Codes: 特性コードのセットを定義する int8 の整数ベクトル
%               Description: それぞれ関連する特性コードを記述する文字列の
%                           セル配列
%               UserData: 任意のユーザ定義追加情報を格納
%
%      IsTimeFirst: データ配列の最初の次元が Time と整合する場合 
%                   True (デフォルト)。データ配列の最後の次元が Time と
%                   整合する場合 False。時系列作成後はこのプロパティは
%                   読み取り専用になることに注意。
%
%      TreatNaNasMissing: TS.Data のすべて NaN の値が欠損値として扱われ、
%                         統計の計算中に除かれる場合は True (デフォルト)。
%                         これらの NaN の値が計算に使用される場合 False。


%   Copyright 2004-2009 The MathWorks, Inc.
