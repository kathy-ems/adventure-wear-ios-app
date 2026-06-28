#!/usr/bin/env python3
"""
Converts Adventure_Wear Running and Golf CSVs into the unified Entries format
for import into Google Sheets.

Usage:
    cd /path/to/adventure_wear
    python3 migration/migrate.py

Output:
    migration/entries.csv  — import this into the 'Entries' tab in Google Sheets
"""

import csv
import re
from pathlib import Path

BASE = Path(__file__).parent.parent

COLUMNS = [
    'timestamp', 'activity', 'temp', 'feelsLike', 'conditions', 'wind', 'humidity',
    'timeOfDay', 'teeTime', 'lowTemp', 'highTemp', 'wetGround',
    'outerwear', 'topLong', 'topShort', 'bottoms', 'head', 'hands', 'feet',
    'notes'
]


def checked(*values):
    """Join non-empty 'x' items into a comma-separated string of their names."""
    return ', '.join(label for label, val in values if str(val).strip().lower() == 'x')


def strip_mph(value):
    """'13 mph' → '13', '6mph' → '6'"""
    m = re.match(r'(\d+(?:\.\d+)?)', str(value).strip())
    return m.group(1) if m else ''


def map_running(row):
    head = checked(('headband', row.get('headband', '')), ('hat', row.get('hat', '')))
    bottoms = checked(
        ('running pants', row.get('Running pants', '')),
        ('yoga pants',    row.get('yoga (warm) pants', ''))
    )
    return {
        'timestamp':  '',
        'activity':   'Running',
        'temp':       row.get('degrees', ''),
        'feelsLike':  row.get('Feels like', ''),
        'conditions': row.get('cloudy/sunny/rain', ''),
        'wind':       row.get('Wind', ''),
        'humidity':   '',
        'timeOfDay':  row.get('time', ''),
        'lowTemp': '', 'highTemp': '', 'wetGround': '',
        'outerwear':  'jacket'           if str(row.get('jacket', '')).strip().lower() == 'x' else '',
        'topLong':    'long sleeved shirt' if str(row.get('long sleeved shirt', '')).strip().lower() == 'x' else '',
        'topShort':   't-shirt'          if str(row.get('t-shirt', '')).strip().lower() == 'x' else '',
        'bottoms':    bottoms,
        'head':       head,
        'hands':      'mitts'            if str(row.get('mits', '')).strip().lower() == 'x' else '',
        'feet':       '',
        'notes':      '',
    }


def map_golf(row):
    # The dewy-ground column has a very long header; find it by partial match
    wet_key = next((k for k in row if 'dewy' in k.lower() or 'raining' in k.lower()), '')
    wet_val = str(row.get(wet_key, '')).strip().lower()
    wet_ground = 'Yes' if wet_val == 'yes' else ('No' if wet_val == 'no' else '')

    return {
        'timestamp':  '',
        'activity':   'Golf',
        'temp':       row.get('Low temp', ''),  # low temp = tee-time temp for lookup
        'feelsLike':  '',
        'conditions': row.get('Conditions', ''),
        'wind':       strip_mph(row.get('Wind max (mph)', '')),
        'humidity':   row.get('Humidity (%)', ''),
        'timeOfDay':  row.get('TeeTime', ''),
        'lowTemp':    row.get('Low temp', ''),
        'highTemp':   row.get('High temp', ''),
        'wetGround':  wet_ground,
        'outerwear':  row.get('Outerwear', ''),
        'topLong':    row.get('Top_long', ''),
        'topShort':   row.get('Top_short', ''),
        'bottoms':    row.get('bottoms', ''),
        'head':       row.get('Head', ''),
        'hands':      row.get('Hands', ''),
        'feet':       row.get('Feet', ''),
        'notes':      row.get('Outcome', ''),
    }


def read_csv(path):
    with open(path, encoding='utf-8-sig') as f:
        return list(csv.DictReader(f))


def main():
    running_rows = read_csv(BASE / 'Adventure_Wear - Running.csv')
    golf_rows    = read_csv(BASE / 'Adventure_Wear - Golf.csv')

    out_path = BASE / 'migration' / 'entries.csv'
    with open(out_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=COLUMNS)
        writer.writeheader()
        for row in running_rows:
            writer.writerow(map_running(row))
        for row in golf_rows:
            writer.writerow(map_golf(row))

    total = len(running_rows) + len(golf_rows)
    print(f"Written {total} rows ({len(running_rows)} running, {len(golf_rows)} golf) → {out_path}")
    print("Next: import migration/entries.csv into the 'Entries' tab of your Google Sheet.")


if __name__ == '__main__':
    main()
