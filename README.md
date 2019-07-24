# clojure-win-cli-wrap
A wrapper around the powershell clojure cli
## What is it ?
This is intended to alleviate the pains of using the clojure cli tools from the regular Windows command line. We aim at providing
an experience as close as possible to the unix cli user experience, but we do not aim at supporting the very recent powershell cli, this remains available by launching powershell and using the existing tools.
The provided Nim source can be compiled to a clojure.exe and clj.exe files that will call the Invoke-Clojure command provided by Cognitect. My goal is to have this, or something like it included in the official windows distribution of clojure.

## Status
This alpha version accepts a couple quotation and escaping styles, and translates these to something that works.
Right now, I focused on making shadow-cljs and cider work, I also tested some other command lines, but i'm not a clojure cli expert ! So I'm counting on the community to bring me some error cases.

Some examples of pretty hairy command lines that do work :
```
clojure -Sdeps '{:deps {nrepl {:mvn/version "0.6.0"} refactor-nrepl {:mvn/version "2.5.0-SNAPSHOT"} cider/cider-nrepl {:mvn/version "0.22.0-beta4"}}}' -m nrepl.cmdline --middleware '["refactor-nrepl.middleware/wrap-refactor", "cider.nrepl/cider-middleware"]'
```

```
clojure -Sdeps "{:aliases {:shadow-cljs-inject {:extra-deps {thheller/shadow-cljs {:mvn/version \"2.8.28\"}}}}}" -A:dev:example:shadow-cljs-inject -m shadow.cljs.devtools.cli --npm
```

[TDEPS-133](https://clojure.atlassian.net/projects/TDEPS/issues/TDEPS-133)
```
clj -Sdeps '{:deps {viebel/klipse-repl {:mvn/version "0.2.3"}}}' -m klipse-repl.main
```
## Language choice
This project uses the Nim programming language, version 0.19.0. I'm certainly not dead set on this language, but I find it easy to write and read. It produces small, stand alone, garbage collected binary files. This program is tiny, so there is no issue with rewriting it in any language.
## Testing
The test.cmd file tests the parsing/escaping routines
## Compiling
Run the compile.cmd file to test, then produce both executables. 
## What's this base64 thing in the code?
In order to avoid encountering more quotes/doublequotes escaping issues, we're using the -EncodedCommand of powershell. This takes a base64 encoded command. The downside is that this may trigger some anti-virus softwares (though this wasn't reported to me yet).
## License
Copyright (c) Sacha De Vos and contributors. All rights reserved.

The use and distribution terms for this software are covered by the Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php) which can be found in the file LICENSE.html at the root of this distribution. By using this software in any fashion, you are agreeing to be bound by the terms of this license. You must not remove this notice, or any other, from this software.

