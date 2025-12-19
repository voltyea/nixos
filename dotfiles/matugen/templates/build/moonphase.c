#include <stdio.h>
#include "astro_demo_common.h"

static const char *MoonPhaseName(double angle)
{
  if (angle < 22.5 ) return "󰽤 ";
  if (angle < 67.5) return "󰽧";
  if (angle < 112.5) return "󰽡";
  if (angle < 157.5) return "󰽨";
  if (angle < 202.5) return "󰽢 ";
  if (angle < 247.5) return "󰽦";
  if (angle < 292.5) return "󰽣";
  if (angle < 355.5) return "󰽥";
  return "󰽤 ";
}

int main(void)
{
  astro_time_t time;
  astro_angle_result_t phase;

  time = Astronomy_CurrentTime();

  phase = Astronomy_MoonPhase(time);
  if (phase.status != ASTRO_SUCCESS)
  {
    fprintf(stderr, "Astronomy_MoonPhase error %d\n", phase.status);
    return 1;
  }

  printf("%s\n", MoonPhaseName(phase.angle));

  return 0;
}
