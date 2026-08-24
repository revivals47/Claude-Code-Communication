#!/bin/bash
until grep -q "★完了★" /home/ken/w3size.out 2>/dev/null; do sleep 5; done
echo "=== ① 完了 → ② 起動 ===" >> /home/ken/w3L.out
python3 /home/ken/w3L.py >> /home/ken/w3L.out 2>&1
