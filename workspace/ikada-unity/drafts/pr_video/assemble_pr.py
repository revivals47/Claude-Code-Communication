#!/usr/bin/env python3
"""PR video assembly (drafts/pr_video/PR_VIDEO_PLAN.md §4, worker3; PRESIDENT 2026-10-02 02:0x: captions A, the end = the title
「筏の涯へ」). Built on assemble_demo.py (the symlinked exact-count sequence, two copies with one sha256, the ffprobe line).

Input = a cut table (JSON):
  {"fps": 30, "size": [1920, 1080], "out": "pr_<tag>.mp4",
   "cuts": [ {"kind": "frames", "dir": <DemoCapture dir>, "from": <sim s>, "dur": <s>, "crop": [x0, y0, x1, y1]?, "fit": true?},
             {"kind": "stills", "images": [<png>...], "each": <s>, "xfade": <s>},
             {"kind": "title", "text": "筏の涯へ", "dur": <s>, "image": <png>?} ],
   "captions": [ {"text": "夜明けの筏。", "from": <s>, "to": <s>} ],
   "caption_y": 868, "audio": {"wav": <path>, "from": <s in the wav>}? }
- frames: the DemoCapture frames (frames.tsv, kind f) with sim t >= from, the first dur*fps of them (a capture is 30 fps of sim
  time); fewer than that = an error (never padded silently). crop = a box cut out and scaled to the size (no crop = as shot);
  with "fit": the box keeps its aspect, scaled to fit and centred on a dark ground ("ground": [r, g, b]).
- stills: each image shown `each` s, the next fading in over `xfade` s (PIL blend, linear).
- title: the text large in the centre, white, on black (or on `image`, darkened).
- captions: drawn on the frames whose time in the video is in [from, to): white, soft dark shadow, centred at caption_y.
- audio: the wav's [from, from + video length) as AAC 192 kbps; none = no audio stream (said in the report).
The report: every cut's frame count and source span, then ffprobe (codec, pix_fmt, size, r, frames, duration, size, audio streams).
usage: assemble_pr.py <table.json> [--out-dir A --copy-dir B] [--selftest]
--selftest: makes its own frames / stills in a temp dir and checks the result (900 frames, 30.000 s, h264, 1920x1080, 30/1).
"""
import argparse, csv, hashlib, json, os, shutil, subprocess, sys, tempfile
from PIL import Image, ImageDraw, ImageFilter, ImageFont

FONT = '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc'
SERIF = '/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc'


def frames_cut(c, fps, size):
    rows = [r for r in csv.DictReader(open(os.path.join(c['dir'], 'frames.tsv')), delimiter='\t') if r['kind'] == 'f']
    pick = [r for r in rows if float(r['t']) >= c['from']][:round(c['dur'] * fps)]
    need = round(c['dur'] * fps)
    if len(pick) < need:
        sys.exit(f"[assemble_pr] cut from {c['dir']} t>={c['from']}: {len(pick)} frames, {need} needed (never padded)")
    out = []
    for r in pick:
        im = Image.open(os.path.join(c['dir'], f"f_{int(r['index']):06d}.jpg")).convert('RGB')
        if c.get('crop') and c.get('fit'):   # aspect kept: scaled to fit, centred on a dark ground (a near-square panel never stretched)
            part = im.crop(tuple(c['crop'])); k = min(size[0] / part.width, size[1] / part.height)
            part = part.resize((round(part.width * k), round(part.height * k)), Image.LANCZOS)
            im = Image.new('RGB', size, tuple(c.get('ground', [10, 16, 24]))); im.paste(part, ((size[0] - part.width) // 2, (size[1] - part.height) // 2))
        elif c.get('crop'): im = im.crop(tuple(c['crop'])).resize(size, Image.LANCZOS)
        elif im.size != tuple(size): im = im.resize(size, Image.LANCZOS)
        out.append(im)
    return out, f"frames t {pick[0]['t']}..{pick[-1]['t']} ({len(pick)})"


def stills_cut(c, fps, size):
    ims = [Image.open(p).convert('RGB').resize(size, Image.LANCZOS) for p in c['images']]
    each, xf = round(c['each'] * fps), round(c.get('xfade', 0) * fps)
    out = []
    for i, im in enumerate(ims):
        for k in range(each):
            if i + 1 < len(ims) and xf > 0 and k >= each - xf:
                a = (k - (each - xf) + 1) / (xf + 1)
                out.append(Image.blend(im, ims[i + 1], a))
            else:
                out.append(im)
    return out, f"stills {len(ims)} x {each} frames, xfade {xf}"


def title_cut(c, fps, size):
    base = Image.open(c['image']).convert('RGB').resize(size, Image.LANCZOS) if c.get('image') else Image.new('RGB', size)
    if c.get('image'): base = Image.blend(base, Image.new('RGB', size), 0.55)
    d = ImageDraw.Draw(base); f = ImageFont.truetype(SERIF, c.get('px', 120))
    w = d.textlength(c['text'], font=f); d.text(((size[0] - w) / 2, size[1] / 2 - c.get('px', 120) * 0.7), c['text'], font=f, fill=(255, 255, 255))
    n = round(c['dur'] * fps)
    return [base] * n, f"title '{c['text']}' {n} frames"


def caption(im, text, y, px=54):
    im = im.copy(); f = ImageFont.truetype(FONT, px)
    d0 = ImageDraw.Draw(im); w = d0.textlength(text, font=f); x = (im.width - w) / 2
    sh = Image.new('L', im.size, 0); ds = ImageDraw.Draw(sh); ds.text((x, y - px / 2), text, font=f, fill=200)
    sh = sh.filter(ImageFilter.GaussianBlur(6))
    im.paste(Image.new('RGB', im.size, (0, 0, 0)), (0, 0), sh)
    ImageDraw.Draw(im).text((x, y - px / 2), text, font=f, fill=(255, 255, 255))
    return im


def build(table, out_dir, copy_dir):
    fps = table.get('fps', 30); size = tuple(table.get('size', [1920, 1080]))
    frames, report = [], []
    for c in table['cuts']:
        part, what = {'frames': frames_cut, 'stills': stills_cut, 'title': title_cut}[c['kind']](c, fps, size)
        report.append(f"[assemble_pr] cut {len(report) + 1} {c['kind']}: {what} -> video {len(frames) / fps:.2f}..{(len(frames) + len(part)) / fps:.2f} s")
        frames += part
    for cap in table.get('captions', []):
        for i in range(round(cap['from'] * fps), min(len(frames), round(cap['to'] * fps))):
            frames[i] = caption(frames[i], cap['text'], table.get('caption_y', 868))
        report.append(f"[assemble_pr] caption '{cap['text']}' {cap['from']}..{cap['to']} s")
    tmp = tempfile.mkdtemp(); seq = os.path.join(tmp, 'seq'); os.makedirs(seq)
    for i, im in enumerate(frames): im.save(os.path.join(seq, f'{i:06d}.jpg'), quality=95)
    os.makedirs(out_dir, exist_ok=True); out = os.path.join(out_dir, table['out'])
    cmd = ['ffmpeg', '-y', '-loglevel', 'error', '-framerate', str(fps), '-i', os.path.join(seq, '%06d.jpg')]
    au = table.get('audio')
    if au: cmd += ['-ss', str(au.get('from', 0)), '-t', f'{len(frames) / fps:.3f}', '-i', au['wav']]
    cmd += ['-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-r', str(fps), '-crf', str(table.get('crf', 18)), '-movflags', '+faststart']
    cmd += (['-c:a', 'aac', '-b:a', '192k', '-shortest'] if au else ['-an']) + [out]
    subprocess.run(cmd, check=True); shutil.rmtree(tmp)
    h = lambda p: hashlib.sha256(open(p, 'rb').read()).hexdigest()
    if copy_dir:
        os.makedirs(copy_dir, exist_ok=True); cp = os.path.join(copy_dir, os.path.basename(out)); shutil.copy2(out, cp)
        assert h(out) == h(cp), 'copy differs'
    pr = json.loads(subprocess.run(['ffprobe', '-v', 'error', '-count_frames', '-show_entries',
         'stream=codec_type,codec_name,pix_fmt,width,height,r_frame_rate,nb_read_frames:format=duration,size', '-of', 'json', out],
         capture_output=True, text=True, check=True).stdout)
    v = [s for s in pr['streams'] if s['codec_type'] == 'video'][0]; a = [s for s in pr['streams'] if s['codec_type'] == 'audio']
    for l in report: print(l)
    print(f"[assemble_pr] frames built {len(frames)} ({len(frames) / fps:.3f} s); mp4 {out}")
    print(f"[assemble_pr] ffprobe: video {v['codec_name']} {v['pix_fmt']} {v['width']}x{v['height']} r={v['r_frame_rate']} frames={v['nb_read_frames']} "
          f"duration={float(pr['format']['duration']):.3f}s size={int(pr['format']['size']) / 1e6:.1f}MB audio_streams={len(a)}"
          f"{' (' + a[0]['codec_name'] + ')' if a else ' (none: no wav given)'}; sha256 {h(out)}")
    return v, a, len(frames)


def selftest():
    t = tempfile.mkdtemp(); fd = os.path.join(t, 'cap'); os.makedirs(fd)
    with open(os.path.join(fd, 'frames.tsv'), 'w') as w:
        w.write('kind\tindex\tstep\tt\tscreen\n')
        for i in range(400):   # 400 frames of 30 fps sim time from t 100.0
            Image.new('RGB', (1920, 1080), (i % 256, 60, 120)).save(os.path.join(fd, f'f_{i:06d}.jpg'), quality=80)
            w.write(f'f\t{i}\t{2 * i}\t{100 + i / 30:.3f}\t06\n')
    st = []
    for k in range(3):
        p = os.path.join(t, f's{k}.png'); Image.new('RGB', (1920, 1080), (40 * k, 120, 40)).save(p); st.append(p)
    table = {'out': 'selftest.mp4', 'cuts': [
        {'kind': 'title', 'text': '筏の涯へ', 'dur': 2},
        {'kind': 'stills', 'images': st, 'each': 2, 'xfade': 0.6},
        {'kind': 'frames', 'dir': fd, 'from': 101.0, 'dur': 10},
        {'kind': 'frames', 'dir': fd, 'from': 103.0, 'dur': 5, 'crop': [16, 166, 503, 595], 'fit': True},
        {'kind': 'title', 'text': '筏の涯へ', 'dur': 7}],
        'captions': [{'text': '夜明けの筏。', 'from': 2, 'to': 8}, {'text': '穂先が、語る。', 'from': 8, 'to': 14}]}
    v, a, n = build(table, os.path.join(t, 'out'), None)
    ok = (n == 900 and v['nb_read_frames'] == '900' and v['codec_name'] == 'h264' and (v['width'], v['height']) == (1920, 1080)
          and v['r_frame_rate'] == '30/1' and not a)
    print(f"[assemble_pr] selftest {'PASS' if ok else 'FAIL'} (expected 900 frames h264 1920x1080 30/1, no audio)")
    shutil.rmtree(t); sys.exit(0 if ok else 1)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(); ap.add_argument('table', nargs='?'); ap.add_argument('--selftest', action='store_true')
    ap.add_argument('--out-dir', default='/home/ken/Documents/Claude-Code-Communication/workspace/ikada-unity/drafts/user_review')
    ap.add_argument('--copy-dir', default='/home/ken/Documents/ikada-play/pr')
    x = ap.parse_args()
    if x.selftest: selftest()
    build(json.load(open(x.table)), x.out_dir, x.copy_dir)
