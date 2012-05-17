% VERTCAT  オーバーロードされた time series オブジェクトの垂直方向の連結
%
%   TS = VERTCAT(TS1,TS2,...) は、垂直方向の連結を実行します。
%
%         TS = [TS1 ; TS2 ; ...]
% 
%   この演算は time series オブジェクトを連結します。 時間ベクトルは
%   オーバーラップしてはいけません。 TS1 の最後の時間は、TS2 の最初の
%   時間よりも早くなければなりません。 時系列のサンプルサイズは一致しな
%   ければなりません。


%   Author(s): James Owen, Rong Chen
%   Copyright 2004-2005 The MathWorks, Inc.
