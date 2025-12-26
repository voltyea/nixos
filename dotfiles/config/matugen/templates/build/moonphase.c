#include <stdio.h>
#include "astro_demo_common.h"

static const char *MoonPhaseName(double angle)
{
  static const char *phases[] = {
    "󰽤 ", "󰽧", "󰽡", "󰽨",
    "󰽢 ", "󰽦", "󰽣", "󰽥"
  };
  return phases[(int)(angle/45)];
}
int main(void)
{
  printf("%s\n", MoonPhaseName(Astronomy_MoonPhase(Astronomy_CurrentTime()).angle));
  return 0;
}
