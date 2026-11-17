# ER diagramm hobused.db põhjal (SVG), Jegor Onoprijuk, TA-24B
import sqlite3, html
db = sqlite3.connect('hobused.db')
pos = {'tall':(40,40),'omanik':(40,330),'toug':(420,40),'hobune':(420,300),'treening':(800,40),'treener':(1150,40),
       'tulemus':(800,420),'voistlus':(1150,420),'vaktsineerimine':(420,640),'veterinaar':(800,640)}
pos = {k:(x,y+25) for k,(x,y) in pos.items()}
W = 230; RH = 22
tabs = {}
for t in pos:
    cols = db.execute(f'PRAGMA table_info({t})').fetchall()
    fks = {r[3]: (r[2], r[4]) for r in db.execute(f'PRAGMA foreign_key_list({t})')}
    tabs[t] = (cols, fks)
def box(t):
    x, y = pos[t]; h = 34 + RH * len(tabs[t][0]); return x, y, W, h
svg = ['<svg xmlns="http://www.w3.org/2000/svg" width="1450" height="900" font-family="Menlo,monospace" font-size="13">',
       '<rect width="100%" height="100%" fill="#fff"/>',
       '<rect width="100%" height="44" fill="#0b5cad"/><text x="20" y="29" fill="#fff" font-size="20" font-weight="bold" font-family="Helvetica">Jegor Onoprijuk · TA-24B · Hobuste andmebaas — ER diagramm (SQLite, 10 tabelit)</text>']
lines = []
for t, (cols, fks) in tabs.items():
    x, y, w, h = box(t)
    for c, (rt, rc) in fks.items():
        rx, ry, rw, rh = box(rt)
        ci = [c2[1] for c2 in cols].index(c)
        sy = y + 34 + RH * ci + RH / 2
        ri = [c2[1] for c2 in tabs[rt][0]].index(rc)
        ty = ry + 34 + RH * ri + RH / 2
        if rx + rw < x:   sx, tx = x, rx + rw
        elif x + w < rx:  sx, tx = x + w, rx
        else:             sx, tx = x + w / 2, rx + rw / 2; sy = y if ry < y else y + h; ty = ry + rh if ry < y else ry
        lines.append(f'<line x1="{sx}" y1="{sy}" x2="{tx}" y2="{ty}" stroke="#c0392b" stroke-width="2"/><circle cx="{sx}" cy="{sy}" r="4" fill="#c0392b"/><circle cx="{tx}" cy="{ty}" r="4" fill="#2c7a2c"/>')
svg += lines
for t, (cols, fks) in tabs.items():
    x, y, w, h = box(t)
    svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="#f5f9ff" stroke="#0b5cad" stroke-width="2" rx="6"/>')
    svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="30" fill="#0b5cad" rx="6"/><text x="{x+10}" y="{y+21}" fill="#fff" font-weight="bold" font-size="15">{t}</text>')
    for i, c in enumerate(cols):
        key = 'PK ' if c[5] else ('FK ' if c[1] in fks else '   ')
        col = '#b8860b' if c[5] else ('#c0392b' if c[1] in fks else '#222')
        svg.append(f'<text x="{x+10}" y="{y+34+RH*i+16}" fill="{col}">{key}{html.escape(c[1])} <tspan fill="#777">{c[2]}</tspan></text>')
svg.append('<text x="40" y="880" fill="#555">PK = primaarvõti, FK = võõrvõti (punane ots = viitaja, roheline ots = viidatav tabel)</text></svg>')
open('er_diagramm.svg', 'w').write('\n'.join(svg))
