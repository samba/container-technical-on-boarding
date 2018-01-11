# Setting Up Go

This tutorial targets MacOS, and summarizes the [official guide][1].

## Setting Up Your Paths

Go likes to work within a standardized path in your home directory. 

```shell
mkdir -p ${HOME}/go/{src,bin,pkg}
```

Append these lines to your `${HOME}/.bash_profile`:

```shell
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

## Setting Up The Tools 

First, [install Homebrew](https://brew.sh/). 

Then install Go:

```shell
brew install go
```

And install some development tools:

```shell
go get golang.org/x/tools/cmd/godoc
go get github.com/golang/lint/golint
go get golang.org/x/tools/cmd/goimports
go get honnef.co/go/tools/cmd/gosimple
```

**Note** If these don't work, you may not have setup your `$GOPATH` correctly.
Please verify that this command produces a valid path, and that the path exists:

```shell
go env GOPATH
```

## Checking Out Projects

Go expects projects to be namespaced within `$GOPATH`. 
See [Import Paths in the official guide][2].

To check out this project, you'd do like so:

```shell
mkdir -p ${GOPATH}/src/github.com/samsung-cnct/
cd ${GOPATH}/src/github.com/samsung-cnct/
git clone git@github.com:samsung-cnct/technical-on-boarding.git ./technical-on-boarding
```


[1]: https://golang.org/doc/code.html
[2]: https://golang.org/doc/code.html#ImportPaths
