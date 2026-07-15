import { useMemo } from "react";
import type { RideSample } from "../ride/types";

interface PowerChartProps {
  samples: RideSample[];
  targetWatts?: number;
  windowSec?: number;
}

const WIDTH = 640;
const HEIGHT = 180;
const PADDING = { top: 12, right: 12, bottom: 20, left: 36 };

/** A rolling line chart of actual vs. target power for the current ride. */
export function PowerChart({ samples, targetWatts, windowSec = 180 }: PowerChartProps) {
  const windowed = useMemo(() => {
    if (samples.length === 0) return samples;
    const latestT = samples[samples.length - 1].tSec;
    return samples.filter((s) => s.tSec >= latestT - windowSec);
  }, [samples, windowSec]);

  const maxWatts = useMemo(() => {
    const powers = windowed.map((s) => s.powerWatts ?? 0);
    const peak = Math.max(targetWatts ?? 0, ...powers, 50);
    return Math.ceil((peak * 1.15) / 25) * 25;
  }, [windowed, targetWatts]);

  const plotWidth = WIDTH - PADDING.left - PADDING.right;
  const plotHeight = HEIGHT - PADDING.top - PADDING.bottom;

  const tMin = windowed.length > 0 ? windowed[0].tSec : 0;
  const tMax = windowed.length > 0 ? windowed[windowed.length - 1].tSec : windowSec;
  const tSpan = Math.max(1, tMax - tMin);

  const x = (t: number) => PADDING.left + ((t - tMin) / tSpan) * plotWidth;
  const y = (watts: number) => PADDING.top + plotHeight - (watts / maxWatts) * plotHeight;

  const powerPath = windowed
    .filter((s) => s.powerWatts !== undefined)
    .map((s, i) => `${i === 0 ? "M" : "L"} ${x(s.tSec).toFixed(1)} ${y(s.powerWatts!).toFixed(1)}`)
    .join(" ");

  const gridLines = [0.25, 0.5, 0.75, 1].map((f) => Math.round((maxWatts * f) / 25) * 25);

  return (
    <div className="power-chart">
      <svg viewBox={`0 0 ${WIDTH} ${HEIGHT}`} width="100%" height={HEIGHT} role="img" aria-label="Power over time chart">
        {gridLines.map((watts) => (
          <g key={watts}>
            <line x1={PADDING.left} x2={WIDTH - PADDING.right} y1={y(watts)} y2={y(watts)} className="chart-grid" />
            <text x={PADDING.left - 6} y={y(watts)} textAnchor="end" dominantBaseline="middle" className="chart-axis-label">
              {watts}
            </text>
          </g>
        ))}

        {targetWatts !== undefined && (
          <line
            x1={PADDING.left}
            x2={WIDTH - PADDING.right}
            y1={y(targetWatts)}
            y2={y(targetWatts)}
            className="chart-target-line"
          />
        )}

        {powerPath && <path d={powerPath} className="chart-power-line" />}
      </svg>
      <div className="chart-legend">
        <span className="chart-legend-item">
          <span className="chart-swatch chart-swatch-power" /> Power
        </span>
        <span className="chart-legend-item">
          <span className="chart-swatch chart-swatch-target" /> Target
        </span>
      </div>
    </div>
  );
}
