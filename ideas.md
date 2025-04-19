###### Sample Async Code

```ts
astal.exec_async(
  [
    "bash",
    "-c",
    `echo 'print("return" .. (require "lua.utils").serialize((require "lua.extras.sysinfo").get_all_info()))' | lua`,
  ],
  (out: string) => {
    if (out !== null) {
      let [data] = load(out);
      if (data) {
        let tbl = data();
        if (tbl) {
          setInfo(() => tbl);
        } else {
          error("Failed to execute data -> table;");
        }
      } else {
        error("Failed to load out -> data;");
      }
    } else {
      error("Failed to execute info;");
    }
  },
);
```
