# Zeit MVP 要件定義

## 概要
時間経過で人口が増加し、それに合わせて家が自動的に建設される様子を眺めるシミュレーションゲーム。

## 基本仕様

### 初期状態
- **人口**: 0人
- **家**: 0軒
- **ゲーム開始**: 何もない更地から始まる

### 人口増加システム
- **初回**: ゲーム開始10秒後に最初の1人
- **増加間隔**: 10秒ごと
- **増加量**: 1人ずつ
- **上限**: なし（無限に増加）

### 家の生成システム
- **収容人数**: 1軒につき3人
- **建築タイミング**: 現在の家が満員になったら新しい家を建築
  - 例: 人口1人目→1軒目建築、人口4人目→2軒目建築
- **配置**: 完全ランダム（マップ内のランダムな位置）
- **配置制約**: 他の家と重ならない（隣接OK）

### 表示システム
- **描画方式**: 3D
- **カメラ**: 
  - アイソメトリック角度（地面に対して45度）で固定
  - 高さ固定
  - X/Z軸の移動のみ可能（パン操作）
- **操作方法**:
  - マウスドラッグまたはWASDでカメラ移動

### UI表示
- **人口数**: 現在の人口
- **家の数**: 建築済みの家の数  
- **経過時間**: ゲーム開始からの経過時間（分:秒形式）
- **時間加速**: スライダーで調整（x1〜x100）

### その他の仕様
- **セーブ機能**: なし（アプリを閉じるとリセット）
- **フォアグラウンド限定**: アプリがバックグラウンドに行くと時間停止
- **カメラ初期位置**: マップ中央

## 技術仕様

### マップ
- **サイズ**: 固定サイズ（例: 50x50グリッド）
- **地形**: フラットな平地

### 家のビジュアル
- **スタイル**: ローポリ
- **形状**: シンプルな家の形（屋根付きの箱）
- **色**: 茶色系統
- **サイズ**: 1x1グリッド
- **バリエーション**: なし（全て同じ見た目）

### パフォーマンス
- **目標FPS**: 60FPS
- **最大家数**: 特に制限なし（パフォーマンスが許す限り）

## 実装優先順位
1. 3Dシーンとアイソメトリックカメラ
2. 人口増加システム
3. 家の自動生成
4. UI表示
5. カメラ移動
6. 時間加速機能

## TDD実装ワークフロー

### Phase 1: 基本シーン構築とテスト環境
- [ ] **テスト環境のセットアップ**
  - [ ] test/ディレクトリの作成
  - [ ] TestRunner.gdの作成（基本的なテストフレームワーク）
  - [ ] コンソールにテスト結果を出力する仕組み

- [ ] **プロジェクト設定**
  - [ ] project.godotの基本設定（ウィンドウサイズ: 1280x720）
  - [ ] レンダリング設定（モバイル向け）
  - [ ] 背景色の設定（明るい空色）

- [ ] **メインシーンの作成（RED）**
  - [ ] test_main_scene_exists()テストを作成 → 失敗確認
  - [ ] scenes/main.tscnを作成（Node3D）
  - [ ] テストが通ることを確認（GREEN）

- [ ] **3Dカメラの実装（RED→GREEN）**
  - [ ] test_camera_is_isometric()テストを作成
    - カメラの角度が45度であることを確認
    - 正投影であることを確認
  - [ ] Camera3Dを追加（位置: 10,10,10、rotation: -35,-45,0）
  - [ ] projection = orthogonalに設定
  - [ ] size = 10に設定

- [ ] **ライティングの実装**
  - [ ] test_scene_has_lighting()テストを作成
  - [ ] DirectionalLight3Dを追加（rotation: -45,-45,0）
  - [ ] 影の設定（shadow_enabled = true）

- [ ] **地面の実装**
  - [ ] test_ground_exists()テストを作成
  - [ ] CSGBox3Dで地面を作成（size: 50,0.1,50）
  - [ ] 緑色のマテリアルを適用

### Phase 2: GameManagerとコアシステム
- [ ] **GameManagerクラスの作成（RED→GREEN）**
  - [ ] test_game_manager_singleton()テストを作成
  - [ ] scripts/GameManager.gdを作成
  - [ ] Autoloadに登録
  - [ ] 初期化メッセージの出力を確認

- [ ] **人口管理システム（TDD）**
  - [ ] test_initial_population_is_zero()テストを作成
  - [ ] GameManagerにpopulation変数を追加
  - [ ] test_population_increases_after_10_seconds()テストを作成
  - [ ] Timerノードを追加（wait_time = 10.0）
  - [ ] _on_population_timer_timeout()の実装
  - [ ] test_first_house_spawns_at_population_1()テストを作成
  - [ ] test_second_house_spawns_at_population_4()テストを作成

- [ ] **時間管理システム**
  - [ ] test_elapsed_time_tracking()テストを作成
  - [ ] elapsed_time変数とその更新処理
  - [ ] test_time_scale_changes_speed()テストを作成
  - [ ] time_scale変数の実装（デフォルト: 1.0）

- [ ] **グリッドシステム**
  - [ ] test_grid_size_is_50x50()テストを作成
  - [ ] GridManagerクラスの作成
  - [ ] test_grid_position_validation()テストを作成
  - [ ] test_grid_occupation_check()テストを作成

### Phase 3: 家の実装
- [ ] **家のリソース準備**
  - [ ] building-i.objのインポート設定
  - [ ] building-i.obj.importファイルの生成確認
  - [ ] マテリアルとテクスチャの設定

- [ ] **家のシーン作成（TDD）**
  - [ ] test_house_scene_loads()テストを作成
  - [ ] scenes/house.tscnの作成
  - [ ] MeshInstance3Dでbuilding-i.objを参照
  - [ ] スケール調整（適切なサイズに）

- [ ] **家の配置システム**
  - [ ] test_house_spawns_at_random_position()テストを作成
  - [ ] test_houses_dont_overlap()テストを作成
  - [ ] spawn_house()メソッドの実装
  - [ ] get_random_available_position()の実装
  - [ ] test_house_count_matches_expected()テストを作成

### Phase 4: UI実装
- [ ] **UIシーンの作成**
  - [ ] test_ui_scene_exists()テストを作成
  - [ ] scenes/ui.tscnの作成（CanvasLayer）
  - [ ] UIスクリプトの作成

- [ ] **人口表示**
  - [ ] test_population_label_updates()テストを作成
  - [ ] PopulationLabelの追加
  - [ ] GameManagerからのシグナル接続
  - [ ] フォーマット: "人口: X"

- [ ] **家の数表示**
  - [ ] test_house_count_label_updates()テストを作成
  - [ ] HouseCountLabelの追加
  - [ ] フォーマット: "家: X"

- [ ] **経過時間表示**
  - [ ] test_elapsed_time_format()テストを作成
  - [ ] TimeLabel�追加
  - [ ] MM:SS形式での表示
  - [ ] 1時間以上の場合はHH:MM:SS

- [ ] **時間加速スライダー**
  - [ ] test_time_scale_slider_range()テストを作成（1-100）
  - [ ] HSliderの追加
  - [ ] test_time_scale_affects_population_timer()テストを作成
  - [ ] スライダー値の表示（"速度: x10"）

### Phase 5: カメラコントロール
- [ ] **カメラコントローラーの作成**
  - [ ] test_camera_controller_exists()テストを作成
  - [ ] CameraController.gdの作成
  - [ ] Camera3Dにアタッチ

- [ ] **キーボード入力**
  - [ ] test_wasd_moves_camera()テストを作成
  - [ ] Input.is_action_pressed()の実装
  - [ ] test_camera_movement_speed()テストを作成
  - [ ] 移動速度の調整（10 units/sec）

- [ ] **マウスドラッグ**
  - [ ] test_mouse_drag_moves_camera()テストを作成
  - [ ] _input(event)の実装
  - [ ] ドラッグ状態の管理

- [ ] **移動範囲制限**
  - [ ] test_camera_stays_within_bounds()テストを作成
  - [ ] カメラ位置のクランプ処理
  - [ ] 境界の視覚的表示（デバッグ用）

### Phase 6: 統合テストと最適化
- [ ] **統合テスト**
  - [ ] test_full_game_flow()テストを作成
    - 10秒待機→人口1→家1軒
    - 30秒待機→人口3→家1軒
    - 40秒待機→人口4→家2軒
  - [ ] test_ui_reflects_game_state()テストを作成

- [ ] **パフォーマンステスト**
  - [ ] test_performance_with_100_houses()テストを作成
  - [ ] FPSカウンターの実装
  - [ ] メモリ使用量の監視

- [ ] **エッジケーステスト**
  - [ ] test_grid_full_scenario()テストを作成
  - [ ] test_time_scale_extremes()テストを作成（x0.1, x1000）
  - [ ] test_long_running_stability()テストを作成（10分実行）

### テスト実行方法

#### 方法1: シェルスクリプト経由
```bash
# WSL/Linuxから実行
./run_tests.sh
```

#### 方法2: Godotエディタから実行
1. Godotエディタを開く
2. `test/test_runner_scene.tscn`を開く
3. F6キーまたは「現在のシーンを実行」ボタンでテスト実行

#### 方法3: コマンドラインから直接実行
```bash
# WSLから
cmd.exe /c "cd /d C:\\Users\\himaj\\project\\Zeit && C:\\Users\\himaj\\project\\Zeit\\Godot_v4.4.1-stable_win64.exe\\Godot_v4.4.1-stable_win64.exe --headless test/test_runner_scene.tscn"
```

テストが成功した場合は終了コード0、失敗がある場合は失敗数が終了コードとして返されます。

## 実装に関する決定事項

### アセット作成方法
- **家**: Kenney City Kit Industrialの「building-i.obj」を使用
  - ローポリでシンプルな工業建築
  - テクスチャ付き（colormap.png）
- **地面**: シンプルなPlane
- **道路**: MVPでは実装しない

### 技術的な質問への回答
- 家のアセットはGodot内でプロシージャルに作成（外部3Dソフト不要）
- 道路はMVPでは実装しない（将来の拡張として）