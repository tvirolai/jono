;;; jono.el --- A local (Youtube) play queue in Org mode -*- lexical-binding: t -*-

;; Copyright (C) 2026 Tuomo Virolainen

;; Author: Tuomo Virolainen <tvirolai@soittakaaparanoid.mail.kapsi.fi>

;; URL: https://github.com/tvirolai/jono
;; Keywords: lisp
;; Version: 0.0.1

(defconst jono--version "0.0.1")

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

;;; Code:

(defgroup jono ()
  "Settings for Jono."
  :group 'media)

(defcustom jono-command "mpv"
  "The command to run for the queue."
  :type 'string
  :group 'jono)

(defcustom jono-command-args '("--no-video" "--force-window=no")
  "The arguments for the command to run."
  :type 'list
  :group 'jono)

(defcustom jono-buffer "*Jono*"
  "The name for the Jono buffer.")

(defvar jono--process
  "The playback process." nil)

(defvar jono--queue
  "The internal representation of the queue." '())

(defconst jono--process-name "jono-playback")

(defun jono-start-playback (url)
  "Start playback for URL."
  (let ((status (process-status jono--process-name)))
    (when (memq status '(run stop))
      (kill-process jono--process-name))
    (let* ((buffer (get-buffer-create jono-buffer))
           (cmd (cons jono-command jono-command-args))
           (fullcmd (append cmd (cons url '()))))
      (with-current-buffer buffer
        (comint-mode))
      (setq jono--process (make-process :name jono--process-name
                                        :buffer "*Jono*"
                                        :command fullcmd
                                        :filter #'comint-output-filter))
      (set-process-sentinel jono--process #'(lambda (process event)
                                              (let ((finished-signal "finished\n"))
                                                (message event)
                                                (when (string= finished-signal event)
                                                  (let ((next (car jono--queue)))
                                                    (message "Playing the next one")
                                                    (setq jono--queue (cdr jono--queue))
                                                    (jono-start-playback next)))))))))

(defvar test-url
  "https://youtube.com/watch?v=jW-S5tnA3aw")

(defvar test-url-short
  "https://youtube.com/watch?v=_-ywSPWu3K8")

(setq jono--queue (cons test-url '()))

(defun testaa ()
  (interactive)
  (message "Let's play")
  (jono-start-playback test-url-short))

(defun jono-play ())

(defun jono-stop ())

(defun jono-add-to-queue ())

(defun jono-play-next ())

(provide 'jono)

;;; jono.el ends here
