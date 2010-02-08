;;; dracula-mode.el --- major mode providing a DRACULA rules mode hook for fontification
;;; $Id: dracula-mode.el,v 1.9 2002/10/01 15:49:11 vdplas Exp vdplas $

;; Emacs Lisp Archive Entry
;; Author: Geert Van der Plas <geert_vanderplas@email.com>
;; Keywords: dracula, rules files
;; Filename: dracula-mode.el
;; Last-Updated: 1 October 2002
;; Description: mode for editing DRACULA(TM) rules files.
;; URL: http://www.esat.kuleuven.ac.be/~vdplas/dracula/
;; Compatibility: Emacs21

;; Implementation uses generic-mode (generic.el) and is based on examples
;; found in generic-x.el. DRACULA is a trademark of Cadence Design Systems, Inc.
;; comments, suggestions, hacks are welcome.

;; Copyright (C) 2002 Geert A. M. Van der Plas <geert_vanderplas@email.com>

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;; INSTALL:
;; ========

;; byte compile dracula-mode.el to dracula-mode.elc (see `byte-compile-file')
;; put these two files in an arbitrary, but accesible directory
;; for example: $HOME/emacs, /usr/lib/emacs/site-lisp/ or 
;; /usr/local/lib/emacs/site-lisp/

;; If you chose a non-standard place to put the files add the following
;; line to your Emacs start-up file (`.emacs') or custom `site-start.el'
;; file (replace <directory-name> by the directory where you placed 
;; dracula-mode.el and dracula-mode.elc):
;; (setq load-path (cons (expand-file-name "<directory-name>") load-path))

;; to activate DRACULA mode put (preferred method):
;; (require 'dracula-mode) 
;; in your Emacs start-up file (`.emacs') or custom `site-start.el' file
;; alternatively you could add:
;; (autoload 'dracula-mode "dracula-mode" "Editing dracula files." t)
;; (setq auto-mode-alist (append (list (cons "\\.drc$" 'dracula-mode))
;; 				 auto-mode-alist))

;;; Code:

(require 'generic)
(require 'font-lock)

(defconst dracula-version "1.2 (1 October 2002)"
  "Current version of DRACULA mode.")

(defconst dracula-developer 
  "Geert Van der Plas (<geert_vanderplas@email.com>)"
  "Current developer/maintainer of dracula-mode.")

(defconst dracula-section-keywords
  (list "*DESCRIPTION" "*INPUT-LAYER" "*OPERATION" "*PLOT")
  "dracula section keywords") ;; for imenu and font-lock'ing

(defconst dracula-command-keywords
  (list
   "AND" "ANDNOT" "AREA" "ATTACH" "ATTRIBUTE" "*BREAK" "BY"
   "CALCULATE" "CAP" "CAT" "CHKPAR" "COEFFICIENT" "COMPUTE" "CONNECT"
   "CONNECT-LAYER" "CORNER" "COVERAGE" "CUT" "CUT_TERM" "DATATYPE"
   "DEVTAG" "DIO" "DrcAntenna" "drcAntenna" "ECONNECT" "EDTEXT" "ELCOUNT"
   "ELEMENT" "ENC" "ENCLOSE" "EQ" "EQUATION" "EXPLODE" "EXT"
   "extractParasitic" "FLATTEN" "FLOATCHK" "FRACTURE" "FRINGE CAP"
   "GLOBAL-SCONNECT" "GPATHCHK" "GPATHDEF" "GROW" "HEDTEXT" "HIERARCHEN"
   "INSIDE" "INT" "LCONNECT" "LE" "LENGTH" "LEXTRACT" "LINK" "LPECHK"
   "LPESELECT" "LT" "LVSCHK" "LVSPLOT" "MOS" "MULTILAB" "NDCOUNT" "NE"
   "NEIGHBOR" "NODE-FILE" "NODE-SELECT" "NOT" "OCTBIAS" "OR" "OUTPUT"
   "OUTSIDE" "OVERLAP" "OVL" "PARAMETER" "PARASITIC" "PATHCHK"
   "PERIMETER" "PGCONVERT" "PGEFILE" "PGEMERGE" "PLENGTH" "POSTENC"
   "PROBE" "RANGE" "RCONNECT" "RELOCATE" "RES" "RESISTANCE" "RLENGTH"
   "RSPFSELECT" "SAMELAB" "SCONNECT" "SELECT" "SHRINK" "SIZE" "SNAP"
   "SOFTCHK" "SPFSELECT" "STAMP" "TEXTTYPE" "TOUCH" "TRIANGLE" "VERTEX"
   "WIDTH" "XBOX" "XCELL" "XDEVICE" "XOR" "XVIA" "PLOT" "PLOTCOMMAND"
   "PLOTFORMAT" "PLOTHOST" "PLOTHOSTLOGIN" "PLOTMODE" "PLOTOUTPUT"
   "PLOT-PEN-WIDTH" "PLOT-PROGRAM-DIR" "PLOTSCALE" "PLOTTER"
   "PLOT-TEXT-SIZE" "PLOT-TITLE" "PLOT-WINDOW" "WINDOW")
  "list of dracula keywords") ;; for font-lock'ing only


(define-generic-mode 'dracula-generic-mode
  ;; comment character:
  (list ?\;)
  ;; keywords
  dracula-command-keywords
  ;; font-lock regexps
  (list 
   ;; sections:
   (list (concat "^\\s-*" 
		 (regexp-opt (append dracula-section-keywords '("*END")) t))
	 '(1 'font-lock-function-name-face))
   ;; parameters: name = value
   '("\\(\\<\\w*\\(\\s(\\w*\\s)\\)*\\)\\s-*=" 1 font-lock-variable-name-face)
   ;; & constructs:
   (list "\\&\\s-*$" 0 'font-lock-keyword-face)
   )
  ;; auto-mode-alist regexps
  (list "\\.ba\\'" "\\.drc\\'" "\\.erc\\'" "\\.lpe\\'" "\\.lvs\\'")
  ;; init function, runs after setup by generic
  (list
   (function
    (lambda ()
      (setq font-lock-defaults (list 'generic-font-lock-defaults nil t ; case insensitive
				     (list (cons ?* "w") (cons ?- "w"))))
      (setq imenu-generic-expression
	    (list 
	     (list nil (concat "^\\s-*" 
			       (regexp-opt dracula-section-keywords t)) 1))
	    imenu-case-fold-search t
	    )
      ;;(imenu-add-to-menubar "Index")
      (message "Dracula mode %s. Type C-h m for documentation." ;; always
	       dracula-version)
      )))
  "Generic mode for DRACULA rules files. The mode has built-in
font-lock support/syntactic highlighting, imenu indexing of blocks and
`auto-mode-alist' based automatic activation.  Current version is
`dracula-version', developed by `dracula-developer'.

Provides an initialization hook `dracula-generic-mode-hook'.")

;; for lazy users:
(defalias 'dracula-mode 'dracula-generic-mode)

;; this is sometimes useful
(provide 'dracula-mode)

;;; dracula-mode.el ends here

;;; Local Variables:
;;; mode:Emacs-lisp
;;; End:  
