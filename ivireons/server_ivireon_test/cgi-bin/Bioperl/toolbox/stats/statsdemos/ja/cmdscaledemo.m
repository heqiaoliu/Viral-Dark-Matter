% 古典的多次元尺度構成法
%
% 主軸解析 (Principal Coordinates Analysis) としても知られる
% 古典的多次元尺度構成法 (Classical multidimensional scaling) は、
% interpoint の距離の行列を与え、点の構成を作成します。
% 理想的には、それらの点は 2 次元か 3 次元で構成することが構成することが
% でき、それらの間のユークリッド距離は、近似的にオリジナルの距離行列を
% 再生します。
% 
% このデモの 2 つの例は、空間的な距離以外の類似尺度への多次元尺度構成法の
% アプリケーションを説明し、これらの違いを視覚化するための点の配置を
% 構築する方法を示します。
%
% このデモは、Statistics Toolbox の |cmdscale| を使った多次元尺度構成法を
% 説明します。|mdscale| 関数は、古典的な手法よりも時々柔軟な "非古典的な" 
% MDSを実行します。非古典的な MDS は、
% <mdscaledemo.html  Non-Classical Multidimensional Scaling> のデモに
% 記述されています。


%   Copyright 2002-2007 The MathWorks, Inc.
