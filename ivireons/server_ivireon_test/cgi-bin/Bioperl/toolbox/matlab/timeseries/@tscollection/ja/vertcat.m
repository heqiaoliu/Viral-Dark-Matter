% VERTCAT  オーバーロードされた tscollection オブジェクトの垂直方向の連結
%
%   TSC = VERTCAT(TSC1, TSC2, ...) は、つぎの処理を実行します。
%
%         TSC = [TSC1 ; TSC2 ; ...]
% 
%   この演算は tscollection オブジェクトを追加します。 時間ベクトルは
%   オーバーラップしてはいけません。 TSC1 の最後の時間は、TSC2 の最初の
%   時間よりも早くなければなりません。 連結されるすべての tscollection 
%   オブジェクトは、同じ時系列メンバをもたなくてはなりません。


%   Author(s): Rong Chen, James Owen
%   Copyright 2004-2005 The MathWorks, Inc. 
