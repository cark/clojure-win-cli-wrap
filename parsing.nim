# module parsing
import strutils

type GetParamStringParseState = enum
    gpsParsing, gpsInDblQuotes, gpsGotExe

# Removes the executable file name from a full command line,
# taking care of executable names in double quotes
proc getParamString*(cmdLine :string) : string {.noSideEffect.} =
    let text = cmdLine.strip()
    var i = 0
    var stringLength = text.len()
    var state = gpsParsing;
    while i < stringLength :
        case state :
            of gpsParsing : 
                case text[i] :
                    of '"' : state = gpsInDblQuotes
                    of ' ' : state = gpsGotExe
                    else : discard
            of gpsInDblQuotes : 
                case text[i] :
                    of '"' : state = gpsGotExe
                    else: discard
            of gpsGotExe : break
        i += 1
    return text[i..stringLength - 1].strip()

# a simple command line
# clojure.exe -i main.clj -m main -C:dev

# One of a few cases : we need to transform this
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

type fixEscapingState = enum
    feParsing, feInDblQuotes, feInQuotes, feDblQuotesBackSlashing, feQuotesBackSlashing

proc fixEscaping* (cmdLine : string) : string {.noSideEffect.} = 
    let text = cmdLine.strip()
    var i = 0
    var stringLength = len(text)
    var state = feParsing
    result = ""
    while i < stringLength :
        let c = text[i]
        case state :
            of feParsing : 
                case c :
                    of '\'' : 
                        result.add(c)
                        state = feInQuotes
                    of '"' :
                        result.add(c)
                        state = feInDblQuotes
                    else : result.add(c)
            of feInDblQuotes :
                case c :
                    of '\\' :
                        result.add(c)
                        state = feDblQuotesBackSlashing
                    of '"' :
                        result.add(c)
                        state = feParsing
                    else : result.add(c)
            of feDblQuotesBackSlashing :
                case c :
                    of '"' : 
                        result.add('"')
                        result.add('"')
                        state = feInDblQuotes
                    else : 
                        result.add(c)
                        state = feInDblQuotes
            of feInQuotes :
                case c :
                    of '\'' :
                        result.add(c)
                        state = feParsing
                    of '"' :
                        result.add('\\')
                        result.add(c)                        
                    of '\\' :
                        result.add(c)
                        state = feQuotesBackSlashing
                    else : result.add(c)
            of feQuotesBackSlashing :
                result.add(c)
                state = feInQuotes
        i += 1
