// --- Common Types ---
declare type Binding<_> = {};
declare type Variable<_> = {};
declare type SVariable<T> = Binding<Variable<T>> & {
  _v: Variable<T> & CallableFunction;
};

type TransitionType =
  | "NONE"
  | "CROSSFADE"
  | "SLIDE_RIGHT"
  | "SLIDE_LEFT"
  | "SLIDE_UP"
  | "SLIDE_DOWN"
  | "SLIDE_LEFT_RIGHT"
  | "SLIDE_UP_DOWN"
  | "OVER_UP"
  | "OVER_DOWN"
  | "OVER_LEFT"
  | "OVER_RIGHT"
  | "UNDER_UP"
  | "UNDER_DOWN"
  | "UNDER_LEFT"
  | "UNDER_RIGHT"
  | "OVER_UP_DOWN"
  | "OVER_DOWN_UP"
  | "OVER_LEFT_RIGHT"
  | "OVER_RIGHT_LEFT";

type RevealerTransitionType =
  | "NONE"
  | "CROSSFADE"
  | "SLIDE_RIGHT"
  | "SLIDE_LEFT"
  | "SLIDE_UP"
  | "SLIDE_DOWN";

type Align =
  | "FILL"
  | "START"
  | "END"
  | "CENTER"
  | "BASELINE_FILL"
  | "BASELINE"
  | "BASELINE_CENTER";

// --- Base Widget Props ---
interface Widget {
  on_destroy?: CallableFunction;
  onDestroy?: CallableFunction;
  key?: any;
  className?: string | string[];
  class_name?: string;
  css?: object | string;
  hexpand?: boolean;
  vexpand?: boolean;
  expand?: boolean;
  valign?: Align;
  halign?: Align;
  width?: number;
  height?: number;
  visible?: boolean;

  ref?: Variable<Widget>;
}

// --- Layout Props ---
interface LayoutProps {
  vertical?: boolean;
  spacing?: number;
}

// --- Event Handlers ---
interface Clickable {
  onClick?: () => void;
  on_clicked?: () => void;
}

// --- Specific Element Types ---
type Div = Widget & LayoutProps;

type Button = Widget &
  Clickable & {
    label?: string;
  };

type TextWidget = Widget & {
  label?: string;
};

type InputWidget = Widget & {
  text?: string;
  on_changed?: (text: string) => void;
};

type ValueWidget = Widget & {
  value?: number;
};

type ToggleWidget = Widget & {
  active?: boolean;
  on_toggled?: (active: boolean) => void;
};

// --- JSX Intrinsic Elements ---
declare namespace JSX {
  interface IntrinsicElements {
    div: Div;
    box: Div;
    grid: Div & {
      "column-homogeneous"?: boolean;
      "row-homogeneous"?: boolean;
      "column-spacing"?: number;
      "row-spacing"?: number;
    };
    griditem: Div & { x: number; y: number; w: number; h: number };
    p: Div;
    span: Widget & { vertical?: boolean };

    button: Button;
    btn: Button;
    centerbox: Widget & LayoutProps;
    circularprogress: ValueWidget;
    drawingarea: Widget;
    entry: InputWidget;
    eventbox: Widget & { on_button_press_event?: CallableFunction };
    icon: Widget & { name?: string; size?: number };
    label: TextWidget;
    levelbar: ValueWidget;
    overlay: Widget;
    revealer: Widget & {
      reveal_child?: boolean;
      transition_type?: RevealerTransitionType;
      transition_duration?: number;
    };
    scrollable: Widget;
    slider: ValueWidget & {
      on_value_changed?: (value: number) => void;
    };
    stack: Widget & {
      transition_type: TransitionType;
      transition_duration: number;
    };
    switch: ToggleWidget;
    hr: Widget;
  }
}
