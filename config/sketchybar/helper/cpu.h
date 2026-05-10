#include <stdio.h>
#include <unistd.h>
#include <mach/mach.h>
#include <stdbool.h>
#include <time.h>

static const char TOPPROC[32] = { "/bin/ps -Aceo pid,pcpu,comm -r" }; 
static const char FILTER_PATTERN[16] = { "com.apple." };

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;

  char command[256];
};

static inline void cpu_init(struct cpu* cpu) {
  cpu->host = mach_host_self();
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  cpu->has_prev_load = false;
  snprintf(cpu->command, 100, "");
}

static inline void cpu_update(struct cpu* cpu) {
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    printf("Error: Could not read cpu host statistics.\n");
    return;
  }

  if (cpu->has_prev_load) {
    uint32_t delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];

    uint32_t delta_system = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                            - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];

    uint32_t delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];

    double user_perc = (double)delta_user / (double)(delta_system
                                                     + delta_user
                                                     + delta_idle);

    double sys_perc = (double)delta_system / (double)(delta_system
                                                      + delta_user
                                                      + delta_idle);

    double total_perc = user_perc + sys_perc;

    FILE* file;
    char line[1024];

    file = popen(TOPPROC, "r");
    if (!file) {
      printf("Error: TOPPROC command errored out...\n" );
      return;
    }

    fgets(line, sizeof(line), file);
    fgets(line, sizeof(line), file);

    char* start = strstr(line, FILTER_PATTERN);
    char topproc[64];
    uint32_t caret = 0;
    for (int i = 0; i < sizeof(line); i++) {
      if (start && i == start - line) {
        i+=9;
        continue;
      }

      topproc[caret++] = line[i];
      if (line[i] == '\0') break;
    }

    pclose(file);

    char color[16];
    if (total_perc >= .7) {
      snprintf(color, 16, "0xffed8796");
    } else if (total_perc >= .3) {
      snprintf(color, 16, "0xfff5a97f");
    } else if (total_perc >= .1) {
      snprintf(color, 16, "0xffeed49f");
    } else {
      snprintf(color, 16, "0xffcad3f5");
    }

    snprintf(cpu->command, 256, "--push cpu.sys %.2f "
                                "--push cpu.user %.2f "
                                "--set cpu.percent label=%.0f%% label.color=%s "
                                "--set cpu.top label=\"%s\"",
                                sys_perc,
                                user_perc,
                                total_perc*100.,
                                color,
                                topproc                                         );
  }
  else {
    snprintf(cpu->command, 256, "");
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;
}
