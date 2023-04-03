;;; teletext-nos.el --- Teletext provider for the Dutch Broadcasting Foundation NOS -*- lexical-binding: t -*-
;;
;; Package requirements: Emacs 24.3, Teletext 0.1 package and Bitstream Vera Sans Mono font
;; Version: 0.1.1
;; Keywords: comm help hypermedia
;;
;; This file is not part of GNU Emacs.
;;
;; The MIT Licence (MIT)
;;
;; Copyright (C) 2023 Edwin H. Jonkvorst.
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; The Software Is Provided "As Is", Without Warranty Of ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;; IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
;; CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
;; TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
;; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;;
;; Note: The NOS Teletekst pages are in Dutch.

(require 'url)
(require 'json)
(require 'teletext)

(defvar teletext-nos--cache (make-hash-table)
  "Cache for recently retrieved NOS Teletext pages.")

(defun teletext-nos--page-url (page &optional subpage)
  "Internal helper to get the URL for a NOS Teletext PAGE."
  (concat "https://teletekst-data.nos.nl"
   	  "/json/"
          (number-to-string page)
          (when (not (null subpage))
            (concat "-" (number-to-string subpage)))))

;; NOS Teletekst uses the following colors.
(defconst teletext-nos--colors
  '("black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" "null")
  "Internal list of NOS Teletekst colors. Background colors have prefix bg-.")

;; NOS Teletekst uses the following html tags.
(defconst teletext-nos--html-tags
  '("<span" "\">" "<span>" "</span>")
  "Internal list of NOS Teletext html tags.")

;; NOS Teletekst uses the following entities.
(defconst teletext-nos--entities
  '(("&quot;"   . "\u0022") ; HTMLspecial
    ("&amp;"    . "\u0026")
    ("&apos;"   . "\u0027")
    ("&lt;"     . "\u003C")
    ("&gt;"     . "\u003E")
    ("&AElig;"  . "\u00C6") ; HTMLlat1
    ("&Aacute;" . "\u00C1")
    ("&Acirc;"  . "\u00C2")
    ("&Agrave;" . "\u00C0")
    ("&Aring;"  . "\u00C5")
    ("&Atilde;" . "\u00C3")
    ("&Auml;"   . "\u00C4")
    ("&Ccedil;" . "\u00C7")
    ("&ETH;"    . "\u00D0")
    ("&Eacute;" . "\u00C9")
    ("&Ecirc;"  . "\u00CA")
    ("&Egrave;" . "\u00C8")
    ("&Euml;"   . "\u00CB")
    ("&Iacute;" . "\u00CD")
    ("&Icirc;"  . "\u00CD")
    ("&Igrave;" . "\u00CC")
    ("&Iuml;"   . "\u00CF")
    ("&Ntilde;" . "\u00D1")
    ("&Oacute;" . "\u00D3")
    ("&Ocirc;"  . "\u00D4")
    ("&Ograve;" . "\u00D2")
    ("&Oslash;" . "\u00D8")
    ("&Otilde;" . "\u00D5")
    ("&Ouml;"   . "\u00D6")
    ("&THORN;"  . "\u00DE")
    ("&Uacute;" . "\u00DA")
    ("&Ucirc;"  . "\u00DB")
    ("&Ugrave;" . "\u00D9")
    ("&Uuml;"   . "\u00DC")
    ("&Yacute;" . "\u00DD")
    ("&aacute;" . "\u00E1")
    ("&acirc;"  . "\u00E2")
    ("&aelig;"  . "\u00E6")
    ("&agrave;" . "\u00E1")
    ("&aring;"  . "\u00E5")
    ("&atilde;" . "\u00E3")
    ("&auml;"   . "\u00E4")
    ("&ccedil;" . "\u00E7")
    ("&eacute;" . "\u00E9")
    ("&ecirc;"  . "\u00EA")
    ("&egrave;" . "\u00E8")
    ("&eth;"    . "\u0111")
    ("&euml;"   . "\u00EB")
    ("&iacute;" . "\u00ED")
    ("&icirc;"  . "\u00EE")
    ("&igrave;" . "\u00EC")
    ("&iuml;"   . "\u00EF")
    ("&ntilde;" . "\u00F1")
    ("&oacute;" . "\u00F3")
    ("&ocirc;"  . "\u00F4")
    ("&ograve;" . "\u00F2")
    ("&oslash;" . "\u00F8")
    ("&otilde;" . "\u00F5")
    ("&ouml;"   . "\u00F6")
    ("&szlig;"  . "\u00DF")
    ("&thorn;"  . "\u00FE")
    ("&uacute;" . "\u00FA")
    ("&ucirc;"  . "\u00FB")
    ("&ugrave;" . "\u00F9")
    ("&uuml;"   . "\u00FC")
    ("&yacute;" . "\u00FD")
    ("&yuml;"   . "\u00FF")
    ("&#xF020;" . "\uF020") ; continuous block mosaic characters
    ("&#xF021;" . "\uF021")
    ("&#xF022;" . "\uF022")
    ("&#xF023;" . "\uF023")
    ("&#xF024;" . "\uF024")
    ("&#xF025;" . "\uF025")
    ("&#xF026;" . "\uF026")
    ("&#xF027;" . "\uF027")
    ("&#xF028;" . "\uF028")
    ("&#xF029;" . "\uF029")
    ("&#xF02a;" . "\uF02A")
    ("&#xF02b;" . "\uF02B")
    ("&#xF02c;" . "\uF02C")
    ("&#xF02d;" . "\uF02D")
    ("&#xF02e;" . "\uF02E")
    ("&#xF02f;" . "\uF02F")
    ("&#xF030;" . "\uF030")
    ("&#xF031;" . "\uF031")
    ("&#xF032;" . "\uF032")
    ("&#xF033;" . "\uF033")
    ("&#xF034;" . "\uF034")
    ("&#xF035;" . "\uF035")
    ("&#xF036;" . "\uF036")
    ("&#xF037;" . "\uF037")
    ("&#xF038;" . "\uF038")
    ("&#xF039;" . "\uF039")
    ("&#xF03a;" . "\uF03A")
    ("&#xF03b;" . "\uF03B")
    ("&#xF03c;" . "\uF03C")
    ("&#xF03d;" . "\uF03D")
    ("&#xF03e;" . "\uF03E")
    ("&#xF03f;" . "\uF03F")
    ("&#xF060;" . "\uF060")
    ("&#xF061;" . "\uF061")
    ("&#xF062;" . "\uF062")
    ("&#xF063;" . "\uF063")
    ("&#xF064;" . "\uF064")
    ("&#xF065;" . "\uF065")
    ("&#xF066;" . "\uF066")
    ("&#xF067;" . "\uF067")
    ("&#xF068;" . "\uF068")
    ("&#xF069;" . "\uF069")
    ("&#xF06a;" . "\uF06A")
    ("&#xF06b;" . "\uF06B")
    ("&#xF06c;" . "\uF06C")
    ("&#xF06d;" . "\uF06D")
    ("&#xF06e;" . "\uF06E")
    ("&#xF06f;" . "\uF06F")
    ("&#xF070;" . "\uF070")
    ("&#xF071;" . "\uF071")
    ("&#xF072;" . "\uF072")
    ("&#xF073;" . "\uF073")
    ("&#xF074;" . "\uF074")
    ("&#xF075;" . "\uF075")
    ("&#xF076;" . "\uF076")
    ("&#xF077;" . "\uF077")
    ("&#xF078;" . "\uF078")
    ("&#xF079;" . "\uF079")
    ("&#xF07a;" . "\uF07A")
    ("&#xF07b;" . "\uF07B")
    ("&#xF07c;" . "\uF07C")
    ("&#xF07d;" . "\uF07D")
    ("&#xF07e;" . "\uF07E")
    ("&#xF07f;" . "\uF07F"))
  "Internal list of NOS Teletekst entities.")

(defconst teletext-nos--regex
  (regexp-opt (append           ; regexp-opt takes a list of strings and produces a single regexp which matches any of them
               (-mapcat (lambda (entity) (list (car entity))) teletext-nos--entities)
               teletext-nos--html-tags
               teletext-nos--colors))
  "Internal regular expression to match one NOS Teletekst color or entity.")

(defun teletext-nos--download-page-json (page &optional subpage)
  "Internal helper to download the JSON for a NOS Teletekst PAGE."
  (let ((url (teletext-nos--page-url page subpage)))
    (with-temp-buffer
      (condition-case _
	  (let ((url-show-status nil))
	    (url-insert-file-contents url)
	    (json-read))
	((file-error)
	 (message "Teletext page not found")
	 nil)
	((json-error end-of-file)
	 (message "Error decoding teletext page")
	 nil)))))

(defun teletext-nos--get-page-json (page &optional subpage force)
  "Internal helper to get the JSON for a NOS Teletekst PAGE.

Previously visited pages are cached in `teletext-nos--cache`.
This function retrieves the page from cache unless the cache is
stale or FORCE is non-nil. A newly downloaded page is put in
cache."
  (let ((cached (unless force (gethash page teletext-nos--cache))))
    (when cached
      (let* ((timestamp (nth 0 cached))
	     (age (truncate (time-to-seconds (time-since timestamp)))))
	(when (> age 60)
	  (remhash page teletext-nos--cache)
	  (setq cached nil))))
    (or (and cached (nth 1 cached))
	(let ((json (teletext-nos--download-page-json page subpage)))
	  (puthash page (list (current-time) json) teletext-nos--cache)
	  json))))

(defun teletext-nos--parse-html ()
  "Internal helper to parse the html from a NOS Teletekst PAGE."
  (let ((tag-region-start nil)
        (tag-region-end nil)
        (text-region-start nil)
        (foreground-color nil)
        (background-color nil)
        (expression nil))
    (while (not (eobp))
      (while (not (eolp))

        ;; search for <span, ">, </span>, continuous block mosaic character or html entity
        (cond ((re-search-forward teletext-nos--regex nil t)
               (setq expression (match-string 0))
               (cond ((assoc expression teletext-nos--entities) ; continuous block mosaic character or html entity
                      (replace-match (cdr (assoc expression teletext-nos--entities))))
                     ((member expression teletext-nos--html-tags) ; <span, "> <span> or </span>
                       (cond ((or (equal expression "<span>") (equal expression "<span"))
                              (cond ((equal expression "<span>")
                                     (replace-match "")
                                     (setq text-region-start (point))
                                     (setq foreground-color "white"))      ; reset foreground color, but keep using the last found background color
                                    (t (setq tag-region-start (match-beginning 0)) ; beginning of <span
                                       (search-forward "\">" nil t)
                                       (setq tag-region-end (match-end 0)) ; we are now between <span .. ">
                                       ;; reset foreground color, but keep using the last found background color
                                       (setq foreground-color "white")
                                       (goto-char (- (point) 1))

                                       ;; search for a color
                                       (cond ((re-search-backward teletext-nos--regex nil t) ; TODO do not search further back than nescessary, so use tag-region-start?
                                              (setq expression (match-string 0))
                                              (cond ((equal "bg-" (buffer-substring (- (match-beginning 0) 3) (match-beginning 0)))
                                                     (setq background-color expression)
                                                     (when (re-search-backward teletext-nos--regex nil t) ; TODO do not search further back than nescessary, so use tag-region-start?
                                                       (setq expression (match-string 0))
                                                       (when (member expression teletext-nos--colors)
                                                         (setq foreground-color (match-string 0)))))
                                                    (t (setq foreground-color expression))))
                                             (t nil)) ; use default/last used colors
                                       (setq text-region-start tag-region-start)
                                       (delete-region tag-region-start tag-region-end)))) ; delete <span ..>
                             ((equal expression "</span>")
                              (replace-match "")
                              (teletext-put-color background-color foreground-color text-region-start (point))
                              ;;(setq foreground-color "white")
                              (setq background-color nil)
                              (let ((position (point)))
                                (while (not (equal position text-region-start)) ; search for any links
                                  (cond ((search-backward "<a" nil t)
                                         (setq tag-region-start (match-beginning 0))
                                         (re-search-forward teletext-nos--regex nil t) ; search for a color
                                         (setq foreground-color (match-string 0))
                                         (when (equal foreground-color "null")
                                           (setq foreground-color "white"))
                                         (search-forward "\">" nil t)
                                         (delete-region tag-region-start (match-end 0))
                                         (search-forward "</a>" nil t)
                                         (replace-match "")
                                         (teletext-put-color background-color foreground-color text-region-start (point)))
                                        (t (setq position text-region-start)))) ))
                             (t nil)))
                     (t nil)))
              (t goto-char (end-of-line))))
      (forward-line)))) ; move the point one line forward or place it at the end of the buffer

(defun teletext-nos--insert-from-json (parsed-json page subpage)
  "Internal helper to insert the contents of a NOS Teletekst PAGE.

SUBPAGE is the subpage (1..n) of that page. PARSED-JSON is an
Emacs Lisp representation of the JSON response corresponding to
PAGE from the NOS Teletekst data."
  (let* (
         (json (cond ((null parsed-json) ; if  no data/empty page (re)load the homepage
                      (teletext-nos--get-page-json 100))
                     ((null subpage)
                      parsed-json)
                     ((teletext-nos--get-page-json page subpage 'FORCE))))
         (page-number page)
         (next-page (cdr (assoc 'nextPage json)))
         (previous-page (cdr (assoc 'prevPage json)))
         (next-subpage (cdr (assoc 'nextSubPage json)))
         (previous-subpage (cdr (assoc 'prevSubPage json)))
         (subpages nil)
         (content (cdr (assoc 'content json)))
         (position (point)))

    (insert content)

    ;; find the total number of subpages
    (goto-char position)
    (if (equal page-number 100)
        (setq subpages 3) ; assuming there page 100 will always have 3 subpages
      (forward-line 7)
      (when (re-search-backward "[0-9]/[0-9]" nil t)
        (setq subpages (string-to-number (substring (match-string 0) 2 3))))
      (goto-char position))

    ;; parse html
    (teletext-nos--parse-html)

    ;; return header
    (list (cons 'page page-number)
          (cons 'subpage (cond ((and (string="" previous-subpage) (string="" next-subpage)) 1)    ; there are no subpases
                               (t subpage)))
          (cons 'subpages (if (null subpages)
                              1
                            subpages))
          (cons 'prev-page (string-to-number previous-page))
          (cons 'next-page (if (equal page-number 899)
                              100
                             (string-to-number next-page)))
	  (cons 'network-heading "NOS TELETEKST")
	  (cons 'network-page-text "Pagina:")
   	  (cons 'network-time-format "{dd}.{mm}. {HH}:{MM}"))))

(defun teletext-nos--page (network page subpage force)
  "Internal helper to insert the contents of NOS Teletekst PAGE/SUBPAGE.

NETWORK must be \"NOS\"."
  (cl-assert (equal network "NOS"))
  ;; check if required font is installed
  (if (not (find-font (font-spec :name "Bitstream Vera Sans Mono")))
      (user-error  "Error font not found Bitstream Vera Sans Mono")
    (progn
      (setq buffer-face-mode-face '(:family "Bitstream Vera Sans Mono" :height 190))
      (buffer-face-mode)))
  ;; load and insert page
  (teletext-nos--insert-from-json
   (teletext-nos--get-page-json page subpage force) ; the first time page 100 is requested
   page subpage))

(defun teletext-nos--networks ()
  "Internal helper to get the NOS Teletekst network list."
  '("NOS"))

;;;###autoload
(defun teletext-nos-provide ()
  "Add NOS to the Teletext network list."
  (teletext-provide
   'teletext-nos
   :networks #'teletext-nos--networks
   :page #'teletext-nos--page))

;;;###autoload
(teletext-nos-provide)

(provide 'teletext-nos)
