#include <stdio.h>
#include <unistd.h>
#include "astro_demo_common.h"

int main(void)
{
  astro_time_t time;
  astro_angle_result_t phase;

  while (1)
  {
    /* Get current system time */
    time = Astronomy_CurrentTime();

    phase = Astronomy_MoonPhase(time);
    if (phase.status != ASTRO_SUCCESS)
    {
      fprintf(stderr, "Astronomy_MoonPhase error %d\n", phase.status);
      return 1;
    }

    printf("%.6f\n", phase.angle);
    fflush(stdout);

    /* Update once per hour */
    sleep(3600);
  }

  return 0;
}
