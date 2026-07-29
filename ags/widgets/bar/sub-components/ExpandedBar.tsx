import { Gtk } from "ags/gtk4";
import Workspaces from "../components/Workspaces";
import Information from "../components/Information";
import Utilities from "../components/Utilities";

export default () =>
  (
    <box orientation={Gtk.Orientation.HORIZONTAL} hexpand spacing={2}>
      <box spacing={2} hexpand={false}>
        <box class="section9-identity">
          <label label="S9" />
        </box>
        <Workspaces />
      </box>

      <box
        hexpand
        halign={Gtk.Align.FILL}
      >
        <box
          hexpand
          halign={Gtk.Align.CENTER}
        >
          <Information />
        </box>
      </box>

      <box
        hexpand={false}
        halign={Gtk.Align.END}
        marginEnd={8}
      >
        <Utilities />
      </box>
    </box>
  ) as Gtk.Widget;
