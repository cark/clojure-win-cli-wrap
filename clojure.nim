import winlean
import osproc
import base64
import encodings
from parsing import fixEscaping, getParamString

# returns the full command line as a Nim string
# I think it's UTF-8 due to the $ call on a wide string
proc getCommandLine():string =
    return $(winlean.getCommandLineW())

# we're using the actual cmdlet name rather than the aliases
# in order to prevent recursively calling our exe when it's in the path
const cmdlet : string = "Invoke-Clojure" 

# prepends the cmdlet name to a paramString.
proc prepareCommand(paramString : string) : string {.noSideEffect.} =    
    return if paramString == "" :
        cmdlet
    else:
        cmdlet & " " & paramString

# launches powershell with the command encoded to base64 in order to avoid any more 
# escaping shenanigans than we already have
proc launch(command : string) : void = 
    # probably might want to verify what encoding we're starting with
    # Though my understanding is that we're UTF-8 due to converting the string using $
    var utf16Command = convert(command, "UTF-16", "UTF-8") 
    var encodedCommand = base64.encode(utf16Command)
    var process = startProcess("powershell", "", ["-EncodedCommand", encodedCommand], nil, {poUsePath, poParentStreams, poInteractive}) 
    var exitCode = waitForExit(process)
    close(process)
    quit(exitCode)

getCommandLine().getParamString().prepareCommand().fixEscaping().launch()
