#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <libevdev-1.0/libevdev/libevdev.h>
#include <libevdev-1.0/libevdev/libevdev-uinput.h>

#define BTN_FORWARD 0x115

void emit(struct libevdev_uinput *uidev, unsigned int type, unsigned int code, int val) {
    libevdev_uinput_write_event(uidev, type, code, val);
    libevdev_uinput_write_event(uidev, EV_SYN, SYN_REPORT, 0);
}

void tap_meta_tab(struct libevdev_uinput *uidev) {
    printf("Triggering Meta+Tab\n");
    emit(uidev, EV_KEY, KEY_LEFTMETA, 1);
    emit(uidev, EV_KEY, KEY_TAB, 1);
    usleep(50000); // 50ms
    emit(uidev, EV_KEY, KEY_TAB, 0);
    emit(uidev, EV_KEY, KEY_LEFTMETA, 0);
}

int is_mouse_with_forward(int fd) {
    struct libevdev *dev = NULL;
    int rc = libevdev_new_from_fd(fd, &dev);
    if (rc < 0) return 0;

    int has_btn = libevdev_has_event_code(dev, EV_KEY, BTN_FORWARD);
    libevdev_free(dev);
    return has_btn;
}

int main() {
    struct libevdev *devs[16];
    struct libevdev_uinput *uidev;
    int fds[16];
    int dev_count = 0;

    // 1. Setup Virtual Keyboard
    struct libevdev *uidev_raw = libevdev_new();
    libevdev_set_name(uidev_raw, "KDE Mouse Actions Virtual Keyboard (C)");
    libevdev_enable_event_type(uidev_raw, EV_KEY);
    libevdev_enable_event_code(uidev_raw, EV_KEY, KEY_LEFTMETA, NULL);
    libevdev_enable_event_code(uidev_raw, EV_KEY, KEY_TAB, NULL);

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
                if (is_mouse_with_forward(fd)) {
                    printf("Monitoring: %s\n", path);
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
        fprintf(stderr, "No mice with Forward button found.\n");
        return 1;
    }

    printf("Ready. Press Forward button to trigger Overview.\n");

    // 3. Main Loop
    while (1) {
        for (int i = 0; i < dev_count; i++) {
            struct input_event ev;
            while (libevdev_next_event(devs[i], LIBEVDEV_READ_FLAG_NORMAL, &ev) == LIBEVDEV_READ_STATUS_SUCCESS) {
                if (ev.type == EV_KEY && ev.code == BTN_FORWARD && ev.value == 1) {
                    tap_meta_tab(uidev);
                }
            }
        }
        usleep(10000); // 10ms sleep to avoid 100% CPU
    }

    return 0;
}
