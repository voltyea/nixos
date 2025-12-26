#include <stdio.h>
#include <unistd.h>
#include "astro_demo_common.h"

int main(void)
{
  while (1)
  {
    printf("%f\n", Astronomy_MoonPhase(Astronomy_CurrentTime()).angle);
    fflush(stdout);
    sleep(3600);
  }
  return 0;
}
