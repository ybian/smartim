# What is this?

SmartIM is a plugin to make vim stand well with input methods. It switches
the input method to the default keyboard (usually English) when leaving insert mode and
switches back when you enter insert mode again. It consists of 2 tiny programs:

* `im-select`: a command-line utility to get/set active input method
* `smartim.vim`: a vim plugin to do automatic input method switch, using `im-select`

It is Mac-only for now.

# Installation

## Vundle
1. Add this line to your ~/.vimrc file:
```Plugin 'ybian/smartim'```
2. Open vim and run `:PluginInstall`

## Pathogen
1. `cd ~/.vim/bundle`
2. `git clone git@github.com:ybian/smartim.git`

## Others
1. Clone this repository to your local disk
2. Copy `im-select` and `smartim.vim` (both are under `plugin` directory) to your vim plugin directory (usually `.vim/plugins`)

Then, enjoy the convenience!

# FAQ

## Why is it Mac-only?

Because the command-line utility `im-select` uses Mac specific APIs. It should be easy to develop
equivalents for other platforms but I just don't have the time to do so.

## Can I use `im-select` as a standalone utility?

Sure. The usage is very simple: invoke it with no argument to get the ID string of current active
input method; invoke it with an ID string to set current input method.

```
$ im-select
com.apple.keylayout.US # print the ID string of your active input method
$ im-select com.apple.keylayout.US # change your active input method
```

## What should I do if my default keyboard is not US English?

SmartIM assumes your default keyboard is US English (com.apple.keylayout.US). If you want to change this,
please add the following line to your `.vimrc`:

`let g:smartim_default = '<your_default_keyboard_id>'`

Replace `<your_default_keyboard_id>` with the ID string of your input method (which can be get via `im-select`)


## Somehow I want to disable this plugin

For example, some people reported that it is slow while editing with vim-multiple-cursors, to fix this, put this in .vimrc:

```
function! Multiple_cursors_before()
  let g:smartim_disable = 1
endfunction
function! Multiple_cursors_after()
  unlet g:smartim_disable
endfunction
```

## I have other problems to debug...

Follow the following steps:

1. Run vim with `vim --cmd 'let g:smartim_debug=1'`
2. Enter and leave insert mode for a couple of times to reproduce your problem; then exit vim.
3. Open an issue on github and attach the content of `~/vim_smartim_debug_output`
