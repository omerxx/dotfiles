#include "cpu.h"
#include "clock.h"
#include "sketchybar.h"

struct cpu g_cpu;
struct clock g_clock;

void handler(env env) {
  // Environment variables passed from sketchybar can be accessed as seen below
  char* name = env_get_value_for_key(env, "NAME");
  char* sender = env_get_value_for_key(env, "SENDER");
  char* info = env_get_value_for_key(env, "INFO");
  char* selected = env_get_value_for_key(env, "SELECTED");

  if (selected && strlen(selected) > 0) {
    // Space items
    char* width;
    if (strcmp(selected, "true") == 0) {
      width = "0";
    } else {
      width = "dynamic";
    }
    char command[256];
    snprintf(command, 256, "--animate tanh 20 --set %s icon.highlight=%s label.width=%s", name, selected, width);
    sketchybar(command);
  } 
  else if (strcmp(sender, "front_app_switched") == 0) {
    // front_app item
    char command[256];
    
    snprintf(command, 256, "--set %s label=\"%s\"", name, info);
    sketchybar(command);
  }
  else if ((strcmp(sender, "routine") == 0)
            || (strcmp(sender, "forced") == 0)) {
    // CPU and Clock routine updates
    cpu_update(&g_cpu);
    clock_update(&g_clock);

    if (strlen(g_cpu.command) > 0 && strlen(g_clock.command) > 0) {
      char command[512];
      snprintf(command, 512, "%s %s", g_cpu.command, g_clock.command);
      sketchybar(command);
    }
  }
}

int main (int argc, char** argv) {
  cpu_init(&g_cpu);
  clock_init(&g_clock);

  if (argc < 2) {
    printf("Usage: provider \"<bootstrap name>\"\n");
    exit(1);
  }

  event_server_begin(handler, argv[1]);
  return 0;
}
