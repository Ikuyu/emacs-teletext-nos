
# emacs-teletext-nos

Read NOS Teletext pages in Emacs.

## Requirements

* Use-package
* Quelpa
* [Bitstream Vera Sans Mono font](http://legionfonts.com/fonts/bitstream-vera-sans-mono)
* Teletext package

To install the required Teletext package add this to your Emacs config:

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

<center><img src="nos-teletekst.png" height="500"></center>

## Usage

Within Emacs type `M-x teletext` [ENTER]. Use the left mouse button to click on the word `NOS` or set a key globally like this:

```elisp
(global-set-key (kbd "C-c e t") (lambda ()
                                  (interactive)
                                  (teletext)
                                  (teletext-select-network "NOS")
                                  (setq-local line-spacing nil))) ; temporarily reset set line-spacing
```
