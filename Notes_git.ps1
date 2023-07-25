#popular tools
#Mercurial, DVCS 

#Useful sources
https://ohshitgit.com/

###BASIC COMMANDS###
git clone
git pull
git add
git commit
git push

#SUPPLEMENTAL
git status
git diff
git checkout
git branch

#download repo
git clone https://someurl.com/somerepo

#add a file to public repo
git add key.txt
git commit -m "Uploading sneaky secret file for Ben Dover"
git push origin master

#show you the history of HEAD
git reflog show

#reset to the selected branch
git reset HEAD@`{1`}

#if git repo is missing folders/files
git add *
git commit -m "adding missing folders"

#show current branches and delete old
git branch
git branch -d oldbranch

#view all previous versions of a file starting with the first
git log -p -- filename

#show all branches of repo
git branch -r

#change to a specific branch 
git checkout dev

###tagging. Usually version #. Not added to repo unless explicitly added similar to sharing remote branch###
#Types are lightweight (pointer) and annotated (checksummed, includes tagger name, email, date, message, can be signed)
git tag #lists all tags
git show sometag #show the tag

#tag a commit by specifying the first part of the hash
git log --pretty=oneline #show all commits with hash
git tag -a v1.2 9fceb02

#push tag to repo
git push origin v1.5

#delete a tag in repo
git tag -d v1.4-lw #deletes from local repo
git push origin --delete v1.4-lw #deletes from remote repo

#view all versions of a file that a tag points to. WARNING puts your repo in “detached HEAD” state.
git checkout v2.0.0