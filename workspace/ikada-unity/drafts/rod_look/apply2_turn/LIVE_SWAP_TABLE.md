# live baseline re-take (pre-shotwait) - dry run 2026-10-05 00:55
- reason: the live shots wait 139 frames instead of -ikadaTipSettle (track3/shot-hold f7af1d2, ROD_REST_A_W3.md §7.41-7.42, PRESIDENT 00:2x / 00:8x, worker2 the owner's GO). live_06 = after the dango is dropped: the rod in the hand, waiting for it to sink (shot after the 139-frame wait). live_08 (seed 26) = after the strike: the rod settled in the hand (139-frame wait: the move < 1 %, the tip spring 0.14 %). live_06C: the tip's line only.
- source regress: /home/ken/Documents/ikada-unity-track3/Logs/regress/f7af1d2_004153/

| seed | file | state | sha256 before (baseline) | sha256 source |
|---|---|---|---|---|
| 20260925 | live_04.png | same | 38e8695bb3357f1b3628bd07bbe329d5b1eb0036c3e8213939c324cf8ecc856d | 38e8695bb3357f1b3628bd07bbe329d5b1eb0036c3e8213939c324cf8ecc856d |
| 20260925 | live_05.png | same | b237ffb5f073944ad2f7e76b62be3f6bd8287cf9607b82593f3a81ca1f78fe5d | b237ffb5f073944ad2f7e76b62be3f6bd8287cf9607b82593f3a81ca1f78fe5d |
| 20260925 | live_06.png | changed | db8f3981aec8d8b3abbc01ffae403a906ba4dfe4d10d325fbfe8530f2e379a37 | 8dec5ebb05ecb4b566fe529fb005c153298f2437d186417024e8c38a9c9d8e34 |
| 20260925 | live_06C.png | changed | 9dd903c3eb484f33dc3475b0ba1d133c529db257ed3dd6148c77e625c66189f9 | 23df4f5734c8d70725ad5e1cf12c01f2a91b914557fd3c6a2c10a4d35c674d72 |
| 20260925 | live_07.png | same | d0d7eb534a414c60b2c2bfc978cf5488ad1fd3b89163f369307a1f6dfbbbf335 | d0d7eb534a414c60b2c2bfc978cf5488ad1fd3b89163f369307a1f6dfbbbf335 |
| 20260925 | live_J.png | same | 4695d0b8b68fd5ae46512f457db031e2720607819742498311e98eff415c5c0e | 4695d0b8b68fd5ae46512f457db031e2720607819742498311e98eff415c5c0e |
| 20260925 | RESULT.txt | same | 9beb2fe055eb2a62a486b7866316b09da9124db43da539cd0116a74ecb320358 | 9beb2fe055eb2a62a486b7866316b09da9124db43da539cd0116a74ecb320358 |
| 20260925 | live.log | changed | b0c63d415a52c60935b13113bfe9f67ead7c10a8cb9fc3cc346e7363ce7264b4 | fe94b5ad52c1680fc90fd2dabc276460d8e4e767c157c5fba092ed0b7e8be715 |
| 20260925 | ARGS.txt | changed | 24e49553de3a252a6078731f3e425ca6c9fc40c13a8d0b29752bba4864b2df3d | 9e36821d8b664cb5ae4dcf1b5cce541d169887777ba27d440b3b3299d534703d |
| 20260925 | AUDIO.txt | same | 3a21737d5df2ddacf03ea08fb23b5ba427346a5fef8dedd68908973486b7fdb8 | 3a21737d5df2ddacf03ea08fb23b5ba427346a5fef8dedd68908973486b7fdb8 |
| 1 | live_04.png | same | 38e8695bb3357f1b3628bd07bbe329d5b1eb0036c3e8213939c324cf8ecc856d | 38e8695bb3357f1b3628bd07bbe329d5b1eb0036c3e8213939c324cf8ecc856d |
| 1 | live_05.png | same | b237ffb5f073944ad2f7e76b62be3f6bd8287cf9607b82593f3a81ca1f78fe5d | b237ffb5f073944ad2f7e76b62be3f6bd8287cf9607b82593f3a81ca1f78fe5d |
| 1 | live_06.png | changed | 0ff7d4792d9f5d3264e79a1a7bbe4749c63f2353db9dc605d793a1482403f795 | add45f190d4c761f4bfd8f20a0e052fe483e247b1a36f6e58c6824ee55bbcdc8 |
| 1 | live_06C.png | changed | 6dac74209f40b3ef079821f9716c64ccb430061d7a5530e3c787d939f86b3433 | 906f03f1e11ce7f2f8a37d74997d571d8a617f5198e461020f476a36420c6187 |
| 1 | live_07.png | same | ddee45f918833ce6f5973af087012283d54af133595405fa5b7fdb21a8215be3 | ddee45f918833ce6f5973af087012283d54af133595405fa5b7fdb21a8215be3 |
| 1 | live_J.png | same | 5ae3bc89541ed728ac06718070874a32155ebf4b7e8b5e4bffb93628ef9acdb7 | 5ae3bc89541ed728ac06718070874a32155ebf4b7e8b5e4bffb93628ef9acdb7 |
| 1 | live_J_p2.png | same | cb20cb6b82d3bbe3f125fab98fbea2f9eb54825905efe6c6a87fccf4cef59ed8 | cb20cb6b82d3bbe3f125fab98fbea2f9eb54825905efe6c6a87fccf4cef59ed8 |
| 1 | RESULT.txt | same | ddfdb19189c99dd598fd6811e872ce3e6348c52a94ead6c6e50f79082ad5e176 | ddfdb19189c99dd598fd6811e872ce3e6348c52a94ead6c6e50f79082ad5e176 |
| 1 | live.log | changed | b81fb63c097b5a5478f10e1cc6a84f933063b99b3b02baa1f364fcc1c7b70213 | 0eca4e42e8a905e5616456981552ba13326cabffe16ea99d14425682a3f211bd |
| 1 | ARGS.txt | changed | f60ff7496de4b248e07ca50ce48b9272a06ca488df6dd7bf1e290881014f81ba | d9891bae67d7cc52b1e4475c207a9776bf75da28bf512eba45ac9b3fa96322e5 |
| 1 | AUDIO.txt | same | ebafb07b5a3f4d135d3a565ba6f1aed6b5019fa147ca28bc16637031183d330e | ebafb07b5a3f4d135d3a565ba6f1aed6b5019fa147ca28bc16637031183d330e |
| 26 | live_03.png | same | e256d86a94ab4ad9fc69512a9852f7c042f2a4b6383e5f77a0a1a49099215c89 | e256d86a94ab4ad9fc69512a9852f7c042f2a4b6383e5f77a0a1a49099215c89 |
| 26 | live_04.png | same | 38e8695bb3357f1b3628bd07bbe329d5b1eb0036c3e8213939c324cf8ecc856d | 38e8695bb3357f1b3628bd07bbe329d5b1eb0036c3e8213939c324cf8ecc856d |
| 26 | live_05.png | same | b237ffb5f073944ad2f7e76b62be3f6bd8287cf9607b82593f3a81ca1f78fe5d | b237ffb5f073944ad2f7e76b62be3f6bd8287cf9607b82593f3a81ca1f78fe5d |
| 26 | live_06.png | changed | f54b2900a96c60f5e819365a754aeb195018377f0d445aae9b89bc6737ce0ff1 | 0e9dcc646e1875435ef7d848febc3b0ad66a491a85b5b26b4b4b35468490f93c |
| 26 | live_06C.png | changed | a1b4391167e32643f814dcffdc7c3ae610357e6933db7cd8d6883637bd4e6bfc | 146d7f953e6f43a732b5a08a6c74b99e267a563a319a4663cdad35bb2ceaa87b |
| 26 | live_07.png | same | 3c35430f677daf12e37870933d9a2edbb174917635e6ea077e3784a4c09a6b19 | 3c35430f677daf12e37870933d9a2edbb174917635e6ea077e3784a4c09a6b19 |
| 26 | live_08.png | changed | 8db019d593fb5092f312c73b1381f6af58826301a5f724b6dcc36eef52f12a83 | 662641c878095bd8221b8e0d37aad1507283fd19ec39a767daabb3ed39d12769 |
| 26 | live_J.png | same | 7ec0d5109839b42909856d8ed088c8018c3a46ed6fa3dc3021a560004e7c6848 | 7ec0d5109839b42909856d8ed088c8018c3a46ed6fa3dc3021a560004e7c6848 |
| 26 | RESULT.txt | same | 08671810304dcb737058fa922d098e4247711ad22065b910d221287abbb8175b | 08671810304dcb737058fa922d098e4247711ad22065b910d221287abbb8175b |
| 26 | live.log | changed | 20bc3a1ec82804b66d067a27867fc4ad25336ce2b1f0a8b1c21f78e3eb9f68b2 | 464255c9f8053034d883ec1787c0e19b605a8a021d874679fdfeeb85d5404ad6 |
| 26 | ARGS.txt | changed | 3cb2b1219a97ab6c3aab893a8ff79f073cb28c2a8b0f461752ae34502c62063e | f6c155a48ff4f3dbc6d6da12c639ebf3cb255890002ce1a958db84001279d83b |
| 26 | AUDIO.txt | same | d469e8b84724283d2f0e25cdbf91e08b598fee4f6dec55bcc372746678ce7d95 | d469e8b84724283d2f0e25cdbf91e08b598fee4f6dec55bcc372746678ce7d95 |
- counts: {'changed': 13, 'added': 0, 'gone': 0, 'same': 20}

- labels (PRESIDENT 00:8x): live_06 = after the dango is dropped: the rod in the hand, waiting for it to sink (shot after the 139-frame wait) / live_08 (seed 26) = after the strike: the rod settled in the hand (139-frame wait: the move < 1 %, the tip spring 0.14 %)
- live.log diff (boss1 01:0x): logic lines 0 diff (3 seeds); frame counts + drawn values differ = drafts/rod_look/apply2_turn/livelog_diff_kinds.md
