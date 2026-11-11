# RE9 Insanity Autosave

REFramework mod for **Resident Evil Requiem (RE9)** that enables checkpoint autosaves on **Insanity** difficulty.

On Insanity, the game skips the story checkpoint autosaves that it performs on the other difficulties.
This mod lets those checkpoints autosave on Insanity too. The save goes to the game's own Insanity autosave slot.

## Requirements

- [REFramework](https://github.com/praydog/REFramework-nightly/releases) for Resident Evil Requiem

## Install

Copy `reframework/autorun/re9_insanity_autosave.lua` into the game folder, so that it ends up at:

```
<RESIDENT EVIL requiem install folder>/reframework/autorun/re9_insanity_autosave.lua
```

## Settings

Open the REFramework menu (Insert key by default) → **Script Generated UI** → **RE9 Insanity Autosave**.

| Option | Default | Description |
| --- | --- | --- |
| Enable autosave | On | Turns the mod on/off. |
| Insanity only | On | On: only affects Insanity. Off: forces checkpoint autosaves on every difficulty. |

The menu also shows the current difficulty and how many autosaves the mod has allowed in this session.
Settings are stored in `reframework/data/re9_insanity_autosave/config.json`.

## How it works

Story checkpoint autosaves are run by
`app.LevelFlowBehaviorTreeAction_FSM_AutoSaveAction` and `app.LevelFlowBehaviorTreeAction_FSM_BikeAutoSaveAction`.
Each checkpoint calls `isFilterDifficulty()`, which returns `true` only when the current difficulty is in that
checkpoint's difficulty list; otherwise the autosave is skipped.

This mod hooks `isFilterDifficulty()` and returns `true` when the game would have skipped the save
(only on Insanity by default). It does not add new save points and does not change where the game saves.

## Notes

- Back up your save data before using any mod.
- Insanity is detected as `GameDifficultyID.ID0040`.

## License

[MIT](LICENSE)

---

## 日本語

RE9（バイオハザード レクイエム）の最高難易度 **Insanity** でも、ストーリーのチェックポイントでオートセーブされるようにする REFramework 用 mod です。

- 導入: `reframework/autorun/re9_insanity_autosave.lua` をゲームフォルダの `reframework/autorun/` に置く（REFramework が必要）
- 設定: REFramework のメニュー → Script Generated UI → RE9 Insanity Autosave
  - Enable autosave: mod の有効/無効
  - Insanity only: オンなら Insanity のみ、オフなら全難易度でチェックポイントのオートセーブを強制
- 新しいセーブ地点は作りません。他の難易度で用意されているオートセーブ地点を Insanity でも有効にします。保存先はゲームの Insanity 用オートセーブ枠です。
