# GIT

## Ignore File Sections

I would like to be able to ignore sections of files to that I can have inline working notes that don't get
committed. I think this would be useful when tracking tasks and time within source files.

https://stackoverflow.com/questions/16244969/how-to-tell-git-to-ignore-individual-lines-i-e-gitignore-for-specific-lines-of

## See Also

[Sparse Repository](https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository/52269934#52269934)

[check if dirty](https://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommitted-changes)

[convert to shallow](https://stackoverflow.com/questions/4698759/converting-git-repository-to-shallow)

[vcs history editor](http://www.catb.org/esr/reposurgeon/)

## Tips

Create branch without history:
`git checkout --orphan`

Reuse commit message after reset:
`git commit -C @@{1}`
or
`git commit -C HEAD@{1}`
or
`git commit --reuse-message=HEAD@{1}`
or
`git commit --reuse-message=ORIG_HEAD`
See https://stackoverflow.com/questions/16858069/git-how-to-reuse-retain-commit-messages-after-git-reset
