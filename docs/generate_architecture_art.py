#!/usr/bin/env python3
"""Muse Architecture — Neural Cartography Canvas (Refined)"""

from PIL import Image, ImageDraw, ImageFont
import math
import os
import random

random.seed(42)

# Canvas
W, H = 2400, 3000
img = Image.new('RGB', (W, H), '#080B14')
draw = ImageDraw.Draw(img)

# Fonts
FONT_DIR = os.path.expanduser('~/.claude/skills/canvas-design/canvas-fonts')

KR_FONT = '/System/Library/Fonts/AppleSDGothicNeo.ttc'

def load_font(name, size):
    try:
        return ImageFont.truetype(os.path.join(FONT_DIR, name), size)
    except:
        return ImageFont.load_default()

def kr_font(size, index=0):
    """Korean-capable font"""
    return ImageFont.truetype(KR_FONT, size, index=index)

font_title = load_font('Jura-Medium.ttf', 80)
font_sub = load_font('Jura-Light.ttf', 30)
font_label = load_font('DMMono-Regular.ttf', 22)
font_label_sm = load_font('DMMono-Regular.ttf', 16)
font_node = load_font('InstrumentSans-Regular.ttf', 24)
font_node_bold = load_font('InstrumentSans-Bold.ttf', 26)
font_node_sm = load_font('InstrumentSans-Regular.ttf', 18)
font_kr = kr_font(20)          # Korean text
font_kr_sm = kr_font(16)       # Korean small
font_code = load_font('GeistMono-Regular.ttf', 15)
font_code_lg = load_font('GeistMono-Regular.ttf', 18)
font_accent = load_font('Italiana-Regular.ttf', 24)
font_num = load_font('Jura-Medium.ttf', 48)

# Palette
AMBER = '#E8A849'
AMBER_MID = '#A07030'
AMBER_DIM = '#604020'
INDIGO = '#5580B5'
INDIGO_DIM = '#2A4060'
CORAL = '#D4726A'
CORAL_DIM = '#6A3A36'
SAGE = '#5AAA8B'
SAGE_DIM = '#2A5040'
SLATE = '#1A2030'
GHOST = '#252A38'
WHITE = '#C8CCD4'
DIM = '#505868'

CX = W // 2  # Center X

# === HELPERS ===
def circle(cx, cy, r, fill=None, outline=None, width=2):
    draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=fill, outline=outline, width=width)

def dashed_ring(cx, cy, r, color, segs=72, skip=3):
    for i in range(segs):
        if i % skip == 0:
            continue
        a1 = 2 * math.pi * i / segs
        a2 = 2 * math.pi * (i + 0.7) / segs
        draw.line([
            (cx + r * math.cos(a1), cy + r * math.sin(a1)),
            (cx + r * math.cos(a2), cy + r * math.sin(a2))
        ], fill=color, width=1)

def bezier(x1, y1, x2, y2, color, w=1, curve=0.12):
    steps = 50
    dx, dy = x2 - x1, y2 - y1
    mx, my = (x1+x2)/2 - dy*curve, (y1+y2)/2 + dx*curve
    pts = []
    for i in range(steps+1):
        t = i / steps
        px = (1-t)**2*x1 + 2*(1-t)*t*mx + t**2*x2
        py = (1-t)**2*y1 + 2*(1-t)*t*my + t**2*y2
        pts.append((px, py))
    for i in range(len(pts)-1):
        draw.line([pts[i], pts[i+1]], fill=color, width=w)

def tcenter(x, y, text, font, fill):
    bb = draw.textbbox((0, 0), text, font=font)
    draw.text((x - (bb[2]-bb[0])/2, y - (bb[3]-bb[1])/2), text, font=font, fill=fill)

def glow_circle(cx, cy, r, color, rings=4):
    """Soft glow effect"""
    for i in range(rings, 0, -1):
        alpha = max(8, 25 - i * 5)
        # Parse color and dim it
        cr = int(color[1:3], 16)
        cg = int(color[3:5], 16)
        cb = int(color[5:7], 16)
        gc = f'#{cr*alpha//255:02x}{cg*alpha//255:02x}{cb*alpha//255:02x}'
        circle(cx, cy, r + i * 8, fill=None, outline=gc, width=1)

# === BACKGROUND: Fine grid + noise ===
for x in range(0, W, 80):
    w = 1 if x % 400 != 0 else 1
    draw.line([(x, 0), (x, H)], fill='#0D1018' if x % 400 != 0 else '#121620', width=w)
for y in range(0, H, 80):
    draw.line([(0, y), (W, y)], fill='#0D1018' if y % 400 != 0 else '#121620', width=1)

# Scatter constellation dots
for _ in range(120):
    x, y = random.randint(40, W-40), random.randint(40, H-40)
    r = random.choice([1, 1, 1, 2])
    v = random.randint(15, 35)
    circle(x, y, r, fill=f'#{v:02x}{v+5:02x}{v+15:02x}')

# === HEADER ===
draw.line([(80, 60), (W-80, 60)], fill=GHOST, width=1)
draw.text((80, 30), 'NC-001', font=font_code, fill=DIM)
draw.text((W-200, 30), '2026.03.22', font=font_code, fill=DIM)

tcenter(CX, 120, 'M U S E', font=font_title, fill=WHITE)
tcenter(CX, 180, 'System Architecture · Neural Cartography', font=font_sub, fill=DIM)
draw.line([(CX-180, 210), (CX+180, 210)], fill=AMBER_DIM, width=1)

# === LAYER 01: FLUTTER UI ===
Y1 = 380
# Layer label
draw.text((80, Y1-30), '01', font=font_num, fill=AMBER_DIM)
draw.text((80, Y1+25), 'INTERFACE', font=font_label_sm, fill=AMBER_MID)

# Main node: Flutter
glow_circle(CX, Y1, 60, AMBER)
circle(CX, Y1, 60, fill='#12180E', outline=AMBER, width=3)
tcenter(CX, Y1-12, 'Flutter', font=font_node_bold, fill=AMBER)
tcenter(CX, Y1+14, 'Riverpod · GoRouter', font=font_code, fill=AMBER_MID)

# 4 Bottom Nav tabs
tab_data = [
    ('채팅', CX-320, Y1-20),
    ('캐릭터', CX-160, Y1-120),
    ('시나리오', CX+160, Y1-120),
    ('내 정보', CX+320, Y1-20),
]
for label, tx, ty in tab_data:
    circle(tx, ty, 32, fill=SLATE, outline=AMBER_MID, width=2)
    tcenter(tx, ty, label, font=font_kr, fill=AMBER)
    bezier(CX, Y1, tx, ty, AMBER_DIM, 1, 0.08)

# Full-screen routes
route_data = [
    ('Chat 1:1', CX-260, Y1+130),
    ('Group Chat', CX, Y1+155),
    ('PIN Auth', CX+260, Y1+130),
]
for label, rx, ry in route_data:
    circle(rx, ry, 24, fill=None, outline=AMBER_DIM, width=1)
    tcenter(rx, ry, label, font=font_code, fill=AMBER_DIM)
    bezier(CX, Y1+60, rx, ry-24, '#2A2010', 1)

# === VERTICAL SPINE ===
# Animated-looking vertical connector
for y in range(Y1+60, Y1+210, 3):
    progress = (y - Y1 - 60) / 150
    alpha = int(20 + 30 * (1 - progress))
    draw.line([(CX-1, y), (CX+1, y)], fill=f'#{alpha:02x}{alpha+5:02x}{alpha:02x}', width=2)

tcenter(CX+100, Y1+180, 'HTTP Stream', font=font_code, fill='#303848')

# === LAYER 02: FASTAPI ===
Y2 = 750
draw.text((80, Y2-30), '02', font=font_num, fill=INDIGO_DIM)
draw.text((80, Y2+25), 'API LAYER', font=font_label_sm, fill=INDIGO_DIM)

glow_circle(CX, Y2, 65, INDIGO)
circle(CX, Y2, 65, fill='#0E1320', outline=INDIGO, width=3)
tcenter(CX, Y2-14, 'FastAPI', font=font_node_bold, fill=INDIGO)
tcenter(CX, Y2+12, 'Python 3.12', font=font_code, fill=INDIGO_DIM)

# API endpoints in orbital arrangement
api_nodes = [
    ('/auth',        CX-340, Y2-70,  'JWT · PIN'),
    ('/characters',  CX-300, Y2+50,  'CRUD · Gen'),
    ('/scenarios',   CX-200, Y2+130, 'CRUD · Gen'),
    ('/chat',        CX+340, Y2-70,  'Streaming'),
    ('/group-chat',  CX+300, Y2+50,  'God Agent'),
    ('/conversations',CX+200, Y2+130,'History'),
    ('/personas',    CX-80,  Y2+160, 'Identity'),
    ('/static',      CX+80,  Y2+160, 'Avatars'),
]
for label, ax, ay, desc in api_nodes:
    circle(ax, ay, 28, fill=None, outline=INDIGO_DIM, width=1)
    tcenter(ax, ay-6, label, font=font_code, fill=INDIGO)
    tcenter(ax, ay+12, desc, font=font_code, fill='#2A3858')
    bezier(CX, Y2, ax, ay, '#152238', 1, 0.06)

# Orbital ring
dashed_ring(CX, Y2+30, 300, '#1A2540', segs=100)

# === VERTICAL SPINE 2 ===
for y in range(Y2+65, Y2+200, 3):
    progress = (y - Y2 - 65) / 135
    alpha = int(25 + 25 * (1 - progress))
    draw.line([(CX-1, y), (CX+1, y)], fill=f'#{alpha:02x}{int(alpha*0.6):02x}{int(alpha*0.6):02x}', width=2)

# === LAYER 03: CLAUDE LLM ===
Y3 = 1150
draw.text((80, Y3-30), '03', font=font_num, fill=CORAL_DIM)
draw.text((80, Y3+25), 'INTELLIGENCE', font=font_label_sm, fill=CORAL_DIM)

# Pulsing rings
for r_offset in range(4):
    dashed_ring(CX, Y3, 90 + r_offset * 35, CORAL_DIM, segs=90+r_offset*10)

glow_circle(CX, Y3, 70, CORAL)
circle(CX, Y3, 70, fill='#14100E', outline=CORAL, width=3)
tcenter(CX, Y3-16, 'Claude', font=font_node_bold, fill=CORAL)
tcenter(CX, Y3+8, 'LLM Engine', font=font_code, fill=CORAL_DIM)
tcenter(CX, Y3+26, 'claude -p CLI', font=font_code, fill='#3A2220')

# Model variants
model_nodes = [
    ('Sonnet', CX-250, Y3, '대화 · 롤플레이', 40),
    ('Haiku', CX+250, Y3, '자동생성', 35),
]
for name, mx, my, desc, mr in model_nodes:
    circle(mx, my, mr, fill=SLATE, outline=CORAL_DIM, width=2)
    tcenter(mx, my-8, name, font=font_node_sm, fill=CORAL)
    tcenter(mx, my+10, desc, font=font_kr_sm, fill=CORAL_DIM)
    bezier(CX, Y3, mx, my, CORAL_DIM, 1, 0.1)

# God Agent
circle(CX, Y3+180, 38, fill=SLATE, outline=CORAL, width=2)
tcenter(CX, Y3+172, 'God Agent', font=font_node_sm, fill=CORAL)
tcenter(CX, Y3+192, 'Orchestrator', font=font_code, fill=CORAL_DIM)
bezier(CX, Y3+70, CX, Y3+142, CORAL_DIM, 1, 0)

# === VERTICAL SPINE 3 ===
for y in range(Y3+70, Y3+250, 3):
    progress = (y - Y3 - 70) / 180
    alpha = int(20 + 20 * (1 - progress))
    draw.line([(CX-1, y), (CX+1, y)], fill=f'#{int(alpha*0.6):02x}{alpha:02x}{int(alpha*0.8):02x}', width=2)

# === LAYER 04: DATABASE ===
Y4 = 1600
draw.text((80, Y4-30), '04', font=font_num, fill=SAGE_DIM)
draw.text((80, Y4+25), 'PERSISTENCE', font=font_label_sm, fill=SAGE_DIM)

glow_circle(CX, Y4, 55, SAGE)
circle(CX, Y4, 55, fill='#0A1410', outline=SAGE, width=3)
tcenter(CX, Y4-12, 'PostgreSQL', font=font_node_bold, fill=SAGE)
tcenter(CX, Y4+12, 'SQLAlchemy ORM', font=font_code, fill=SAGE_DIM)

dashed_ring(CX, Y4, 220, SAGE_DIM, segs=80)

# Entity nodes in circular arrangement
entities = ['users', 'profiles', 'characters', 'scenarios',
            'conversations', 'messages', 'personas', 'avatars']
for i, name in enumerate(entities):
    angle = 2 * math.pi * i / len(entities) - math.pi/2
    ex = CX + 200 * math.cos(angle)
    ey = Y4 + 200 * math.sin(angle)
    circle(ex, ey, 26, fill=SLATE, outline=SAGE_DIM, width=1)
    tcenter(ex, ey, name, font=font_code, fill=SAGE)
    bezier(CX, Y4, ex, ey, '#102018', 1, 0.05)

# === LAYER 05: INFRASTRUCTURE ===
Y5 = 2050
draw.line([(80, Y5), (W-80, Y5)], fill=GHOST, width=1)
draw.text((80, Y5+15), '05', font=font_num, fill='#252A38')
draw.text((80, Y5+70), 'INFRA', font=font_label_sm, fill=GHOST)

# Server box
bx1, by1 = 250, Y5+40
bx2, by2 = W-250, Y5+170
draw.rounded_rectangle([bx1, by1, bx2, by2], radius=6, fill='#0C0F18', outline=GHOST, width=1)

tcenter(CX, Y5+70, 'Oracle Cloud', font=font_node, fill=DIM)
tcenter(CX, Y5+100, 'x86_64 · 1GB RAM · Oracle Linux 9.7 · systemd', font=font_code, fill=GHOST)
tcenter(CX, Y5+125, '158.180.83.142:8000', font=font_code, fill='#353A48')

# === STATS SIDEBAR ===
sx = W - 220
sy = 320
draw.text((sx, sy), 'CENSUS', font=font_label, fill=DIM)
draw.line([(sx, sy+28), (sx+140, sy+28)], fill=GHOST, width=1)
stats = [('2', 'Users'), ('60+', 'Characters'), ('13', 'Scenarios'),
         ('3', 'Personas'), ('12', 'Anime Series')]
for i, (v, k) in enumerate(stats):
    y = sy + 42 + i * 32
    draw.text((sx, y), v, font=font_label, fill=AMBER)
    draw.text((sx+48, y+3), k, font=font_code, fill=DIM)

# === LEGEND ===
ly = 2300
draw.text((80, ly), 'SIGNAL', font=font_label, fill=DIM)
draw.line([(80, ly+28), (220, ly+28)], fill=GHOST, width=1)
legends = [(AMBER, 'Interface'), (INDIGO, 'API'), (CORAL, 'Intelligence'),
           (SAGE, 'Persistence'), (DIM, 'Infrastructure')]
for i, (c, l) in enumerate(legends):
    y = ly + 42 + i * 28
    circle(95, y+5, 5, fill=c)
    draw.text((112, y-3), l, font=font_code, fill=DIM)

# === TECH STACK sidebar ===
tx = W - 220
ty = 2300
draw.text((tx, ty), 'STACK', font=font_label, fill=DIM)
draw.line([(tx, ty+28), (tx+140, ty+28)], fill=GHOST, width=1)
stack = ['Flutter · Dart', 'FastAPI · Python', 'Claude Sonnet/Haiku',
         'PostgreSQL', 'Oracle Cloud']
for i, s in enumerate(stack):
    draw.text((tx, ty+42+i*24), s, font=font_code, fill=DIM)

# === FOOTER ===
draw.line([(80, H-70), (W-80, H-70)], fill=GHOST, width=1)
draw.text((80, H-55), 'MUSE v2.0.0 — Neural Cartography', font=font_code, fill=DIM)
draw.text((W-240, H-55), 'NC-001 · 2026.03.22', font=font_code, fill=DIM)

# === SAVE ===
output = os.path.expanduser('~/Projects/active/muse/docs/muse-architecture.png')
img.save(output, 'PNG')
print(f'✓ Saved: {output} ({W}x{H})')
