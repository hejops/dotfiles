#

## Layer 0

- 10x4 grid is bog-standard qwerty, and will not be shown
- lshift, rshift, caps (esc), and \ are still used, but their use will gradually
  be avoided in favour of thumb cluster (see below)
- no distinction is made between lshift/rshift

```text
                        +---+           +---+
                        |win|---+   +---|tab|
                    +---+---|esc|   |shf|---+---+
                    |L1 |   |---+   +---|   |L2 |
                    |bsp|ctl|           |ent|spc|
                    +---+---+           +---+---+
```

- thumb cluster layout is representative of ergodash (4 keys per thumb)
- because elora and kinesis have more keys (5 and 6 respectively), they can
  afford to use the inner keys for navigation (though this is still undesirable
  due to stretching of thumb)
  - kinesis additionally affords alt (never used), and rctrl (compose key); i
    have yet to find a suitable position for the latter, but comma might be a
    good candidate

## Layer 1 (symbols)

```text
|F1 |   |   |   |   |                           |   |   |   |   |F10|
| ~ | _ | < | { |   |                           |F11| } | > | + | " |
| ` | - | ( | [ |   |                           |F12| ] | ) | = | ' |
|   | | |   |   |   |                           |   |   |   | \ |   |
```

- on kinesis, both symbol rows occupy the same (5th) row; the upper symbol row
  must therefore be accessed with shift, which is only mildly annoying
- default fn key layout is horrible on kinesis (and i don't feel like
  remapping), but fn keys are almost never used anyway

## Layer 2 (navigation)

```text
|   |   |   |   |   |                           |   |   |   |   |   |
|   |   |hom|end|   |                           |   | < | > |   |   |
|   |   |pup|pdn|   |                           |   | v | ^ |   |   |
|   |   |   |   |   |                           |   |   |   |   |   |
```

- basically only used for ssh, where inputrc is absent.
  though this issue might be avoided entirely by just rsync-ing inputrc into the
  machine?
