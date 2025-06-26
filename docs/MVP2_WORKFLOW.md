# MVP-2: 円形住宅エリアシステム実装ワークフロー

## Phase 1: GridManager拡張（円形エリア判定）
- [x] `residential_area_test.gd` を作成
  - [x] 中心点の設定テスト
  - [x] 円形エリア内判定テスト
  - [x] 円形エリア外判定テスト
- [x] GridManagerに円形エリア機能を実装
  - [x] center_position プロパティ追加
  - [x] residential_radius プロパティ追加
  - [x] is_within_residential_area() メソッド実装
- [x] テストを実行して全て成功を確認

## Phase 2: 隣接・密度計算
- [x] `adjacency_density_test.gd` を作成
  - [x] 隣接建物カウントテスト（0〜4）
  - [x] エリア密度計算テスト
  - [x] エッジケーステスト（境界付近）
- [x] GridManagerに隣接・密度機能を実装
  - [x] get_adjacent_buildings_count() メソッド実装
  - [x] get_area_density() メソッド実装
- [x] テストを実行して全て成功を確認

## Phase 3: 優先度計算システム
- [x] `priority_calculation_test.gd` を作成
  - [x] 隣接ボーナス計算テスト
  - [x] 密度ボーナス計算テスト
  - [x] 距離ペナルティ計算テスト
  - [x] 総合優先度計算テスト
- [x] GridManagerに優先度計算を実装
  - [x] calculate_placement_priority() メソッド実装
  - [x] 各種重みパラメータ追加
- [x] テストを実行して全て成功を確認

## Phase 4: 最適位置選択
- [x] `best_position_test.gd` を作成
  - [x] 空きグリッドから最適位置選択テスト
  - [x] 同点時のランダム選択テスト
  - [x] エリア外を除外するテスト
  - [x] 全グリッド埋まり時のテスト
- [x] GridManagerに最適位置選択を実装
  - [x] get_best_position() メソッド実装
  - [x] get_available_positions() の修正（円形エリア対応）
- [x] テストを実行して全て成功を確認

## Phase 5: GameManager統合
- [x] `game_manager_integration_test.gd` を作成
  - [x] 新しい配置ロジックでの家生成テスト
  - [x] 最初の家が中心に配置されるテスト
  - [x] 集落形成パターンテスト
- [x] GameManagerの更新
  - [x] _spawn_house() メソッドの修正
  - [x] 最初の家の特別処理追加
- [x] テストを実行して全て成功を確認

## Phase 6: 動的エリア拡大
- [x] `area_expansion_test.gd` を作成
  - [x] 占有率計算テスト
  - [x] 70%超でのエリア拡大テスト
  - [x] 最大半径制限テスト
- [x] エリア拡大機能の実装
  - [x] calculate_occupancy_rate() メソッド追加
  - [x] expand_residential_area() メソッド追加
  - [x] GameManagerに自動拡大ロジック追加
- [x] テストを実行して全て成功を確認

## Phase 7: 統合テストと最終調整
- [x] `mvp2_integration_test.gd` を作成
  - [x] 完全なゲームフローテスト
  - [x] 自然な街の成長パターンテスト
  - [x] パフォーマンステスト（大規模な街）
- [x] パラメータの微調整
  - [x] 各種ボーナスの重み調整
  - [x] エリア拡大の閾値調整
- [x] 全テストスイートを実行（既存 + 新規）
- [x] デバッグとバグ修正

## 完了条件
- [x] 全テスト（既存38 + 新規35 = 73）が成功
- [x] 中心から外側への自然な街の成長を確認
- [x] 集落形成パターンが自然であることを確認
- [x] パフォーマンスが許容範囲内であることを確認