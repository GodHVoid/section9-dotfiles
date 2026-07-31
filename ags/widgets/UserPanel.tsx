import { execAsync } from "ags/process";

import App from "ags/gtk4/app";
import { Astal, Gdk, Gtk } from "ags/gtk4";
import Hyprland from "gi://AstalHyprland";

import { hideWindow } from "../utils/window";
import { getMonitorName } from "../utils/monitor";

const hyprland = Hyprland.get_default();

const UserPanel = () => {
  const Logout = () => (
    <button
      hexpand={false}
      vexpand={false}
      class="logout system-action"
      label="󰍃"
      tooltipText="Logout from Hyprland"
      heightRequest={220}
      widthRequest={220}
      onClicked={() => {
        hyprland.dispatch("hl.dsp.exit()", "");
      }}
    />
  );

  const Shutdown = () => (
    <button
      hexpand={false}
      vexpand={false}
      class="shutdown system-action"
      label=""
      tooltipText="Shutdown immediately"
      heightRequest={220}
      widthRequest={220}
      onClicked={() => {
        execAsync("shutdown now");
      }}
    />
  );

  const Reboot = () => (
    <button
      hexpand={false}
      vexpand={false}
      class="reboot system-action"
      label="󰜉"
      tooltipText="Reboot immediately"
      heightRequest={220}
      widthRequest={220}
      onClicked={() => {
        execAsync("reboot");
      }}
    />
  );

  const Sleep = () => (
    <button
      hexpand={false}
      vexpand={false}
      class="sleep system-action"
      label="󰤄"
      tooltipText="Put system to sleep"
      heightRequest={220}
      widthRequest={220}
      onClicked={(self) => {
        const root = self.get_root() as Gtk.Window & {
          monitorName?: string;
        };

        if (root.monitorName) {
          hideWindow(`user-panel-${root.monitorName}`);
        }

        execAsync(
          `bash -c "$HOME/.config/hypr/scripts/hyprlock.sh suspend"`,
        );
      }}
    />
  );

  return (
    <box
      class="display"
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
      hexpand
      vexpand
      $={(container) => {
        const grid = new Gtk.Grid({
          halign: Gtk.Align.CENTER,
          valign: Gtk.Align.CENTER,
          rowSpacing: 6,
          columnSpacing: 6,
          rowHomogeneous: true,
          columnHomogeneous: true,
        });

        grid.add_css_class("user-grid");

        grid.attach(Logout() as Gtk.Widget, 0, 0, 1, 1);
        grid.attach(Shutdown() as Gtk.Widget, 1, 0, 1, 1);
        grid.attach(Sleep() as Gtk.Widget, 0, 1, 1, 1);
        grid.attach(Reboot() as Gtk.Widget, 1, 1, 1, 1);

        container.append(grid);
      }}
    />
  );
};

export default ({
  monitor,
  setup,
}: {
  monitor: Gdk.Monitor;
  setup: (self: Gtk.Window) => void;
}) => {
  const monitorName = getMonitorName(monitor)!;

  return (
    <window
      gdkmonitor={monitor}
      name={`user-panel-${monitorName}`}
      namespace="user-panel"
      application={App}
      class="user-panel"
      layer={Astal.Layer.OVERLAY}
      visible={false}
      keymode={Astal.Keymode.ON_DEMAND}
      exclusivity={Astal.Exclusivity.IGNORE}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.RIGHT |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.BOTTOM
      }
      $={(self) => {
        setup(self);

        (self as Gtk.Window & { monitorName?: string }).monitorName =
          monitorName;

        const keyController = new Gtk.EventControllerKey();

        keyController.connect("key-pressed", (_controller, keyval) => {
          if (keyval === Gdk.KEY_Escape) {
            self.hide();
            return true;
          }

          return false;
        });

        self.add_controller(keyController);
      }}
    >
      <box
        class="display"
        orientation={Gtk.Orientation.VERTICAL}
        spacing={10}
      >
        <UserPanel />
      </box>
    </window>
  );
};
