# Changelog

## 3.0.0 — 2026-09-19
* LXRCore v3 release line: every resource ships as 3.0.0 from here (the entries below are the road to it).

## 3.0.0 — 2026-09-18

Rebuilt on the LXRCore v3 native API (repository renamed from lxr-weathersync). Nothing of the earlier multi-framework build remains.

* Server calendar with seasons and daylight, persisted; sky from seasonal tables with follow-up rules, hold times and a forecast
* Global state for hour / minute / calendar / weather; clients mirror through state bag handlers; desert swap
* Almanac card on the LXR UI Kit; staff commands; locales EN / KA; offline tests
