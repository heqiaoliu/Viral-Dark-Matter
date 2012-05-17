%SLCHECKPRELOOKUPS SYS 内で、ブレークポイントが正しいサイズであることを確認する
%
% 概要:
%
% >> open_system('f14')
% >> bpcheck_rpt = slcheckprelookups('f14');
%
% モデル名またはモデル内のシステム名が与えられたとき、初めにすべての 
% Interpolation n-D Using PreLookup ブロックを検索し、次に、それらから    
% PreLookup Index Search ブロックまでたどり、パラメータサイズをチェックし、
% テーブルのサイズが対応するブレークポイントサイズと一致するかを確認します。
%
% 注意: この関数を実行する前に、モデルに対してダイアグラムの更新を行なう必要があります。 
%       
%
% 補間ブロックの各入力端子に対し、以下のフィールドと入力端子につき 
% 1 配列要素をもつ構造体配列が返されます:
%
%    interpBlkName:    補間ブロック名
%    interpBlkPort:    補間ブロック　端子番号
%    interpBlkParam:   補間ブロックテーブルパラメータテキスト
%    interpBlkDimSize: interpBlkPort に対応するテーブル次元サイズ
%    prelookupName:    prelookup ブロック名
%    prelookupParam:   prelookup ブロックブレークポイントパラメータテキスト
%    prelookupSize     ブロック prelookupName で設定されたブレークポイントのサイズ
%    mismatch :        true/false または 空 - サイズ不一致の場合 true
%    errorMsg:         エラーが発生した場合、エラーが格納されます
%
% オプションの 戻り値 skipcount は、エラーが発生してブロックがスキップされたか
% どうかのチェックに使用できます:
%
% >> [blks,skips] = slcheckprelookups('f14');
%
% skipcount の戻り値は、通常ゼロです。ゼロでない場合、補間ブロックに
% 非接続返された構造体配列のの端子があり、それによって prelookup 情報が、
% 空であるようなことにより、いくつかのフィールドが空 [] である可能性が
% ります。解析がスキップされたエントリを検索は、この配列の非ゼロ指標を
% 検索することができます。
%  skipitem = zeros(length(blks)); 
%  for k=1:length(blks), 
%     skipitem(k) = isempty(blks(k).mismatch); 
%  end
%  skipidx = find(skipitem ~= 0);
%
% この関数を、モデルチェックプロセスの一部として使用するには、これを
% モデルチェックスクリプトから呼び出すか、独自モデルの 
% コールバックの中に、この関数への呼び出しを置くこともできます。
%
% 戻り構造体情報は、Silimlink から hilite_sytem() コマンドを使用して参照する
% ことができ、参照するとブロックが強調されます。

% 例:
%
% >> hilite_system( blks(n).interpBlkName, 'find' )
% >> hilite_system( blks(n).prelookupName, 'find' )
%
% 強調オプションで 'none' を選択してブロックの強調をオフするか、
% View/RemoveHighlighting オプションで、すべての強調を除きます。


% Copyright 1990-2006 The MathWorks, Inc.
