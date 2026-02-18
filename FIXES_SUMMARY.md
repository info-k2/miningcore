# Исправления для MiningCore - Проблема с Duplicate Share после VarDiff

## Проблема
Antminer S19 выдавал ошибку 'Duplicate share' сразу после срабатывания Vardiff (смена сложности).

## Внесённые исправления

### 1. BitcoinPool.cs - Отправка mining.notify с clean_jobs=true после VarDiff
**Файл:** `src/Miningcore/Blockchain/Bitcoin/BitcoinPool.cs`
**Метод:** `OnVarDiffUpdateAsync`

После смены сложности пул теперь:
- Отправляет `mining.set_difficulty` с новой сложностью
- Сразу отправляет `mining.notify` с `clean_jobs: true`, чтобы майнеры сбросили старые задания

### 2. BitcoinJob.cs - Ключ дубликата с учётом Difficulty
**Файл:** `src/Miningcore/Blockchain/Bitcoin/BitcoinJob.cs`
**Метод:** `RegisterSubmit`

Ключ уникальности шары теперь включает текущую stratum difficulty:
- Старая логика: `extraNonce1 + extraNonce2 + nTime + nonce`
- Новая логика: `extraNonce1 + extraNonce2 + nTime + nonce + Difficulty`

Это позволяет одной и той же комбинации nTime/nonce на разных сложностях не считаться дубликатом.

### 3. VarDiffManager.cs - Степенная логика (степени двойки)
**Файл:** `src/Miningcore/VarDiff/VarDiffManager.cs`
**Методы:** `Update`, `IdleUpdate`, `TryApplyNewDiff`

- Сложность теперь округляется к ближайшей степени двойки (65536, 131072, 262144, ...)
- `maxDelta` работает как множитель (ratio), а не абсолютная разница
- С `maxDelta: 2.0` сложность поднимается плавно, максимум в 2 раза за раз

## Результат
✅ После VarDiff пул принимает шары без ошибок "Duplicate share"
✅ Сложность поднимается постепенно по степеням двойки
✅ Асик корректно обрабатывает смену сложности

## Дата исправлений
2026-02-17
