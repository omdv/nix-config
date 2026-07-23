;;; init.el -*- lexical-binding: t; -*-

(doom!
 :completion
 vertico

 :ui
 doom
 doom-dashboard
 hl-todo
 modeline
 ophints
 (popup +defaults)
 vc-gutter
 vi-tilde-fringe
 workspaces

 :editor
 (evil +everywhere)
 file-templates
 fold
 snippets

 :emacs
 dired
 electric
 undo
 vc

 :checkers
 syntax

 :tools
 direnv
 editorconfig
 lookup
 lsp
 magit

 :lang
 emacs-lisp
 (nix +lsp)
 (python +lsp)
 sh

 :config
 (default +bindings +smartparens))
