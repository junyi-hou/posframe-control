;;; posframe-control.el --- provide keyboard control for posframe -*- lexical-binding: t; -*-

;; Author: Junyi Hou <junyi.yi.hou@gmail.com>
;; Maintainer: Junyi Hou <junyi.yi.hou@gmail.com>
;; URL: https://github.com/junyi-hou/posframe-control
;; Version: 0.0.1
;; Package-requires: ((emacs "26") (posframe "0.5.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This snippet provides keyboard interaction support for posframe
;; (https://github.com/tumashu/posframe).  This is achieved by advising
;; `posframe-show' and add two keywords, `:keymap' and `:hide-fn'. By setting
;; these keywords when calling `posframe-show', one can control the posframe
;; indirectly.
;;
;; In order to overshadow current keymapings, I using `set-transient-map' to
;; temporarily activate keymap defined in `:keymap' to control posframe.
;; This keymap is automatically deactivated when the function specified in
;; `:hide-fn' is called.


;; usage:

;; define posframe using `posframe-show' with extra keywords.
;; Customize `posframe-control-keymap' to suit your need. For any additional
;; command, define them using `posframe-control-command'

;; example:
;; TODO


;;; Code:

(require 'posframe)

(defgroup posframe-control nil
  "Group for posframe-control"
  :group 'posframe
  :prefix "posframe-control-")

(defvar-local posframe-control--deactivate-fn nil)

(defun posframe-control-next-three-lines (posframe-buffer)
  "Scroll POSFRAME-BUFFER down by 3 lines."
  (posframe-funcall posframe-buffer #'scroll-up 3))

(defun posframe-control-prev-three-lines (posframe-buffer)
  "Scroll POSFRAME-BUFFER up by 3 lines."
  (posframe-funcall posframe-buffer #'scroll-down 3))

(defun posframe-control-scroll-down (posframe-buffer)
  "Scroll down POSFRAME-BUFFER half page."
  (posframe-funcall posframe-buffer #'scroll-up (max 1 (/ (1- (window-height (selected-window))) 2))))

(defun posframe-control-scroll-up (posframe-buffer)
  "Scroll up POSFRAME-BUFFER half page."
  (posframe-funcall posframe-buffer #'scroll-down (max 1 (/ (1- (window-height (selected-window))) 2))))

;;;###autoload
(defun posframe-control-hide (posframe-buffer)
  "Hide posframe."
  (posframe-hide posframe-buffer)
  (when posframe-control--deactivate-fn
    (let ((fn posframe-control--deactivate-fn))
      (setq posframe-control--deactivate-fn nil)
      (funcall fn))))

;;;###autoload
(defun posframe-control-delete (posframe-buffer)
  "Delete posframe."
  (posframe-delete posframe-buffer)
  (when posframe-control--deactivate-fn
    (let ((fn posframe-control--deactivate-fn))
      (setq posframe-control--deactivate-fn nil)
      (funcall fn))))

(defun posframe-control-allow-control (posframe-buffer &rest args)
  "Advicing `posframe-show' so that if it is called with :control-keymap keyword set, the posframe can be control using the specified keymap"
  (let ((keymap (plist-get args :control-keymap))
        (hide-fn (plist-get args :hide-fn)))
    (when (keymapp keymap)
      (setq-local posframe-control--deactivate-fn (set-transient-map
                                                   keymap
                                                   t
                                                   hide-fn)))))

(defalias 'posframe-control-show #'posframe-show)

(advice-add 'posframe-control-show :after 'posframe-control-allow-control)


(provide 'posframe-control)
;;; posframe-control.el ends here
