% Simulink: 一般的なモデルのデモと例
%
% デモンストレーションモデル (.mdl)
%   bangbang     - 状態イベントハンドリングのデモ
%   bounce       - 積分器のリセットを用いた弾むボール
%   countersdemo - カウンタ
%   doublebounce - 適応するゼロクロッシングの検出を用いた二度弾むボール
%   dblcart1     - 2 つのカートのデモ
%   dblpend1     - 2 重振子のデモ、バージョン 1
%   dblpend2     - 2 重振子のデモ、バージョン 2
%   hardstop     - 急ブレーキの摩擦モデル
%   hydcyl       - 油圧シリンダモデル
%   hydcyl4      - 4 個の油圧シリンダ
%   hydrod       - スティッフなロッドと接続した 2 つの油圧シリンダ
%   onecart      - 単一のカート/バネのデモ
%   penddemo     - 倒立振子 (カート上) のアニメーション
%   simppend     - 単振子のデモ
%   slprimes     - Simulink による素数の計算
%   thermo       - 家の熱力学
%   toilet       - トイレのタンクを流すアニメーション
%   vdp          - Van der Pol 方程式システム
%
% デモンストレーションスクリプト
%   vdpdemo    - Van der Pol 方程式
%
% MATLAB コマンド "demo simulink" を実行することによって、このディレクトリ
% のほとんどのデモとモデルのメニューが表示されます。デモメニューは、
% メインの Simulink ブロックライブラリの Demos ブロックを開くことでも
% 利用可能です (MATLAB コマンドラインで "simulink" と入力するか、または、
% Simulink ツールバーアイコンを押すことで表示されます)。
%
% デモは、MATLAB コマンドラインで、それらの名前を入力することでも実行できます。
%
% サポートルーチンとデータファイル
%   animinit.m          - 種々のデモのアニメーションの初期化
%   ballBeep.m          - doublebounce の音
%   crtanim1.m          - onecart のアニメーション
%   crtanim2.m          - dblcart1 のアニメーション
%   dblBallanim.m       - doublebounce のアニメーション
%   dblBallaniminit.m   - doublebounce のアニメーションの初期化  
%   dblcart1.mat        - dblcart1 のデータ
%   dblpend1.mat        - dblpend1 のデータ
%   dblpend2.mat        - dblpend2 のデータ
%   lights.mdl          - slprimes の light ブロックを持つ Simulink ライブラリ
%   newhcd.mat          - hydcyl, hydcyl4, hydrod のデータ
%   pendan.m            - penddemo アニメーションの S-Function
%   pndanim1.m          - simppend のアニメーション
%   pndanim2.m          - dblpend1 のアニメーション
%   pndanim3.m          - dblpend2 のアニメーション
%   slight.m            - Light ブロック S-function
%   simdblball.m        - doublebounce のシミュレーション
%   thermdat.m          - thermo のフロントエンドスクリプト
%   toilet.wav          - toilet アニメーションのサウンド
%   toiletgui.m         - toilet アニメーションの GUI
%   toiletsfun.m        - toilet アニメーションの S-Function
%   vdpdemo.m           - vdp のフロントエンドスクリプト


% Copyright 1990-2009 The MathWorks, Inc.
