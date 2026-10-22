# Opt-in for minted. The shared settings (build/, Pygments style) come from
# ~/.config/latexmk/latexmkrc; -shell-escape is deliberately not global.
$pdflatex = "pdflatex -shell-escape -synctex=1 -interaction=nonstopmode -file-line-error %O %S";
# Never stop for keyboard input on an error.
$force_mode = 1;
