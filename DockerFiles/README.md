# RTM NVIM DISTRO

Things to fix

- [] CLipboard not working

## Useful commands

```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/home/nvim/.Xauthority \
  nvim
```
