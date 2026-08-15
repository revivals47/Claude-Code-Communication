# P2_CD2D4_SPEC_worker2 — ★0x800CD2D4 全長 逐語（= オートパイロット を 含む 実装仕様）★

★受領★ = boss1 #543 ②／ ★測定時点★ = 2026-08-15 ／ ★emulator・GDB 非接触（PRESIDENT 走行中）★
★器★ = ★disasm 直読 ＋ w2_effect_cells（cfg_walk / 表 読み）★
★★⑥ 母数・窓・形★★ = ★関数 = ★0x800CD2D4〜0x800CD584 = ★173 語★★（★#543 の『171 語』は ★末尾 2 語（jr $ra ＋ 遅延 nop）を 落として います★ = ★私の 前便の 数も 同じ 誤り★★）
  ／ ★窓★ = ★使って いません（全 173 語 を 1 行ずつ）★ ／ ★形★ = ★jal 11 本 / jr $v0 1 本 / load・store 30 件（sp 28 / gp 1 / 表引き 1）★

## ★1. ★★③ 何を する 関数か（★item 22〜32 の 効果★）★★★

```
 ★入口★ = ★a0 = item id★（★呼び元 = 0x800EA614 / 0x801192EC = ★handler = 表[ [0x80145F90] ] / a0 = [0x80145F90]★★）
   ⇒ ★★∴ ★0x80145F90 = ★『使用中の item id』の cell★★★（= ★#514 ② で 私が 数えた cell の ★名★★）
 ★★index = item id - 22 / 11 未満だけ 分岐★★ ⇒ ★★item 22〜32 の 11 種だけ 中身が 在ります★★
   ⇒ ★item 33〜37（表では 同じ handler）は ★何も せず 尾へ 落ちます★★
 ★jump 表 = ★0x8011AD6C・11 entry★★（★実測 = 0x800CD378 / 3AC / 3C0 / 3D4 / 3E4 / 3F4 / 404 / 414 / 43C / 464 / 488★ = ★arm と 1 対 1★）
```

| item | 名 | 効果（逐語 から） |
|---|---|---|
| ★22★ | ★オートパイロット★ | ★[gp-0x6cb0] == 1 の ときだけ ★0x800CE860 → section 1245 起動★★ |
| 23 | 攻撃チップ | 攻撃 +50 |
| 24 | 防御チップ | 防御 +50 |
| 25 | かしこさチップ | かしこさ +50 |
| 26 | すばやさチップ | すばやさ +50 |
| 27 | ＨＰチップ | HP 上限 +500 |
| 28 | ＭＰチップ | MP 上限 +500 |
| 29 | デビルチップＡ | 攻撃 +100 ／ かしこさ +100 ／ ★罰 -24★ ＋ ★0x800B0224(10,-1)★ |
| 30 | デビルチップＤ | 防御 +100 ／ すばやさ +100 ／ ★罰 -24★ ＋ ★同上★ |
| 31 | デビルチップＥ | HP 上限 +1000 ／ MP 上限 +1000 ／ ★罰 -24★ ＋ ★同上★ |
| 32 | けいたいトイレ | ★0x800CEA10 を 呼び ★尾を 通らずに 戻る★★ |

```
 ★★∴ ★説明文（#537 の 表）と ★数値まで 一致★★★（例 = 23「攻撃力を 永久に ＋５０」= s1 に 50）
```

## ★2. ★★② 1245 を 呼ぶ 前後で 何を するか（★item 22 の arm 逐語★）★★★

```
 ★800CD378  lw $v0, -0x6cb0($gp)★      ← ★唯一の gp cell★
 ★800CD380  bne $v0, 1 → 0x800CD498★   ← ★★1 でなければ ★何も せず★ 尾へ★★
 ★★800CD388  jal 0x800CE860★★           ← ★前★:  ★中身 = `if ([0x80145F90] != 255) { jal 0x800A4168(404, 0); [0x80145F90] = 255; }`★
   ⇒ ★★∴ ★『使用中 item id』を ★255（= 無し）に 戻す★★★（★#514 ② で 私が 数えた ★定数 255 の 書き手 2 件の 1 つが これ★）
 ★800CD390  a0 = 0★ / ★800CD394  a1 = 0x4dd = ★1245★★ / ★800CD398  a2 = 0★
 ★★800CD39C  jal 0x800F0188★★           ← ★★汎用 入口（entry 0 = MAPHEAD / section 1245）★★
 ★800CD3A4  b 0x800CD498★              ← ★後★: ★共通の 尾へ★（★item 22 では 加算値が 全部 0 なので ★尾は 実質 何も 変えません★）
 ★★∴ ★1245 を 呼ぶ 前後で する ことは ★『255 に 戻す』だけ★★★
```

## ★3. ★★④ [gp-0x6CB0] を 何に 使うか★★★

```
 ★★この 関数での 用途 = ★1 と 比べる だけ★★★（★他の 使い方は 173 語の 中に ありません★）
 ★形★ = ★`lw` → `addiu $at,$zero,1` → `bne`★ ⇒ ★★1 以外は ★オートパイロットが 不発★★★
 ★★∴ ★#520 ③ の 値域 {0,1}（書き手 5 件 全部 定数）と 併せると★★:
   ★★『1 の とき だけ 街へ 戻れる』★★ = ★★= 失敗条件は ★これ 1 つ★★★（★意味（何の 1 か）は 決めません★）
```

## ★4. ★★③ item を 消費するか / 失敗条件★★★

```
 ★★在庫を 減らす code = ★173 語の 中に 0 件★★★（★sp 以外の store は ★1 件も ありません★ = §5）
   ⇒ ★★∴ ★消費は ★呼び元 側★★★（★私は 呼び元を 本便で 読んで いません = ★開示★）
 ★★後始末★★ = ★0x800CE860 が ★使用中 item id を 255 に 戻す★★（★item 22 の arm ＋ 呼び元 0x800EA634 の 両方に 在ります★）
 ★★失敗条件★★ = ★★① item id が 22..32 の 外（33..37）→ 何も しない★★ / ★★② item 22 で [gp-0x6cb0] != 1 → 何も しない★★
   ⇒ ★★他の 9 種（23..31）に 失敗条件は ★在りません★★★（★上限 clamp は 在ります★）
```

## ★5. ★★⑤ sp 28 件 / v0 1 件 の 素性（★塞げた か★）★★★

```
 ★★sp 28 件 = ★全部 素性が 割れました★★★（母数 = 173 語）:
   ★0x10 / 0x14 / 0x18 / 0x1c = 各 2 件★ = ★s0 / s1 / s2 / ra の 退避と 復帰★（8 件）
   ★0x20 = 4 件★ = ★すばやさ 加算★ / ★0x22 = 4 件★ = ★かしこさ 加算★
   ★0x24 = 4 件★ = ★HP 上限 加算★ / ★0x26 = 4 件★ = ★MP 上限 加算★（16 件）
   ★0x28 = 4 件★ = ★a0（item id）の 保存 1 ＋ 読み直し 3★（4 件）
   ⇒ ★★∴ ★sp は ★局所 と 引数だけ★ = ★状態では ありません★★★（★#520 の 開示を ★閉じられました★★）
 ★★v0 1 件 = ★0x800CD368 lw $v0,($v0)★ = ★jump 表 0x8011AD6C の 読み★★★
   ⇒ ★★∴ ★表の 中身を 実測しました（11 entry 全部 この 関数の arm）★★ = ★★これも 閉じられました★★
 ★★∴ ★#520 ③ で 私が 開示した『sp 28 / v0 1 は 塞げない』は ★本便で 両方 閉じます★★★
   ★残る 開示★ = ★jal 11 本の 先（0x800CE860 / 0x800F0188 / 0x800CE8A8 x6 / 0x800CEAA8 / 0x800CEA10 / 0x800B0224）★ は ★別関数★
```

## ★6. ★★呼ぶ 相手の 逐語（★実装に 要る 分だけ★）★★★

```
 ★★0x800CE8A8(addr, delta, cap)★★ = ★`*addr += delta;` ＋ ★`if (cap < *addr) *addr = cap;`★★
   ⇒ ★★上限 clamp だけ★★（★下限 clamp は ★在りません★★）
 ★★0x800CEAA8(delta)★★ = ★`*(0x80141D60) += delta;` ＋ ★`if (*p < 0) *p = 0;`★★（★下限 0★）
 ★★0x800CE860()★★ = ★`if ([0x80145F90] != 255) { 0x800A4168(404, 0); [0x80145F90] = 255; }`★
 ★★0x800B0224(10, -1)★★ = ★冒頭で ★0x800A4A74(100)（= 100 面の 乱数）★ を 引き ★a0(=10) と 比べます★
   ⇒ ★★∴ ★10% の 確率で 何かを -1 する 形★★（★中身の 先は 本便では 追って いません = ★開示★）
 ★★0x800CEA10()★★ = ★0x80141D18 の ★bit 3（andi 8）★ が 0 なら ★何も せず 戻る★★（★けいたいトイレの 前提条件★）
 ★0x800F0188(a0=0, a1=1245, a2=0)★ = ★#478 で 出した 汎用 入口★
```

## ★7. ★★① 全長 逐語（★173 語・打ち切り なし★）★★★

```

800CD2D4  addiu $sp, $sp, -0x28              
800CD2D8  sw $ra, 0x1c($sp)                  
800CD2DC  sw $s2, 0x18($sp)                  
800CD2E0  sw $s1, 0x14($sp)                  
800CD2E4  sw $s0, 0x10($sp)                  
800CD2E8  sw $a0, 0x28($sp)                  ← a0 = item id を frame に 保存
800CD2EC  move $s0, $zero                    ← s0 = 0（罰の 量）
800CD2F0  sll $v0, $zero, 0x10               
800CD2F4  sra $v0, $v0, 0x10                 
800CD2F8  sh $v0, 0x26($sp)                  ← [sp+0x26] = 0（MP 上限 加算）
800CD2FC  sll $v0, $v0, 0x10                 
800CD300  sra $v0, $v0, 0x10                 
800CD304  sh $v0, 0x24($sp)                  ← [sp+0x24] = 0（HP 上限 加算）
800CD308  sll $v0, $v0, 0x10                 
800CD30C  sra $v0, $v0, 0x10                 
800CD310  sh $v0, 0x22($sp)                  ← [sp+0x22] = 0（かしこさ 加算）
800CD314  sll $v0, $v0, 0x10                 
800CD318  sra $v0, $v0, 0x10                 
800CD31C  sh $v0, 0x20($sp)                  ← [sp+0x20] = 0（すばやさ 加算）
800CD320  sll $v0, $v0, 0x10                 
800CD324  sra $v0, $v0, 0x10                 
800CD328  sll $s2, $v0, 0x10                 
800CD32C  sra $s2, $s2, 0x10                 ← s2 = 0（防御 加算）
800CD330  sll $v0, $v0, 0x10                 
800CD334  sra $v0, $v0, 0x10                 
800CD338  sll $s1, $v0, 0x10                 
800CD33C  sra $s1, $s1, 0x10                 ← s1 = 0（攻撃 加算）
800CD340  lh $v0, 0x28($sp)                  
800CD344  nop                                
800CD348  addi $v0, $v0, -0x16               ← index = item id - 22
800CD34C  sltiu $at, $v0, 0xb                ← index < 11 か（= item 22..32 だけ）
800CD350  beqz $at, 0x800cd498               ← 外なら 何も せず 尾へ
800CD354  nop                                
800CD358  lui $v1, 0x8012                    
800CD35C  addiu $v1, $v1, -0x5294            ← jump 表 = 0x8011AD6C（11 entry）
800CD360  sll $v0, $v0, 2                    
800CD364  addu $v0, $v0, $v1                 
800CD368  lw $v0, ($v0)                      
800CD36C  nop                                
800CD370  jr $v0                             ← 表引き（= 私の 器の 見えない 1 件）
800CD374  nop                                
800CD378  lw $v0, -0x6cb0($gp)               ← ★item 22 arm★ [gp-0x6cb0] を 読む
800CD37C  addiu $at, $zero, 1                
800CD380  bne $v0, $at, 0x800cd498           ← ★1 でなければ 何も せず 尾へ★
800CD384  nop                                
800CD388  jal 0x800ce860                     ← 使用中 item id を 255 に 戻す
800CD38C  nop                                
800CD390  move $a0, $zero                    
800CD394  addiu $a1, $zero, 0x4dd            ← a1 = 0x4dd = 1245
800CD398  move $a2, $zero                    
800CD39C  jal 0x800f0188                     ← ★section 1245 を 起動★
800CD3A0  nop                                
800CD3A4  b 0x800cd498                       
800CD3A8  nop                                
800CD3AC  addiu $v0, $zero, 0x32             ← item 23 = 攻撃 +50
800CD3B0  sll $s1, $v0, 0x10                 
800CD3B4  sra $s1, $s1, 0x10                 
800CD3B8  b 0x800cd498                       
800CD3BC  nop                                
800CD3C0  addiu $v0, $zero, 0x32             ← item 24 = 防御 +50
800CD3C4  sll $s2, $v0, 0x10                 
800CD3C8  sra $s2, $s2, 0x10                 
800CD3CC  b 0x800cd498                       
800CD3D0  nop                                
800CD3D4  addiu $v0, $zero, 0x32             ← item 25 = かしこさ +50
800CD3D8  sh $v0, 0x22($sp)                  
800CD3DC  b 0x800cd498                       
800CD3E0  nop                                
800CD3E4  addiu $v0, $zero, 0x32             ← item 26 = すばやさ +50
800CD3E8  sh $v0, 0x20($sp)                  
800CD3EC  b 0x800cd498                       
800CD3F0  nop                                
800CD3F4  addiu $v0, $zero, 0x1f4            ← item 27 = HP 上限 +500
800CD3F8  sh $v0, 0x24($sp)                  
800CD3FC  b 0x800cd498                       
800CD400  nop                                
800CD404  addiu $v0, $zero, 0x1f4            ← item 28 = MP 上限 +500
800CD408  sh $v0, 0x26($sp)                  
800CD40C  b 0x800cd498                       
800CD410  nop                                
800CD414  addiu $v0, $zero, 0x64             ← item 29 = 攻撃 +100 / かしこさ +100 / 罰 -24
800CD418  sll $s1, $v0, 0x10                 
800CD41C  sra $s1, $s1, 0x10                 
800CD420  addiu $v0, $zero, 0x64             
800CD424  sh $v0, 0x22($sp)                  
800CD428  addiu $v0, $zero, -0x18            
800CD42C  sll $s0, $v0, 0x10                 
800CD430  sra $s0, $s0, 0x10                 
800CD434  b 0x800cd498                       
800CD438  nop                                
800CD43C  addiu $v0, $zero, 0x64             ← item 30 = 防御 +100 / すばやさ +100 / 罰 -24
800CD440  sll $s2, $v0, 0x10                 
800CD444  sra $s2, $s2, 0x10                 
800CD448  addiu $v0, $zero, 0x64             
800CD44C  sh $v0, 0x20($sp)                  
800CD450  addiu $v0, $zero, -0x18            
800CD454  sll $s0, $v0, 0x10                 
800CD458  sra $s0, $s0, 0x10                 
800CD45C  b 0x800cd498                       
800CD460  nop                                
800CD464  addiu $v0, $zero, 0x3e8            ← item 31 = HP・MP 上限 +1000 / 罰 -24
800CD468  sh $v0, 0x24($sp)                  
800CD46C  addiu $v0, $zero, 0x3e8            
800CD470  sh $v0, 0x26($sp)                  
800CD474  addiu $v0, $zero, -0x18            
800CD478  sll $s0, $v0, 0x10                 
800CD47C  sra $s0, $s0, 0x10                 
800CD480  b 0x800cd498                       
800CD484  nop                                
800CD488  jal 0x800cea10                     ← item 32 = けいたいトイレ（尾を 通らず 戻る）
800CD48C  nop                                
800CD490  b 0x800cd56c                       
800CD494  nop                                
800CD498  lui $a0, 0x8017                    ← ★共通の 尾★ 0x8016B0CC += HP（上限 9999）
800CD49C  addiu $a0, $a0, -0x4f34            
800CD4A0  lh $a1, 0x24($sp)                  
800CD4A4  addiu $a2, $zero, 0x270f           
800CD4A8  jal 0x800ce8a8                     
800CD4AC  nop                                
800CD4B0  lui $a0, 0x8017                    ← 0x8016B0CE += MP（上限 9999）
800CD4B4  addiu $a0, $a0, -0x4f32            
800CD4B8  lh $a1, 0x26($sp)                  
800CD4BC  addiu $a2, $zero, 0x270f           
800CD4C0  jal 0x800ce8a8                     
800CD4C4  nop                                
800CD4C8  lui $a0, 0x8017                    ← 0x8016B0BC += 攻撃(s1)（上限 999）
800CD4CC  addiu $a0, $a0, -0x4f44            
800CD4D0  move $a1, $s1                      
800CD4D4  addiu $a2, $zero, 0x3e7            
800CD4D8  jal 0x800ce8a8                     
800CD4DC  nop                                
800CD4E0  lui $a0, 0x8017                    ← 0x8016B0BE += 防御(s2)（上限 999）
800CD4E4  addiu $a0, $a0, -0x4f42            
800CD4E8  move $a1, $s2                      
800CD4EC  addiu $a2, $zero, 0x3e7            
800CD4F0  jal 0x800ce8a8                     
800CD4F4  nop                                
800CD4F8  lui $a0, 0x8017                    ← 0x8016B0C0 += すばやさ（上限 999）
800CD4FC  addiu $a0, $a0, -0x4f40            
800CD500  lh $a1, 0x20($sp)                  
800CD504  addiu $a2, $zero, 0x3e7            
800CD508  jal 0x800ce8a8                     
800CD50C  nop                                
800CD510  lui $a0, 0x8017                    ← 0x8016B0C2 += かしこさ（上限 999）
800CD514  addiu $a0, $a0, -0x4f3e            
800CD518  lh $a1, 0x22($sp)                  
800CD51C  addiu $a2, $zero, 0x3e7            
800CD520  jal 0x800ce8a8                     
800CD524  nop                                
800CD528  move $a0, $s0                      ← 0x80141D60 += s0（下限 0）= 罰
800CD52C  jal 0x800ceaa8                     
800CD530  nop                                
800CD534  lh $v0, 0x28($sp)                  
800CD538  nop                                
800CD53C  slti $at, $v0, 0x1d                ← item id < 29 なら 戻る
800CD540  bnez $at, 0x800cd56c               
800CD544  nop                                
800CD548  lh $v0, 0x28($sp)                  
800CD54C  nop                                
800CD550  slti $at, $v0, 0x20                ← item id >= 32 なら 戻る
800CD554  beqz $at, 0x800cd56c               
800CD558  nop                                
800CD55C  addiu $a0, $zero, 0xa              
800CD560  addiu $a1, $zero, -1               
800CD564  jal 0x800b0224                     ← ★29..31 だけ 0x800B0224(10,-1)★
800CD568  nop                                
800CD56C  lw $ra, 0x1c($sp)                  
800CD570  lw $s2, 0x18($sp)                  
800CD574  lw $s1, 0x14($sp)                  
800CD578  lw $s0, 0x10($sp)                  
800CD57C  addiu $sp, $sp, 0x28               
800CD580  jr $ra                             
800CD584  nop                                
```

## ★8. ★『0 件』の 4 家族★

```
 ★① 打ち切り★    = ★なし★（★173 語 全部・jump 表 11 entry 全部★）
 ★② 走査型の 外★ = ★★該当★★ = ★jal 11 本の 先（別関数）★ / ★0x800B0224 の 中身★
 ★③ 沈黙★        = ★なし★
 ★④ 母数の 縮小★ = ★していません★（★逆に 171 → 173 に ★増やしました★★）
```

## ★9. ★★意味★★★ = ★★決めません★★（★item 名と 説明文との 一致は ★#537 の 表 join の 結果★ です★）

