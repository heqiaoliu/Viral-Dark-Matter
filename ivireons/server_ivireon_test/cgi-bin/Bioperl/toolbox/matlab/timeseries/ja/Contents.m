% 時系列データの可視化と補間
%
% 一般
%   timeseries              - time series オブジェクトを作成
%   timeseries/tsprops      - time series オブジェクトプロパティのヘルプ
%   timeseries/get          - 時系列プロパティ値を取得
%   timeseries/set          - 時系列プロパティ値を設定
%
% 操作
%   timeseries/addsample    - サンプルを time series オブジェクトに追加
%   timeseries/delsample    - time series オブジェクトからサンプルを削除
%   timeseries/synchronize  - 共通の時間ベクトル上の 2 つの time series オブジェクトの同期を取る
%   timeseries/resample     - 時系列データのリサンプル
%   timeseries/vertcat      - time series オブジェクトの垂直結合
%   timeseries/getsampleusingtime - 新規オブジェクトへの指定した時間範囲内のデータを抽出
%
%   timeseries/ctranspose   - 時系列データの転置
%   timeseries/isempty      - 空の time series オブジェクトを検出
%   timeseries/length       - 時間ベクトルの長さ
%   timeseries/size         - time series オブジェクトのサイズ
%   timeseries/fieldnames   - 時系列プロパティ名のセル配列
%   timeseries/getdatasamplesize - 時系列データのサイズ
%   timeseries/getqualitydesc - 時系列データの説明を取得
%
%   timeseries/detrend      - 時系列データから平均と最適な適合線とすべての NaN を削除
%   timeseries/filter       - 時系列データの整形
%   timeseries/idealfilter  - 理想的な (因果性のない) フィルタを時系列データに適用
%
%   timeseries/getabstime   - セル配列内の日付文字列の時間ベクトルを抽出
%   timeseries/setabstime   - 日付文字列を使って時間を設定
%   timeseries/getinterpmethod - time series オブジェクトに対する補間方法名
%   timeseries/setinterpmethod - 時系列にデフォルトの補間方法を設定
%
%   timeseries/plot         - 時系列データをプロット
%
% 時系列のイベント
%   tsdata.event            - 時系列の event オブジェクトを作成
%   timeseries/addevent     - イベントを追加
%   timeseries/delevent     - イベントを削除
%   timeseries/gettsafteratevent - 指定したイベントで、またはその後で発生するサンプルを抽出
%   timeseries/gettsafterevent - 指定したイベントの後で発生するサンプルを抽出
%   timeseries/gettsatevent - 指定したイベントで発生するサンプルを抽出
%   timeseries/gettsbeforeatevent - 指定したイベントで、またはその前で発生するサンプルを抽出
%   timeseries/gettsbeforeevent - 指定したイベントの前で発生するサンプルを抽出
%   timeseries/gettsbetweenevents - 2 つの指定したイベント間で発生するサンプルを抽出
%
% オーバーロードされた算術演算
%   timeseries/plus         - (+)   時系列の加算
%   timeseries/minus        - (-)   時系列の減算
%   timeseries/times        - (.*)  時系列の乗算
%   timeseries/mtimes       - (*)   時系列の除算
%   timeseries/rdivide      - (./)  時系列の配列の右除算
%   timeseries/mrdivide     - (/)   時系列の行列の右除算
%   timeseries/ldivide      - (.\)  時系列の配列の左除算
%   timeseries/mldivide     - (\)   時系列の行列の左除算
%
% オーバーロードされた統計的な関数
%   timeseries/iqr          - 時系列データの四分位範囲
%   timeseries/max          - 時系列データの最大値
%   timeseries/mean         - 時系列データの平均
%   timeseries/median       - 時系列データの中央値
%   timeseries/min          - 時系列データの最小値
%   timeseries/std          - 時系列データの標準偏差
%   timeseries/sum          - 時系列データの和
%   timeseries/var          - 時系列データの分散
%
%
% 時系列コレクションの一般
%   tscollection            - time series collection オブジェクトを作成
%   tscollection/get        - 時系列コレクションのプロパティ値を取得
%   tscollection/set        - 時系列コレクションのプロパティ値を設定
%
% 時系列コレクションの操作
%   tscollection/addts      - データベクトル、または time series collection オブジェクトをコレクションに追加
%   tscollection/removets   - コレクションから time series collection オブジェクトを削除
%   tscollection/addsampletocollection - サンプルをコレクションに追加
%   tscollection/delsamplefromcollection - コレクションからサンプルを削除
%   tscollection/resample   - コレクションの時系列メンバのリサンプル
%   tscollection/vertcat    - tscollection オブジェクトの垂直結合
%   tscollection/horzcat    - tscollection オブジェクトの水平結合
%   tscollection/getsampleusingtime - 指定した時間値間のコレクションからサンプルを抽出
%
%   tscollection/isempty    - 空の tscollection オブジェクトを検出
%   tscollection/length     - 時間ベクトルの長さ
%   tscollection/size       - tscollection オブジェクトのサイズ
%   tscollection/fieldnames - 時系列コレクションのプロパティ名のセル配列
%
%   tscollection/getabstime   - セル配列内の日付文字列の時間ベクトルを抽出
%   tscollection/setabstime   - 日付文字列を使ってコレクションの時間を設定
%   tscollection/gettimeseriesnames - tscollection 内の時系列名のセル配列
%   tscollection/settimeseriesnames - コレクションの時系列メンバ名の変更
%
% グラフィカルな視覚化と解析
%   tstool                  - 時系列ツール GUI を開く


%   Copyright 2004-2006 The MathWorks, Inc.
