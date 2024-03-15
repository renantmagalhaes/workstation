import keyboard

class LWRemapper():
  def __init__(self) -> None:
    self.last_press_e = None
    keyboard.on_press(self.handle_press)
    keyboard.on_release_key('left windows', self.handle_lw_release, True)
    keyboard.wait()

  def handle_press(self, e: keyboard.KeyboardEvent) -> None:
    self.last_press_e = e

  def handle_lw_release(self, e: keyboard.KeyboardEvent) -> None:
    if self.last_press_e.name == 'left windows':
      keyboard.send('f12')
    keyboard.release('left windows')

LWRemapper()