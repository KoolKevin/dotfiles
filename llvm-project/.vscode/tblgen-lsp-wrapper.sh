#!/bin/bash

# CMake generates the tablegen_compile_commands.yml database from the actual
# tablegen()/mlir_tablegen() invocations. Each entry says “this .td  file is 
# compiled with these -I directories”. So it only has entries for the .td files
# that are inputs to a tablegen command, not for every .td file in the tree.
#
# When you open a .td file, the lsp server looks up that file’s entry and uses
# its include directories to resolve the #include "*.td" directives. .td files
# that have an entry in the database work out of the box; but .td files that are
# only included by other files and never passed to tablegen, have no entry, and
# therefore no include directories. 
#
# This wrapper gives the lsp server a global fallback (mlir/include and friends)
# for files with no entry. It's invocation is specified in settings.json
# exec /home/kevin/llvm-project/install/bin/tblgen-lsp-server \
#   --tablegen-extra-dir=/home/kevin/llvm-project/mlir/include \
#   --tablegen-extra-dir=/home/kevin/llvm-project/llvm/include \
#   --tablegen-extra-dir=/home/kevin/llvm-project/build/tools/mlir/include \
#   "$@"

# usa il binario dentro build/
exec /home/kevin/llvm-project/build/bin/tblgen-lsp-server \
  --tablegen-extra-dir=/home/kevin/llvm-project/mlir/include \
  --tablegen-extra-dir=/home/kevin/llvm-project/llvm/include \
  --tablegen-extra-dir=/home/kevin/llvm-project/build/tools/mlir/include \
  "$@"
