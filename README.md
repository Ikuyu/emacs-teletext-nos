
# emacs-teletext-nos

Read NOS Teletext pages in Emacs.

## Requirements

* Use-package
* Quelpa
* [Bitstream Vera Sans Mono font](http://legionfonts.com/fonts/bitstream-vera-sans-mono)
* Teletext package

To install the Teletext package add the line below to your Emacs config:

```elisp
(use-package teletext)
```

## Installation

The last step is to add the `teletext-nos` package to your Emacs config. Use Quelpa until it’s available on Melpa.

```elisp
(use-package teletext-nos
  :defer t
  :after teletext
  :init (require 'teletext-nos)
  :quelpa (teletext-nos
           :fetcher github
           :repo "Ikuyu/emacs-teletext-nos"))
```

## Usage

Within Emacs type `M-x teletext` [ENTER]. Use the left mouse button to click on the word `NOS`.