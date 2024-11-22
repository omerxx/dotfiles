#include <stdio.h>
#include <time.h>

struct clock {
  char command[128];
};

static inline void clock_init(struct clock* clock) {
  snprintf(clock->command, 128, "");
}

static inline void clock_update(struct clock* clock) {
  time_t t = time(NULL);
  struct tm* tm = localtime(&t);

  char time[8];
  strftime(time, 8, "%H:%M", tm);

  char date[16];
  strftime(date, 16, "%a %d. %b", tm);

  snprintf(clock->command, 128, "--set calendar icon=\"%s\" label=\"%s\"", date, time);
}
