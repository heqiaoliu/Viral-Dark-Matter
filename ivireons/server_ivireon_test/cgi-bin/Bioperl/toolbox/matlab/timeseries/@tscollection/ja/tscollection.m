%TSCOLLECTION  時間、または time series オブジェクトを使った tscollection 
%              オブジェクトの作成
%
%   TSC = TSCOLLECTION(TIME) は、TIME を使って tscollection オブジェクト TSC 
%   を作成します。注意:時間が日付文字列の場合、TIME は日付文字列のセル配列で
%   指定されなければなりません。
%
%   TSC = TSCOLLECTION(TS) は、time series オブジェクト TS を持つ 
%   tscollection オブジェクト TSC を作成します。注意:TS の時間は、共通の時間
%   ベクトルとして使われます。
%
%   TSC = TSCOLLECTION(TS) は、TS に格納された time series オブジェクトの
%   セル配列を持つ tscollection オブジェクト TSC を作成します。
%
%   TIME または TS 引数の後にプロパティ-値の組み合わせを入力することができます。
%       'PropertyName1', PropertyValue1, ...
%   tscollection オブジェクトの以下の追加プロパティを設定します。
%       (1) 'Name':この tscollection オブジェクトの名前を指定する文字列です。
%       (2) 'isDatenum':TRUE の場合、時間ベクトルが DATENUM 値から成ることを
%       示す論理値です。'isDatenum' は、tscollection オブジェクトのプロパティでは
%       ないことに注意してください。


%   Copyright 2005-2007 The MathWorks, Inc.
