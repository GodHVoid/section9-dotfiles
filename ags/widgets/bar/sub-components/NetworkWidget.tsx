import { Accessor, createComputed, createState } from "ags";
import AstalNetwork from "gi://AstalNetwork";
import GLib from "gi://GLib";
import { Gtk } from "ags/gtk4";
import { activateState } from "../Bar";

const network = AstalNetwork.get_default();

type NetworkType = "wifi" | "ethernet" | "vpn" | "unknown";

type NetworkActivity = {
  connected: boolean;
  name: string;
  type: NetworkType;
};

export const [networkActivity, setNetworkActivity] =
  createState<NetworkActivity>({
    connected: false,
    name: "Initializing",
    type: "unknown",
  });

let startupComplete = false;
let updateTimer = 0;

let previousActivity: NetworkActivity = {
  connected: false,
  name: "Initializing",
  type: "unknown",
};

function getCurrentActivity(): NetworkActivity {
  const wifi = network.wifi;
  const wired = network.wired;

  /*
   * Prefer Wi-Fi whenever it has a valid connected SSID.
   * This prevents temporary wired/bridge state from replacing
   * an already established wireless connection.
   */
  if (
    wifi?.ssid &&
    wifi.internet === AstalNetwork.Internet.CONNECTED
  ) {
    return {
      connected: true,
      name: wifi.ssid,
      type: "wifi",
    };
  }

  if (
    wired &&
    wired.internet === AstalNetwork.Internet.CONNECTED
  ) {
    return {
      connected: true,
      name: "Ethernet",
      type: "ethernet",
    };
  }

  if (wifi) {
    return {
      connected: false,
      name: "Disconnected",
      type: "wifi",
    };
  }

  return {
    connected: false,
    name: "Disconnected",
    type: "unknown",
  };
}

function activityChanged(
  current: NetworkActivity,
  previous: NetworkActivity,
): boolean {
  return (
    current.connected !== previous.connected ||
    current.name !== previous.name ||
    current.type !== previous.type
  );
}

function applyNetworkState(allowPulse = true) {
  const currentActivity = getCurrentActivity();
  const changed = activityChanged(currentActivity, previousActivity);

  setNetworkActivity(currentActivity);

  /*
   * Do not show a network activity pulse while AstalNetwork and
   * NetworkManager are still discovering interfaces at login.
   */
  if (startupComplete && allowPulse && changed) {
    activateState("network", 3000);
  }

  previousActivity = currentActivity;
}

function scheduleNetworkUpdate() {
  /*
   * Debounce rapid interface events. At login, wired, Wi-Fi, and
   * primary-adapter properties may all update within milliseconds.
   */
  if (updateTimer !== 0) {
    GLib.source_remove(updateTimer);
  }

  updateTimer = GLib.timeout_add(
    GLib.PRIORITY_DEFAULT,
    500,
    () => {
      updateTimer = 0;
      applyNetworkState(true);
      return GLib.SOURCE_REMOVE;
    },
  );
}

/*
 * Give NetworkManager time to establish the real primary connection
 * before displaying the initial state.
 */
GLib.timeout_add(
  GLib.PRIORITY_DEFAULT,
  1500,
  () => {
    applyNetworkState(false);
    startupComplete = true;
    return GLib.SOURCE_REMOVE;
  },
);

if (network.wifi) {
  network.wifi.connect("notify::ssid", scheduleNetworkUpdate);
  network.wifi.connect("notify::internet", scheduleNetworkUpdate);
}

if (network.wired) {
  network.wired.connect("notify::internet", scheduleNetworkUpdate);
}

network.connect("notify::primary", scheduleNetworkUpdate);

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

            if (activity.name === "Initializing") {
              return "Network Initializing";
            }

            if (activity.connected) {
              return activity.type === "wifi"
                ? "Connected to Wi-Fi"
                : "Ethernet Connected";
            }

            return activity.type === "wifi"
              ? "Wi-Fi Disconnected"
              : "Network Disconnected";
          })}
        />

        <label
          xalign={0}
          class="subtitle"
          visible={createComputed(
            () =>
              networkActivity().connected &&
              networkActivity().type === "wifi",
          )}
          label={createComputed(() => networkActivity().name)}
        />
      </box>
    </box>
  ) as Gtk.Widget;
};
