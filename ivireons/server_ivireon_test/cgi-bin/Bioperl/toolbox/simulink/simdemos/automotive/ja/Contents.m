% Simulink: 自動車モデルのデモンストレーションと例
%
% デモンストレーションモデル (.mdl)
%   absbrake     - ABS ブレーキシステム
%   clutch       - クラッチのエンゲージモデル
%   engine       - 自動車のエンジンモデル
%   enginewc     - 速度制御を伴う自動車エンジンモデル
%   suspn        - 自動車のサスペンションモデル
%
% デモンストレーションスクリプト (.m)
%   runabs   - ABS ブレーキのフロントエンドスクリプト
%   suspgrph - サスペンションのフロントエンド
%
% MATLAB コマンド "demo simulink" を実行することにより、このディレクトリの
% ほとんどのデモとモデルのメニューが表示されます。デモメニューは、
% メインの Simulink ブロックライブラリ (MATLAB コマンドラインで "simulink" と
% タイプする、または、Simulink のツールバーアイコンを押すことにより表示されます)
% の Demos ブロックを開くことによっても利用可能です。 
%
% デモは、MATLAB コマンドラインで、デモの名前をタイプすることによっても
% 実行できます。
%
% サポートルーチンとデータファイル
%   absdata.m    - absbrake のデータ
%   clutchplot.m - clutch のプロットルーチン
%   suspdat.m    - suspn のデータ
%   clutch.mat   - clutch のデータ


% Copyright 1990-2006 The MathWorks, Inc.
