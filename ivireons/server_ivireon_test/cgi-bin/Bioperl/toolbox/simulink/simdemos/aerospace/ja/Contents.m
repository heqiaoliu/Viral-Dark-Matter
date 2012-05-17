% Simulink: 航空機モデルのデモンストレーションと例
%
% デモンストレーションモデル (.mdl)
%   f14                      - F-14 航空機モデル
%   f14_digital              - F-14 ディジタルオートパイロットモデル
%   aero_dap3dof             - 1969 年月着陸船ディジタルオートパイロット
%   aero_six_dof             - 6 自由度モーションプラットフォーム
%   aero_guidance            - 3 自由度誘導ミサイル
%   aero_guideance_airframe  - ミサイル機体のトリムと線形化
%   aero_atc                 - 航空管制のレーダー設計
%   aero_radmod              - レーダの追跡
%   aero_pointer_tracker     - 移動するターゲットの追跡のデモ


% ユーザガイドのケーススタディ #1、#2、#3 のデモモデル
%   f14c - F-14 ベンチマーク、閉-ループ型
%   f14n - F-14 ブロックダイアグラム、切り替え型
%   f14o - F-14 ベンチマーク、開-ループ型
%
%
% このディレクトリにあるほとんどのデモとモデルのメニューを見るには、MATLAB コマンド
% "demo simulink" を実行します。デモメニューは、メイン Simulink ブロックライブラリ
% (MATLAB コマンドラインでコマンド "simulink" を実行、または Simulink ツールバー
% アイコンをクリックして表示）でデモブロックを開くことで得られます。
%
% デモは、MATLAB コマンドラインでそれらの名前をタイプすることでも実行することができます。
%
% サポートルーチンとデータファイル
%   aerospace         - フライトダイナミックコンポーネントのライブラリ
%   aero_lin_aero     - 線形機体トリムコマンド
%   aero_dap3dofdata  - 月着陸船定数定義
%   aero_phaseplane   - 月着陸船ラインタイム表示
%   f14dat            - F-14 定数定義
%   f14dat_digital    - F-14 デジタル定数定義
%   f14actuator       - F-14 デジタルアクチュエイターライブラリ
%   f14autopilot      - F-14 自動操縦設計モジュール
%   f14pix            - F-14 デジタルビットマップピクチャ
%   f14controlpix     - F-14 デジタルビットマップピクチャ
%   f14weather        - F-14 デジタルビットマップピクチャ
%   aero_guid_dat     - 誘導定数定義
%   aero_guid_plot    - 誘導デモのプロットルーチン
%   aero_guid_autop   - 誘導自動操縦ゲイン
%   sanim3dof         - アニメーション S-function (3 自由度)
%   sanim             - アニメーション S-Function (6 自由度)
%   aero_preload_atc  - エアートラフィックレーダーのプリロードルーチン
%   aero_init_atc     - エアートラフィックレーダーの初期化ルーチン
%   aero_atcgui       - エアートラフィックレーダーの GUI インターフェース
%   aero_atc_callback - エアートラフィック制御レーダー GUI のコールバックルーチン
%   aero_extkalman    - レーダー追跡拡張 kalman フィルタ
%   aero_raddat       - レーダー追跡定数定義
%   aero_radlib       - コンポーネントのレーダー追跡ライブラリ
%   aero_radplot      - レーダー追跡結果表示
%   aero_vibrati      - 動ターゲット追跡振動シミュレーション


% Copyright 1990-2006 The MathWorks, Inc.
