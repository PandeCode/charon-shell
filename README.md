This was also playing alot with lua.

Tailwind like styling

base16 colors (plan for base24)

Glade
Lua
Fennel
Typescript

Teal ?

Shrodinger's bugs

useRef => Variable

https://www.svgrepo.com/

mkdir -p /home/shawn/.cache/charon-shell/fetch/

custom props
: ref: (object of current element) => (optional)
: intercept

Elements.Create

If not defined in [./ts/\_G.d.ts](./ts/_G.d.ts)

When a function is passed in the function is passed the props as the first arg and then the `...args` are the children

Anatomy of an element

```ts
function El(props: object, ...children: object[]) {
print(props, children);
}

const el = <El/>
cosnt el_2 = <El></El>
cosnt el_2 = <El>{"1"}{"2"}<El/></El>
```

can be used as

which transpiles to

```lua
local function El(props, ...)
local children = {...}
    print(props, children)
end

local el = Elements.Create(El, nil)
local el_2 = Elements.Create(El, nil)
local el_2 = Elements.Create(
    El,
    nil,
    "1",
    "2",
    Elements.Create(El, nil)
)
```
