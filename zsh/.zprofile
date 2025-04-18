#>>> Homebrew initialization
eval "$(/opt/homebrew/bin/brew shellenv)"

#>>> Setting PATH for Python 3.12
# The original version is saved in .zprofile.pysave
export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:${PATH}"

#>>> gcc and g++ PATH
export PATH="/opt/homebrew/bin:$PATH"

#>>> dart
export PATH="/opt/homebrew/bin/dart:$PATH"

#>>> flutter sdk
export PATH=$HOME/development/flutter/bin:$PATH

#>>> go setup
export GOROOT=/usr/local/go
export GOPATH=$HOME/Documents/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

#>>> MySQL PATH
export PATH="/usr/local/mysql/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql/bin:$PATH"

#>>> Maven PATH
export PATH="/usr/local/opt/maven/bin:$PATH"

#>>> .NET SDK PATH
export PATH="/Users/your_username/.vscode-dotnet-sdk/.dotnet:$PATH"

#>>> JavaFX library path
export JAVAFX_PATH="/Users/your_username/javafx-sdk-22.0.2/lib"

#>>> DYLD Library Paths
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/lib
#export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/Users/your_username/Desktop/CS50/C/libcs50-11.0.2/build/lib

#>>> Homebrew PATH
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt:$PATH"

#>>> NVM (Node Version Manager) setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

#>>> Java JDK setup for Temurin-21
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home/bin:$PATH"

#>>> Miniconda Initialization
__conda_setup="$('/Users/your_username/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/your_username/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/your_username/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/your_username/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

#>>> Added by Toolbox App
export PATH="$PATH:/usr/local/bin"

#>>> n version manager for npm
export N_PREFIX=$HOME/.n
export PATH=$N_PREFIX/bin:$PATH
