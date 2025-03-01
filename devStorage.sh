#! /bin/bash

$(which echo) "What would you like to do?"

$(which echo) "1 - View mounted file system statistics."
$(which echo) "2 - Watch mounted file system statistics."
$(which echo) "3 - See size of specified directory (recursive)."
$(which echo) "4 - See summarized size of specified directory(ies)."
$(which echo) "5 - Interacively view disk space of specified directory."

read devstorageCommand;

case $devstorageCommand in
    1) $(which df) -hTx tmpfs;;
    2) $(which watch) $(which df) -hTx tmpfs;;
    3) $(which echo) "Insert directory path:"
       read duPath;
       $(which echo) "How deep? (recursive)"
       read depth;
       sudo $(which du) -h --max-depth $depth $duPath;;
    4) $(which echo) "Insert directory path(s) (separate multiple paths with a single space):"
       read duPaths;
       sudo $(which du) -hsc $duPaths;;
    5) $(which echo) "Insert directory:"
       read ncduPath;
       sudo $(which ncdu) $ncduPath
esac