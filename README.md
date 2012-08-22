# What is this?

SmartIM is a plugin to make vim stand well with input methods. It switches
the input method to the default keyboard (usually English) when leaving insert mode and
switches back when you enter insert mode again. It consists of 2 tiny programs:

* `im-select`: a command-line utility to get/set active input method
* `smartim.vim`: a vim plugin to do automatic input method switch, using `im-select`

It is Mac-only for now.

# How to use it?

1. Clone this repository to your local disk
2. Run `make` under root directory to compile `im-select` (or you can use the compiled binary directly)
3. Copy `im-select` to a directory in your $PATH
4. Copy `smartim.vim` to your vim plugin directory (usually `.vim/plugins`)
5. Relauch vim and enjoy the convenience

# FAQ

## Why is it Mac-only?

Because the command-line utility `im-select` uses Mac specific APIs. It should be easy to develop
equivalents for other platforms but I just don't have the time to do so.

## Can I use `im-select` as a standalone utility?

Sure. The usge is very simple: invoke it with no argument to get the ID string of current active
input method; invoke it with an ID string to set current input method.

```
$ im-select
com.apple.keylayout.US # print the ID string of your active input method
$ im-select com.apple.keylayout.US # change your active input method
```

## But my default keyboard is not US English

SmartIM will assume your default keyboard is UE English (com.apple.keylayout.US). If you want to change this,
please add the following line to your `.vimrc`:

`let g:smartim_default = '<your_default_keyboard_id>'`

Replace `<your_default_keyboard_id>` with the ID string of your input method (which can be get via `im-select`)
