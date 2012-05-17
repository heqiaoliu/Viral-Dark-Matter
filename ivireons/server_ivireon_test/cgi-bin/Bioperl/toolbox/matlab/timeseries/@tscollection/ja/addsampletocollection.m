%ADDSAMPLETOCOLLECTION  サンプルを時系列コレクションに追加
%
%   TSC = ADDSAMPLETOCOLLECTION(TSC, 'TIME', TIME, TS1NAME, TS1DATA, ...,
%   TSnNAME, TSnDATA)
%   は、時間 TIME で tscollection TSC 内のメンバ TSnNAME にデータサンプル 
%   TSnDATA を追加します。ここで、TSnNAME は、TSC 内の時系列の名前を表す文字列
%   で、TSnDATA はデータ配列です。注意: TSC の時系列メンバに対するデータサンプル
%   を指定しない場合、時系列メンバは時間 TIME において、(数値の時系列データに
%   ついては) NaN 値、あるいは (論理値の時系列データについては) FALSE 値となる
%   欠損値を含みます。
%
%   データサンプルと一緒に特性を指定する (特性値の必要な時系列メンバに
%   ついて) には、以下のシンタックスを使用してください 。
%
%   TSC = ADDSAMPLETOCOLLECTION(TSC, 'TIME', TIME, TS1NAME, TS1CELLARRAY, TS2NAME, TS2CELLARRAY, ...)
%   セル配列の最初の要素のデータとセル配列の 2 番目の要素の特性を指定します。


% Copyright 2005-2008 The MathWorks, Inc.
