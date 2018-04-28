(when (configuration-layer/package-usedp 'my-package)
  ;; Create the magic #! headers for a Tcl file
  ;; This will always insert at the top, but will do nothing
  ;; if the file already has a #! header
  (defun spacemacs/tcl-stub-file-exec ()
    "Inserts proper headers for an executable tcl file."
    (interactive)
    (beginning-of-buffer)
    ;; if it already appears to have the #!, just stop
    (if (looking-at "^#!")
        ()
      (progn
        (insert "#!/bin/sh\n"
                "# The next line is executed by /bin/sh, but not tcl \\\n"
                "exec " tcl-default-application " \"$0\" ${1+\"[email protected]\"}\n\n")
        )))

  ;; Create the file headers as per the style guide recommendations
  ;; This queries for a package name and version and insert the code
  ;; for package provision and namespace (thus Tcl8+ oriented)
  (defun spacemacs/tcl-stub-file (pkgname pkgversion)
    "Inserts proper headers in a Tcl file."
    (interactive "sPackage Name: \nsPackage Version: ")
    (beginning-of-buffer)
    (if (looking-at "^#!")
        ;; If the file begins with "#!" (exec magic)
        ;; move forward to first empty line to avoid messing with it.
        (search-forward "\n\n" (point-max) t)
      )
    (insert "# " (file-name-nondirectory buffer-file-name) " --\n#\n"
            "#\tThis file implements package " pkgname ", which  ...\n"
            "#\n# Copyright (c) " (format-time-string "%Y" (current-time)) " " user-full-name "\n#\n"
            "# See the file \"license.terms\" for information on usage and\n"
            "# redistribution of this file, and for a DISCLAIMER OF ALL WARRANTIES.\n"
            "#\n"
            "# RCS: @(#) $Id: $ \n\n"
            "#package require NAME VERSION\n"
            "package provide " pkgname " " pkgversion
            "\n\nnamespace eval " pkgname " {;\n"
            "#namespace export -clear *\n"
            "\n\n}; # end of namespace " pkgname "\n")
    (search-backward "\n};"))

  ;; Insert the stub headers for a proc with the style guide format
  ;; Queries for procedure name and args
  (defun spacemacs/tcl-stub-proc (procname argnames)
    "creates proper headers for a tcl proc"
    (interactive "sProcedure Name: \nsArguments: ")
    (let ((start (point)))
      (insert "# " procname " --\n"
              "#\n#   ADD COMMENTS HERE\n"
              "#\n# Arguments:\n"
              "#   args\tcomments\n"
              "# Results:\n#   Returns ...\n#\n"
              "proc " procname " {" argnames "} {\n\n}\n")
      (indent-region start (point) (tcl-calculate-indentation start))
      ;; move to body of proc
      ;; maybe should move to ADD to encourage commenting from the start
      (search-backward "\n}")
      ))

  ;; Inserts a package ifneeded command, meant for pkgIndex.tcl
  ;; Queries for package name, version, tcl file and procedure names of
  ;; the package
  (defun spacemacs/tcl-stub-pkgindex (pkgname pkgversion tclfile procnames)
    "creates package ifneeded stub line proper for pkgIndex.tcl file"
    (interactive "sPackage Name: \nsPackage Version: \nFTcl File: \nsProcedures: ")
    (let ((start (point)))
      (insert "package ifneeded " pkgname " " pkgversion
              " [list tclPkgSetup $dir " pkgname " " pkgversion
              " {\n    {" (file-name-nondirectory tclfile)
              " source {\n\t" procnames "\n}}}]\n"
              )
      (search-backward "\n}")
      ))

  ;; Creates stub namespace headers
  ;; Queries for namespace name
  (defun spacemacs/tcl-stub-namespace (namespace)
    "creates proper headers for a tcl namespace"
    (interactive "sNamespace Name: ")
    (let ((start (point)))
      (insert "# Namespace " namespace " --\n"
              "#\n#   ADD COMMENTS HERE\n#\n"
              "namespace eval " namespace " {;\n"
              "#namespace export -clear *\n"
              "\n\n}; # end of nameespace " namespace "\n")
      (indent-region start (point) (tcl-calculate-indentation start))
      (search-backward "\n};")
      ))

  (defun spacemacs/forward-tcl-definition ()
    "Move forward to the next procedure definition."
    (interactive)
    (forward-char)
    (re-search-forward "proc ")
    (goto-char (match-beginning 0))
    (recenter '(4)))

  (defun spacemacs/backward-tcl-definition ()
    "Move backward to the previous procedure definition."
    (interactive)
    (re-search-backward "proc ")
    (goto-char (match-beginning 0))
    (recenter '(4)))
  )
