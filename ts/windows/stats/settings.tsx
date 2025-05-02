import { astal, Gtk, Variable, Widget, Elements } from "../../../tslib/react";

const assets = require("lua.assets");
const { ninspect, inspect } = require("lua.utils");

const { encode, decode } = require("dkjson");

const { write_file, read_file_async, write_file_async } = astal;

export default function () {
  const entry_refs: any[] = [];

  const keys = Variable([]);
  read_file_async(assets.config_path, (out: string) => {
    if (out != null) {
      const json: object = decode(out);
      if (json != null) {
        let ret: [string, string | number | boolean][] = [];
        for (let [k, v] of pairs(json)) {
          ret.push([k as string, v as string | number | boolean]);
        }
        keys.set(keys, ret);
      }
    }
  });

  const save = () => {
    read_file_async(assets.config_path, (out: string) => {
      if (out != null) {
        const json = decode(out);
        if (json != null) {
          let changed = false;

          for (let r of entry_refs) {
            let [id, el, typ] = r;
            if (el != null) {
              if (typ == "string" && el.text != null && el.text != "") {
                json[id] = el.text;
                changed = true;
              } else if (typ == "number" && el.value != null) {
                json[id] = el.value;
                changed = true;
              } else if (typ == "boolean" && el.state != null) {
                json[id] = el.state;
                changed = true;
              } else {
                print("ERROR with settings");
              }
            }
          }

          if (changed) {
            const encoded = encode(json);
            if (encoded != null) {
              write_file_async(
                assets.config_path,
                encoded,
                () => (assets.config = assets.loadconfig()),
              );
            } else {
              print("Encoded null: ", inspect(encoded));
            }
          }
        }
      }
    });
  };

  return (
    <div vertical spacing={10}>
      {keys((k: [string, string | boolean | number][]) =>
        k.map((id) => (
          <div>
            {`${id[0]}: ${assets.config[id[0]] ?? "NULL"}`}
            {(() => {
              if (typeof id[1] == "boolean") {
                return (
                  <Gtk.Switch
                    halign="END"
                    state={id[1]}
                    ref={(self: any) => {
                      entry_refs.push([id[0], self, typeof id[1]]);
                    }}
                  />
                );
              } else if (typeof id[1] == "number") {
                return (
                  <Gtk.SpinButton
                    value={id[1]}
                    ref={(self: any) => {
                      entry_refs.push([id[0], self, typeof id[1]]);
                    }}
                    halign="END"
                    hexpand
                    adjustment={Gtk.Adjustment({
                      lower: 0,
                      upper: 64,
                      step_increment: 1,
                      page_increment: 1,
                      value: id[1],
                    })}
                  />
                );
              } else {
                return (
                  <Widget.Entry
                    halign="END"
                    hexpand
                    text={id[1]}
                    ref={(self: any) => {
                      entry_refs.push([id[0], self, typeof id[1]]);
                    }}
                  />
                );
              }
            })()}
          </div>
        )),
      )}

      <button onClick={save}>Save</button>
    </div>
  );
}
