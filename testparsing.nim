from parsing import fixEscaping, getParamString
import unittest

suite "fixEscaping":
    test "cider command line":
        check(fixEscaping("""clojure -Sdeps '{:deps {nrepl {:mvn/version \"0.6.0\"} refactor-nrepl {:mvn/version \"2.5.0-SNAPSHOT\"} cider/cider-nrepl {:mvn/version \"0.22.0-beta4\"}}}' -m nrepl.cmdline --middleware '[\"refactor-nrepl.middleware/wrap-refactor\", \"cider.nrepl/cider-middleware\"]'""") ==
            """clojure -Sdeps '{:deps {nrepl {:mvn/version \"0.6.0\"} refactor-nrepl {:mvn/version \"2.5.0-SNAPSHOT\"} cider/cider-nrepl {:mvn/version \"0.22.0-beta4\"}}}' -m nrepl.cmdline --middleware '[\"refactor-nrepl.middleware/wrap-refactor\", \"cider.nrepl/cider-middleware\"]'""")
    test "cider command line 2":
        check(fixEscaping("""clojure -Sdeps '{:deps {nrepl {:mvn/version "0.6.0"} refactor-nrepl {:mvn/version "2.5.0-SNAPSHOT"} cider/cider-nrepl {:mvn/version "0.22.0-beta4"}}}' -m nrepl.cmdline --middleware '["refactor-nrepl.middleware/wrap-refactor", "cider.nrepl/cider-middleware"]'""") ==
            """clojure -Sdeps '{:deps {nrepl {:mvn/version \"0.6.0\"} refactor-nrepl {:mvn/version \"2.5.0-SNAPSHOT\"} cider/cider-nrepl {:mvn/version \"0.22.0-beta4\"}}}' -m nrepl.cmdline --middleware '[\"refactor-nrepl.middleware/wrap-refactor\", \"cider.nrepl/cider-middleware\"]'""")
    test "shadow-cljs command line":
        check(fixEscaping("""clojure -Sdeps "{:aliases {:shadow-cljs-inject {:extra-deps {thheller/shadow-cljs {:mvn/version \"2.8.28\"}}}}}" -A:dev:example:shadow-cljs-inject -m shadow.cljs.devtools.cli --npm""") ==
        """clojure -Sdeps "{:aliases {:shadow-cljs-inject {:extra-deps {thheller/shadow-cljs {:mvn/version \""2.8.28\""}}}}}" -A:dev:example:shadow-cljs-inject -m shadow.cljs.devtools.cli --npm""")
    test "no parameters":
        check(fixEscaping("clojure")=="clojure")
    test "empty string":
        check(fixEscaping("") == "")
    
suite "getParamString":
    test "just the exe":
        check(getParamString("clojure.exe") == "")
    test "the exe and some parameters":
        check(getParamString("clojure.exe some params") == "some params")
    test "the exe and some double quoted parameters":
        check(getParamString("clojure.exe \"some params\"") == "\"some params\"")
    test "the exe has spaces in it":
        check(getParamString("\"c:\\program files\\bleh\\clojure.exe\"") == "")
    test "the exe has spaces in it + params":
        check(getParamString("\"c:\\program files\\bleh\\clojure.exe\" some params") == "some params")