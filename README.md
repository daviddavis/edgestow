# Edgestow

GitHub issues over FUSE.

## Building

You will need to
[install opam](http://opam.ocamlpro.com/doc/Quick_Install.html) and
OCaml 4.x to be able to build Edgestow. You'll also need `libfuse-dev`.

If you're not sure whether you have 4.x installed or not, you can check with:

    $ opam switch list
    # If your system compiler is 4.x or above, you're ready to go.
    # Otherwise, issue the following command:
    $ opam switch 4.01.0

To build, run the following commands:

    $ opam install ocamlfind core github # ocamlfuse
    $ ocamlbuild -use-ocamlfind edgestow.byte

## Usage

```shell
$ edgestow mount technomancy/leiningen issues/
$ ls issues # shows you all milestones
2.3.4/	3.0.0/	closed/	no-milestone/
$ cd issues/2.3.4
$ ls
1337/	1328/	1320/	1317/	1198/	closed/
$ cat 1320/info
Special characters in clojars password causes deploy to fail
opened 2013-09-09 by wokier
tags: bug, upstream

I have experienced some trouble for my first clojars deploy because
'lein deploy clojars' prompt for username and password, and then gpg
passord twice, but finally fail during the deploy with a 401 error.

Could not transfer artifact org.clojars.wokier:lein-bower:jar:0.1.0
from/to clojars (https://clojars.org/repo/): Failed to transfer file:
https://clojars.org/repo/org/clojars/wokier/lein-bower/0.1.0/lein-bower-0.1.0.jar. Return
code is: 401, ReasonPhrase: Unauthorized.

It worked after i have removed special characters (french accents)
from the password.
$ cat 1320/comments/*
posted 2013-10-30 by hypirion

I've been playing around with the Leiningen parts, and I've verified
that the password read in from the console is the correct one.

The error is definitely upstream somewhere, but it's hard to pinpoint
exactly where the error happens. It may be in some Apache library
sending the request, or at the Clojar end where the locale is either
wrong or ignored.
```

Issue files are sorted into directories by milestone, then by issue
number. Closed issues and milestones are kept in a special `closed/`
directory.

Each issue has an `info` file and a `comments` directory. The `info`
file has a few lines of metadata followed by the description. Comments
may be listed and shown, and saving a new file to the comments
directory will post it. Moving an issue to the `closed/` directory
closes it, while moving it to another milestone reassigns it.
