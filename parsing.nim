
# module parsing
import strutils

# Removes the executable file name from a full command line,
# taking care of executable names in double quotes
proc getParamString*(cmdLine :string) : string {.noSideEffect.} =
    var i = 0
    var l = len(cmdLine)
    var inDblQuotes = false
    var gotExeName = false
    while  i < l :
        case cmdLine[i] :
            of '"' : 
                if gotExeName :
                    break
                else:
                    if inDblQuotes :
                        gotExeName = true
                    else:
                        inDblQuotes = true
            of ' ' :                
                if not inDblQuotes :
                    gotExeName = true                    
            else: 
                if gotExeName :
                    break
        i += 1
    return cmdLine[i..len(cmdLine)-1].strip();

# a simple command line
# clojure.exe -i main.clj -m main -C:dev

# One of two cases : we need to transform this
# clojure -Sdeps "{:aliases {:shadow-cljs-inject {:extra-deps {thheller/shadow-cljs {:mvn/version \"2.8.28\"}}}}}" -A:dev:example:shadow-cljs-inject -m shadow.cljs.devtools.cli --npm
# to this
# clojure -Sdeps "{:aliases {:shadow-cljs-inject {:extra-deps {thheller/shadow-cljs {:mvn/version \""2.8.28\""}}}}}" -A:dev:example:shadow-cljs-inject -m shadow.cljs.devtools.cli --npm

# second case
# clojure -Sdeps '{:deps {nrepl {:mvn/version \"0.6.0\"} refactor-nrepl {:mvn/version \"2.5.0-SNAPSHOT\"} cider/cider-nrepl {:mvn/version \"0.22.0-beta4\"}}}' -m nrepl.cmdline --middleware '[\"refactor-nrepl.middleware/wrap-refactor\", \"cider.nrepl/cider-middleware\"]'
# should stay the same

# third case
# clojure -Sdeps '{:deps {nrepl {:mvn/version "0.6.0"} refactor-nrepl {:mvn/version "2.5.0-SNAPSHOT"} cider/cider-nrepl {:mvn/version "0.22.0-beta4"}}}' -m nrepl.cmdline --middleware '["refactor-nrepl.middleware/wrap-refactor", "cider.nrepl/cider-middleware"]'
# to this :
# clojure -Sdeps '{:deps {nrepl {:mvn/version \"0.6.0\"} refactor-nrepl {:mvn/version \"2.5.0-SNAPSHOT\"} cider/cider-nrepl {:mvn/version \"0.22.0-beta4\"}}}' -m nrepl.cmdline --middleware '[\"refactor-nrepl.middleware/wrap-refactor\", \"cider.nrepl/cider-middleware\"]'
proc fixEscaping* (text : string) : string {.noSideEffect.} = 
    var i = 0
    var l = len(text)
    var inDblQuotes = false
    var backSlashing = false
    var inQuotes = false
    result = ""
    while i < l :
        var c = text[i]
        case c :
            of '\'' :
                add(result, '\'')
                if not inDblQuotes :
                    inQuotes = not inQuotes
            of '"' :
                if backSlashing :
                    if inDblQuotes:
                        add(result, '"')
                        add(result, '"')
                        backSlashing = false
                    else:
                        add(result, '"')
                        backSlashing = false
                elif inQuotes :
                    add(result, '\\')
                    add(result, '"')
                elif inDblQuotes :
                    add(result, '"')
                    inDblQuotes = false
                else:
                    add(result, '"')
                    inDblQuotes = true
            of '\\' :
                add(result, '\\')
                backSlashing = true
            else :
                result.add(c)
        i += 1
