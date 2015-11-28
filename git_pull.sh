#!/bin/sh
#
# author: yanue
# time: 2015-11-28
# git pull tool
# when project has untracked and local change files
# usage:
#  gpl [project path]

tmp_file='/tmp/git_pull_error';
git='/usr/local/bin/git';

if [ $# -gt 0 ] ;then
        cd $1;
        if [ $? != 0 ]; then
                echo $1 ': path not found';
                exit 0;
        fi
else
        cd ${PWD};
fi

if [ ! -d ".git" ]; then
        echo 'this is not a git project path';
        exit 0;
fi

pwd;
# git pull once
$git pull 2> $tmp_file;

# if has errors
if [ $? != 0 ]; then
        # delete untracked and local change files
        # --all those files each have an epmty space char
        cat $tmp_file | sed -n '/^\s/p' | awk '{print $1}' | xargs rm -f
        # git pull again
        $git pull;
        # set tmp file to empty
        cat /dev/null > $tmp_file;
fi

# addon options
chmod -R 777 data cache uploads avatar
chown -R www.www .

# end
echo 'done'
