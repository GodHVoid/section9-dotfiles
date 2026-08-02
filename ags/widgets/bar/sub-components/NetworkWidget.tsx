import { Accessor, createComputed, createState } from "ags";
import AstalNetwork from "gi://AstalNetwork";
import { activateState } from "../Bar";
import { Gtk } from "ags/gtk4";

const network = AstalNetwork.get_default();

export const [networkActivity, setNetworkActivity] = createState({
  connected: false,
  name: "",
  type: "wifi" as "wifi" | "ethernet" | "vpn" | "unknown",
});

function updateActivity(triggerPulse = false) {
  const wifi = network.wifi;
  const wired = network.wired;

  let connected = false;
  let name = "Disconnected";
  let type: "wifi" | "ethernet" | "vpn" | "unknown" = "unknown";

  // Prefer an active Wi-Fi connection over wired/bridge interfaces.
  if (
    wifi &&
    wifi.ssid &&
    wifi.internet === AstalNetwork.Internet.CONNECTED
  ) {
    connected = true;
    name = wifi.ssid;
    type = "wifi";
  } else if (
    wired &&
    wired.internet === AstalNetwork.Internet.CONNECTED
  ) {
    connected = true;
    name = "Ethernet";
    type = "ethernet";
  } else if (wifi) {
    connected = false;
    name = "Disconnected";
    type = "wifi";
  }
  // Push state updates to reactive variables
  setNetworkActivity({ connected, name, type });

  // Pulse the Bar's state engine if changes happen actively post-boot
  if (triggerPulse) {
    activateState("network", 3000);
  }
}

// Track immediately on startup so widgets aren't blank on launch
updateActivity(false);

// Safe GObject Property Change Listeners
if (network.wifi) {
  // Listen to both SSID changes and state/internet level changes
  network.wifi.connect("notify::ssid", () => updateActivity(true));
  network.wifi.connect("notify::internet", () => updateActivity(true));
}

if (network.wired) {
  network.wired.connect("notify::internet", () => updateActivity(true));
}

// Watch for primary adapter target swaps
network.connect("notify::primary", () => updateActivity(true));

export default ({ widthRequest }: { widthRequest?: Accessor<number> }) => {
  return (
    <box
      class="network-widget"
      spacing={12}
      widthRequest={widthRequest}
      valign={Gtk.Align.CENTER}
    >
      <image
        pixelSize={26}
        iconName={createComputed(() => {
          const activity = networkActivity();
          if (activity.type === "ethernet") {
            return activity.connected
              ? "network-wired-symbolic"
              : "network-wired-disconnected-symbolic";
          }
          return activity.connected
            ? "network-wireless-signal-excellent-symbolic"
            : "network-wireless-offline-symbolic";
        })}
      />

      <box valign={Gtk.Align.CENTER} spacing={5}>
        <label
          xalign={0}
          class="title"
          label={createComputed(() => {
            const activity = networkActivity();
            if (activity.connected) {
              return activity.type === "wifi"
                ? "Connected to Wi-Fi"
                : "Ethernet Connected";
            }
            return activity.type === "wifi"
              ? "Wi-Fi Disconnected"
              : "Ethernet Disconnected";
          })}
        />
        <label
          xalign={0}
          class="subtitle"
          visible={createComputed(
            () =>
              networkActivity().connected && networkActivity().type === "wifi",
          )}
          label={createComputed(() => networkActivity().name)}
        />
      </box>
    </box>
  ) as Gtk.Widget;
};
