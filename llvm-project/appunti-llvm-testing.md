# Generalità test infrastructure di llvm

LLVM ha due tipologie di test principale: 

- regression test (in /test)
- unit test (in /unittests)

*llvm-lit* è il test runner di llvm, permette di lanciare sia unit test che regression test **dalla directory di build**

- lo script python di configurazione è dentro a build/test/
- `bin/llvm-lit --show-suites test`
    - permette di vedere le due suite (regressione e unit)
- `bin/llvm-lit --show-tests test`
    - permette di vedere tutti i test visibili E IL LORO PATH

**Il path di un test** è qualcosa di questo tipo:

- `LLVM-Unit :: TargetParser/./TargetParserTests/9/12`
    - prima dei :: abbiamo la suite
    - poi abbiamo il path fisico dentro a test/ unittests/ fino a /./
    - e poi non so bene cosa

# Comandi/build target utili:

- lancia tutti i test
    - `ninja check-all` oppure `bin/llvm-lit -sv test`
    
- lancia target più granulari
    - `ninja check-llvm` oppure `ninja check-clang` ...
        - regression test di un sottosistema
    - `ninja check-llvm-unit`
        - unit test di un sottosistema

- lancia i test filtrando per nome
    - --filter REGEX
        - Only run tests with paths matching the given regular expression
    - --filter-out REGEX
        - Filter out tests with paths matching the given regular expression
    - --filter-failed
        - **only run tests which failed in the previous run**
    - e.g. `bin/llvm-lit -sv --filter "TargetParser" test`

- **quando si modifica un unit test bisogna ricompilare**
    - `ninja && bin/llvm-lit -sv --filter "TargetParser" test`
