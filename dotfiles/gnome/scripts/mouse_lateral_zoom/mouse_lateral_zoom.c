#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <time.h>
#include <libevdev-1.0/libevdev/libevdev.h>
#include <libevdev-1.0/libevdev/libevdev-uinput.h>

long long current_time_ms() {
    struct timespec spec;
    clock_gettime(CLOCK_MONOTONIC, &spec);
    return (long long)(spec.tv_sec) * 1000 + (spec.tv_nsec / 1000000);
}

void emit(struct libevdev_uinput *uidev, unsigned int type, unsigned int code, int val) {
    libevdev_uinput_write_event(uidev, type, code, val);
    libevdev_uinput_write_event(uidev, EV_SYN, SYN_REPORT, 0);
}

void trigger_zoom(struct libevdev_uinput *uidev, int zoom_in) {
    printf("Zoom %s (Ctrl %c)\n", zoom_in ? "IN" : "OUT", zoom_in ? '+' : '-');
    emit(uidev, EV_KEY, KEY_LEFTCTRL, 1);
    emit(uidev, EV_KEY, zoom_in ? KEY_EQUAL : KEY_MINUS, 1);
    usleep(20000); // 20ms tap
    emit(uidev, EV_KEY, zoom_in ? KEY_EQUAL : KEY_MINUS, 0);
    emit(uidev, EV_KEY, KEY_LEFTCTRL, 0);
}

int has_lateral_wheel(int fd) {
    struct libevdev *dev = NULL;
    int rc = libevdev_new_from_fd(fd, &dev);
    if (rc < 0) return 0;

    int has_hwheel = libevdev_has_event_code(dev, EV_REL, REL_HWHEEL);
    int has_hwheel_hi = libevdev_has_event_code(dev, EV_REL, REL_HWHEEL_HI_RES);
    libevdev_free(dev);
    return (has_hwheel || has_hwheel_hi);
}

int main() {
    struct libevdev *devs[16];
    struct libevdev_uinput *uidev;
    int fds[16];
    int dev_count = 0;
    long long last_zoom_ts = 0;
    const int debounce_ms = 50;

    // 1. Setup Virtual Keyboard
    struct libevdev *uidev_raw = libevdev_new();
    libevdev_set_name(uidev_raw, "GNOME Mouse Zoom Virtual Keyboard");
    libevdev_enable_event_type(uidev_raw, EV_KEY);
    libevdev_enable_event_code(uidev_raw, EV_KEY, KEY_LEFTCTRL, NULL);
    libevdev_enable_event_code(uidev_raw, EV_KEY, KEY_EQUAL, NULL);
    libevdev_enable_event_code(uidev_raw, EV_KEY, KEY_MINUS, NULL);

    int rc = libevdev_uinput_create_from_device(uidev_raw, LIBEVDEV_UINPUT_OPEN_MANAGED, &uidev);
    if (rc < 0) {
        perror("Failed to create uinput device");
        return 1;
    }
    libevdev_free(uidev_raw);

    // 2. Find Mice
    DIR *dir = opendir("/dev/input");
    struct dirent *ent;
    while ((ent = readdir(dir)) != NULL && dev_count < 16) {
        if (strncmp(ent->d_name, "event", 5) == 0) {
            char path[256];
            snprintf(path, sizeof(path), "/dev/input/%s", ent->d_name);
            int fd = open(path, O_RDONLY | O_NONBLOCK);
            if (fd >= 0) {
                if (has_lateral_wheel(fd)) {
                    printf("Monitoring: %s (Lateral Wheel found)\n", path);
                    libevdev_new_from_fd(fd, &devs[dev_count]);
                    fds[dev_count] = fd;
                    dev_count++;
                } else {
                    close(fd);
                }
            }
        }
    }
    closedir(dir);

    if (dev_count == 0) {
        fprintf(stderr, "No mice with Lateral wheel found.\n");
        return 1;
    }

    printf("Ready. Monitoring %d devices for lateral wheel (Debounce: %dms).\n", dev_count, debounce_ms);

    // 3. Main Loop
    while (1) {
        for (int i = 0; i < dev_count; i++) {
            struct input_event ev;
            while (libevdev_next_event(devs[i], LIBEVDEV_READ_FLAG_NORMAL, &ev) == LIBEVDEV_READ_STATUS_SUCCESS) {
                if (ev.type == EV_REL) {
                    if (ev.code == REL_HWHEEL || ev.code == REL_HWHEEL_HI_RES) {
                        long long now = current_time_ms();
                        if (now - last_zoom_ts < debounce_ms) continue;
                        
                        if (ev.value < 0) { // Scroll Left -> Zoom In (Inverted as requested)
                            trigger_zoom(uidev, 1);
                            last_zoom_ts = now;
                        } else if (ev.value > 0) { // Scroll Right -> Zoom Out (Inverted as requested)
                            trigger_zoom(uidev, 0);
                            last_zoom_ts = now;
                        }
                    }
                }
            }
        }
        usleep(10000); // 10ms sleep
    }

    return 0;
}
