import {
  Accessor,
  createBinding,
  createComputed,
  createState,
} from "ags";
import { Astal } from "ags/gtk4";
import { Gdk } from "ags/gtk4";
import { Gtk } from "ags/gtk4";
import { interval, timeout, Timer } from "ags/time";

import AstalMpris from "gi://AstalMpris";
import Wp from "gi://AstalWp";

import {
  fullscreenClient,
} from "../../variables";
import { getMonitorName } from "../../utils/monitor";
import { Window } from "../../utils/window";
import Brightness from "../../services/brightness";
import { isRecording } from "../../services/record.service";

import Volume from "./components/sub-components/Volume";
import BrightnessWidget from "./components/sub-components/BrightnessWidget";
import Recording from "./components/sub-components/Recording";
import PlayerWidget from "./components/sub-components/PlayerWidget";

import NetworkWidget from "./sub-components/NetworkWidget";
import CompactBar from "./sub-components/CompactBar";
import ExpandedBar from "./sub-components/ExpandedBar";
import SearchBar from "./sub-components/SearchBar";

const mpris = AstalMpris.get_default();

export type BarStateName =
  | "compact"
  | "expanded"
  | "recording"
  | "volume"
  | "brightness"
  | "search"
  | "player"
  | "network";

export const [barState, setBarState] =
  createState<BarStateName>("compact");

export const [stackVisibleChild, setStackVisibleChild] =
  createState<BarStateName>("compact");

const PRIORITY: Record<BarStateName, number> = {
  compact: 0,
  recording: 40,
  expanded: 60,
  volume: 80,
  brightness: 80,
  network: 80,
  player: 80,
  search: 100,
};

type StateEntry = {
  priority: number;
  timer?: Timer;
};

const activeStates = new Map<BarStateName, StateEntry>();

// Compact is the permanent base state.
activeStates.set("compact", {
  priority: PRIORITY.compact,
});

function resolveVisibleState(): BarStateName {
  let best: BarStateName = "compact";
  let bestPriority = -Infinity;

  for (const [name, entry] of activeStates) {
    if (entry.priority > bestPriority) {
      best = name;
      bestPriority = entry.priority;
    }
  }

  return best;
}

export function activateState(
  name: BarStateName,
  holdMs?: number,
) {
  const priority = PRIORITY[name];
  const existing = activeStates.get(name);

  existing?.timer?.cancel();

  const entry: StateEntry = {
    priority,
  };

  if (holdMs !== undefined) {
    entry.timer = timeout(holdMs, () => {
      deactivateState(name);
    });
  }

  activeStates.set(name, entry);

  timeout(100, () => {
    setBarState(resolveVisibleState());
  });
}

export function deactivateState(name: BarStateName) {
  // Compact cannot be removed because it is the base state.
  if (name === "compact") {
    return;
  }

  activeStates.get(name)?.timer?.cancel();
  activeStates.delete(name);

  timeout(100, () => {
    setBarState(resolveVisibleState());
  });
}

// ---------------------------------------------------------------------
// MPRIS player state
// ---------------------------------------------------------------------

export const [activePlayer, setActivePlayer] =
  createState<AstalMpris.Player | null>(null);

const PLAYER_HOLD_MS = 2500;
const watchedPlayers = new Set<AstalMpris.Player>();
const playersBinding = createBinding(mpris, "players");

function watchPlayerTransient(player: AstalMpris.Player) {
  let lastTitle = player.title;
  let debounceTimer: Timer | null = null;

  const pulse = () => {
    setActivePlayer(player);

    debounceTimer?.cancel();

    debounceTimer = timeout(50, () => {
      debounceTimer = null;
      activateState("player", PLAYER_HOLD_MS);
    });
  };

  player.connect("notify::title", () => {
    if (player.title === lastTitle) {
      return;
    }

    lastTitle = player.title;
    pulse();
  });
}

function syncWatchedPlayers() {
  const current = new Set(playersBinding.get());

  for (const player of current) {
    if (!watchedPlayers.has(player)) {
      watchedPlayers.add(player);
      watchPlayerTransient(player);
    }
  }

  for (const player of watchedPlayers) {
    if (!current.has(player)) {
      watchedPlayers.delete(player);

      if (activePlayer.peek() === player) {
        setActivePlayer(null);
        deactivateState("player");
      }
    }
  }
}

playersBinding.subscribe(syncWatchedPlayers);
syncWatchedPlayers();

// ---------------------------------------------------------------------
// Bar window
// ---------------------------------------------------------------------

export default ({
  monitor,
  setup,
}: {
  monitor: Gdk.Monitor;
  setup: (self: Gtk.Window) => void;
}) => {
  const monitorName = getMonitorName(monitor)!;
  const [currentWidth, setCurrentWidth] = createState(0);

  let widthVelocity = 0;
  let springTimer: Timer | null = null;

  function animateWidth(
    target: number,
    stiffness = 250,
    damping = 15,
    mass = 1,
  ) {
    if (springTimer !== null) {
      springTimer.cancel();
      springTimer = null;
    }

    const dt = 16 / 1000;

    springTimer = interval(16, () => {
      const current = currentWidth();
      const displacement = current - target;

      const springForce = -stiffness * displacement;
      const dampingForce = -damping * widthVelocity;
      const acceleration =
        (springForce + dampingForce) / mass;

      widthVelocity += acceleration * dt;

      const next = current + widthVelocity * dt;

      setCurrentWidth(next);

      if (
        Math.abs(next - target) < 0.5 &&
        Math.abs(widthVelocity) < 0.5
      ) {
        setCurrentWidth(target);
        widthVelocity = 0;

        springTimer?.cancel();
        springTimer = null;
      }
    });
  }

  const barWidgets =
    {} as Record<BarStateName, Gtk.Widget>;

  const barWidths =
    {} as Record<BarStateName, number>;

  barState.subscribe(() => {
    const name = barState.get();
    const target = barWidths[name];

    if (target === undefined) {
      return;
    }

    const current = currentWidth.peek();
    const growing = target > current;

    if (growing) {
      animateWidth(target);

      timeout(100, () => {
        setStackVisibleChild(name);
      });
    } else {
      setStackVisibleChild(name);

      timeout(100, () => {
        animateWidth(target);
      });
    }
  });

  function registerBarWidget({
    name,
    widget,
    padding = 250,
  }: {
    name: BarStateName;
    widget: Gtk.Widget;
    padding?: number;
  }) {
    barWidgets[name] = widget;

    const [, natural] = widget.measure(
      Gtk.Orientation.HORIZONTAL,
      -1,
    );

    barWidths[name] = natural + padding;

    return widget;
  }

  function watchTransient<T>(
    connectTo: {
      connect: (
        signal: string,
        callback: () => void,
      ) => void;
    },
    signal: string,
    getValue: () => T,
    stateName: BarStateName,
    holdMs = 2000,
  ) {
    let isFirst = true;
    let last: T;

    connectTo.connect(signal, () => {
      const current = getValue();

      if (isFirst) {
        isFirst = false;
        last = current;
        return;
      }

      if (current === last) {
        return;
      }

      last = current;
      activateState(stateName, holdMs);
    });
  }

  const barStack = (
    <stack
      transitionType={Gtk.StackTransitionType.CROSSFADE}
      transitionDuration={250}
      hhomogeneous={false}
      $={(self) => {
        const addDebugPage = (
          name: BarStateName,
          factory: () => Gtk.Widget,
          padding = 250,
        ) => {
          console.log(`[Bar] START: ${name}`);

          const widget = factory();

          console.log(`[Bar] CREATED: ${name}`);
          console.log(`[Bar] PARENT BEFORE REGISTER: ${name}`, widget.get_parent());

          const registeredWidget = registerBarWidget({
            name,
            widget,
            padding,
          });

          console.log(`[Bar] REGISTERED: ${name}`);
          console.log(
            `[Bar] PARENT BEFORE ADD: ${name}`,
            registeredWidget.get_parent(),
          );

          self.add_named(registeredWidget, name);

          console.log(`[Bar] ADDED: ${name}`);
          console.log(
            `[Bar] PARENT AFTER ADD: ${name}`,
            registeredWidget.get_parent(),
          );
        };

        addDebugPage(
          "compact",
          () => CompactBar(),
          400,
        );

        addDebugPage(
          "expanded",
          () => ExpandedBar(),
          500,
        );

        addDebugPage(
          "volume",
          () =>
            Volume({
              widthRequest: currentWidth,
            }),
        );

        addDebugPage(
          "brightness",
          () =>
            BrightnessWidget({
              widthRequest: currentWidth,
            }),
        );

        addDebugPage(
          "recording",
          () =>
            Recording({
              widthRequest: currentWidth,
            }),
        );

        addDebugPage(
          "player",
          () =>
            PlayerWidget({
              widthRequest: currentWidth,
            }),
          350,
        );

        addDebugPage(
          "search",
          () =>
            SearchBar({
              widthRequest: currentWidth,
            }),
          500,
        );

        addDebugPage(
          "network",
          () =>
            NetworkWidget({
              widthRequest: currentWidth,
            }),
          300,
        );

        setCurrentWidth(barWidths.compact);

        const syncVisibleChild = () => {
          const name = stackVisibleChild.peek();
          const child = self.get_child_by_name(name);

          if (child) {
            self.set_visible_child(child);
          }
        };

        // All named stack children exist at this point.
        syncVisibleChild();

        const unsubscribeVisibleChild =
          stackVisibleChild.subscribe(syncVisibleChild);

        self.connect("destroy", () => {
          unsubscribeVisibleChild?.();
        });

        const speaker =
          Wp.get_default()?.audio.defaultSpeaker;

        if (speaker) {
          watchTransient(
            speaker,
            "notify::volume",
            () => speaker.volume,
            "volume",
          );
        }

        const brightness = Brightness.get_default();

        watchTransient(
          brightness,
          "notify::screen",
          () => brightness.screen,
          "brightness",
        );

        isRecording.subscribe(() => {
          if (isRecording.peek()) {
            activateState("recording");
          } else {
            deactivateState("recording");
          }
        });
      }}
    />
  ) as Gtk.Widget;

  return (
    <window
      gdkmonitor={monitor}
      name={`bar-${monitorName}`}
      namespace="bar"
      class="Bar"
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      keymode={Astal.Keymode.NONE}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT
      }
      visible={createComputed(() => {
        return !fullscreenClient();
      })}
      layer={Astal.Layer.TOP}
      $={(self) => {
        setup(self);
        (self as any).monitorName = monitorName;
      }}
    >
      <centerbox>
        <box
          $type="start"
          hexpand
        />

        <box
          class={barState((state) => `bar ${state}`)}
          $type="center"
          widthRequest={currentWidth}
          hexpand={false}
          $={(self) => {
            const windowInstance = new Window();

            (self as any).barWindow = windowInstance;

            let leaveTimer: Timer | null = null;

            const motion =
              new Gtk.EventControllerMotion();

            motion.connect("enter", () => {
              if (leaveTimer !== null) {
                leaveTimer.cancel();
                leaveTimer = null;
              }

              activateState("expanded");
            });

            motion.connect("leave", () => {
              if (leaveTimer !== null) {
                leaveTimer.cancel();
                leaveTimer = null;
              }

              leaveTimer = timeout(250, () => {
                leaveTimer = null;

                if (!windowInstance.popupIsOpen()) {
                  deactivateState("expanded");
                }
              });
            });

            self.add_controller(motion);
          }}
        >
          {barStack}
        </box>

        <box
          $type="end"
          hexpand
        />
      </centerbox>
    </window>
  );
};
