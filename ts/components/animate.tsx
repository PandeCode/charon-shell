import { astal, Elements, Variable } from "../../tslib/react";

export default function Animate(
  props: {
    kind?: RevealerTransitionType;
    duration?: number;
    delay?: number;
  } = { kind: "SLIDE_DOWN", duration: 500, delay: 500 },
  children = <>Empty Revealer</>,
) {
  const ref = Variable(null);
  const { kind, duration, delay } = props;
  astal.timeout(delay || 500, () => {
    const el = ref.get(ref);
    if (el != null) {
      el.reveal_child = true;

      const parent = ref.parent;
      const child = ref.reveal_child;

      if (child != null && parent != null) {
        ref.parent.add(ref.parent, child);
        ref.destroy(ref);
      }
    }
  });
  return (
    <revealer
      ref={ref}
      transition_type={kind || "SLIDE_DOWN"}
      transition_duration={duration || 500}
    >
      {children}
    </revealer>
  );
}
