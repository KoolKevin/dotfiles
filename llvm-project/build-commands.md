# build command corrente

```
cmake -G Ninja -S llvm -B build \
  -DLLVM_TARGETS_TO_BUILD="Native" \
  -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="MyRV" \ # togli quando non ti serve più
  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLLVM_ENABLE_ASSERTIONS=ON \
  -DCMAKE_INSTALL_PREFIX=/home/kevin/llvm-project/install/ \
  -DLLVM_ENABLE_PROJECTS="clang;mlir" -DCLANG_ENABLE_CIR=ON \
  -DLLVM_BUILD_TESTS=True -DLLVM_INSTALL_UTILS=ON \
  -DLLVM_USE_LINKER=mold -DLLVM_PARALLEL_LINK_JOBS=4 \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DBUILD_SHARED_LIBS=ON -DLLVM_USE_SPLIT_DWARF=ON \
  -DLLVM_OPTIMIZED_TABLEGEN=ON \
  -DLLVM_CCACHE_BUILD=ON \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

cmake -L -N è utile per vedere le variabili settate in build/CMakeCache.txt

# Opzioni utili

- **CMAKE_BUILD_TYPE=Debug** 
  - mi produce 200GiB di build e quindi è da evitare. L'unico vantaggio è che ottengo un debugging step-through totalmente seamless ma RelWithDebugInfo sembra andare bene lo stesso

- **LLVM_ENABLE_ASSERTIONS=ON**
  - è particolarmente importante con mlir dato che avere gli assert serve ad abilitare i flag di tracing da cli come -debug etc.

- **BUILD_SHARED_LIBS=ON**
  - Utile per incremental development (non bisogna relinkare 200 binari per una modifica)
  - Ogni libreria LLVM viene costruita come .so invece che come .a. Dopo una piccola modifica, ninja deve rilinkare solo la libreria toccata, non tutti gli eseguibili (clang, mlir-opt, mlir-lsp-server, i test...)
  - inoltre, **occupo molto meno spazio su disco** dato che non ho più 200 binari che includono le stesse librerie staticamente più e più volte, arrivando ad occupare 1 GiB ciascuno 
- Alternativamente, si può anche fare così:
  - -DBUILD_SHARED_LIBS=OFF # obbligatorio se attivi quelli sotto (mutalmente esclusivi)
  - -DLLVM_LINK_LLVM_DYLIB=ON 
  - -DMLIR_LINK_MLIR_DYLIB=ON
  - These allow me to build monolithic shared libraries instead of component shared libraries (a single big .so for llvm and mlir instead of many little ones)
  - the benefit that i get is that:
    - like BUILD_SHARED_LIBS=ON, i don't have to relink binaries when i do incremental modifications
    - also my binaries have to link dinamically with only a single .so, this may speed up first time linking and process startup / debugger performance (?)
  - however, with a single .so, a tiny modification requires me to rebuild the whole giant .so. This doesn't seem too suited for incremental development
    - **dovrei testare qual'è meglio**

- **LLVM_USE_SPLIT_DWARF=ON**
  - Compiling large C++ applications with debug information can lead to slow link times and possible out of memory conditions. For big applications it’s not uncommon for the debug information alone to take up 85% of the binary size.
  - Split DWARF tries to address this by splitting the debug information and storing the majority of it in separate DWARF object files. This significantly reduces the size of the object files the linker needs to process (that now just have a reference to the debug info) and thus speeds up the linking process.
  - **con questo mi sa che posso aggiungere più link jobs**
  - gdb e lldb lo supportano, ma i .dwo devono restare dove sono (non spostare la build/).

- **LLVM_OPTIMIZED_TABLEGEN**
  - serve a buildare tablegen senza debuginfo inutili e in maniera ottimizzata (O3). Questo è importante dato che tablegen serve a generare anche altri file di llvm che saranno da buildare successivamente. Avere tablegen più veloce velocizza il build in generale

- **LLVM_BUILD_TESTS=True** 
  - questo sembra che buildi gli unit test (gtest), che ricorda essere distinti dai Filetest regression test. Utile se fai del LLVM development un po' più serio

- **LLVM_INSTALL_UTILS=ON**
  - This installs additional LLVM utility executables. It is useful when you want a more complete installed LLVM toolchain, particularly for testing and development workflows.
  - It can include utilities such as FileCheck, count, not, split-file, and other testing-related tools

- **LLVM_ENABLE_PROJECTS**
  - lldb è uno dei progetti più pesanti da compilare. Se non lo usi davvero, toglilo da LLVM_ENABLE_PROJECTS.

- **LLVM_BUILD_EXAMPLES=ON**
  - compila esempi
  - sono pesanti! se non li usi meglio lasciar stare
