# Post-push CI poll

After pushing to `main`, poll required GitHub workflows:

```powershell
.\scripts\check-github-ci.ps1 -WaitSeconds 300
```

Required rollups: **CI**, **Security Scan**, **CodeQL**. CI jobs **Repo Hygiene** and **Feature Gate** run inside the CI workflow.

Do not tag a release while any required check is failing.

Begin now.
