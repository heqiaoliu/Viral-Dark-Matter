%TIMESERIES  time series オブジェクトの作成
%
%   TS = TIMESERIES は、空の time series オブジェクトを作成します。
%
%   TS = TIMESERIES(DATA) は、データ DATA を使って time series オブジェクト 
%   TS を作成します。N をサンプル数とすると、時間ベクトルの範囲は、デフォルトで 
%   0 から N-1 で、1 秒の間隔を持ちます。TS オブジェクトのデフォルト名は 
%   'unnamed' です。
%
%   TS = TIMESERIES(NAME) は、NAME を文字列とした場合に、NAME という名前の
%   空の time series オブジェクト TS を作成します。
%
%   TS = TIMESERIES(DATA,TIME) は、データ DATA と時間 TIME を使って、
%   time series オブジェクト TS を作成します。注意:時間が日付文字列の場合、
%   TIME は日付文字列のセル配列で指定されなければなりません。
%
%   TS = TIMESERIES(DATA,TIME,QUALITY) は、データ DATA、TIME の時間ベクトル、
%   QUALITY のデータ特性を使って time series オブジェクト TS を作成します。
%   注意: QUALITY がベクトルの場合 (時間ベクトルと同じ長さでなければなりません)、
%   各 QUALITY の値は、対応するデータサンプルに適用されます。QUALITY が TS.Data と
%   同じサイズの場合、各 QUALITY の値は、データ配列の対応する要素に適用されます。
%
%   DATA, TIME, QUALITY の引数の後に、以下のようにプロパティ-値の組み合わせを
%   入力できます。
%       'PropertyName1', PropertyValue1, ...
%   time series オブジェクトの以下の追加プロパティを設定できます。
%       (1) 'Name':time series オブジェクト名を指定する文字列です。
%       (2) 'IsTimeFirst':TRUE の場合、データ配列の最初の次元が時間ベクトルと
%       整合していることを示す論理値です。
%       そうでない場合、データ配列の最後の次元が時間ベクトルと整合します。
%       (3) 'isDatenum':TRUE の場合、時間ベクトルが DATENUM 値から成ることを
%       示す論理値です。'isDatenum' は、time series オブジェクトのプロパティ
%       ではないことに注意してください。
%
%   例:
%   4 つのデータセット (長さ 5 複数の列に格納されたデータ) を含み、デフォルト
%   の時間ベクトルを使用する 'LaunchData' という time series オブジェクトを
%   作成します。
%
%   b = timeseries(rand(5,4),'Name','LaunchData')
%
%   長さ 5 の 1 つのデータセットを含み、時間ベクトルがの最初が 1 で最後が 
%   5 の time series オブジェクトを作成します。
%
%   b = timeseries(rand(5,1),[1 2 3 4 5])
%
%   1 つの時刻で 5 つのデータ点を含む 'FinancialData' と呼ばれる time series 
%   オブジェクトを作成します。
%   b = timeseries(rand(1,5),1,'Name','FinancialData')
%
%   参考 TIMESERIES/ADDSAMPLE, TIMESERIES/TSPROPS


%   Copyright 2004-2007 The MathWorks, Inc.
