# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Adventure Wear** — a personal data log tracking what clothing to wear for outdoor activities under varying weather conditions. No build system or code; the repository contains CSV data files only.

## Data Files

| File | Activity | Columns |
|------|----------|---------|
| `Adventure_Wear - Running.csv` | Running | Temperature (degrees/feels like), time, conditions, wind, and clothing items worn (t-shirt, mitts, headband, hat, long-sleeved shirt, jacket, running pants, yoga pants) |
| `Adventure_Wear - Golf.csv` | Golf | Date, tee time, low/high temp, conditions, humidity, wind, and clothing worn by category (outerwear, top long/short, bottoms, feet, head, hands) plus an outcome/notes column and course name |

## Conventions

- Running CSV uses `x` to mark which items were worn; missing `Feels like` means only the raw temperature was recorded.
- Golf CSV includes free-text `Outcome` notes with retrospective advice (e.g., "Next time, heavy socks") — these are the most actionable rows for future outfit decisions.
- Dates in the Golf CSV are MM/DD/YY; a few rows have typos (e.g., `2/24222`).
