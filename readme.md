# Modularized $profile
A cleaner approach of hard-to-mantain [$profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles) monolith. Modularization provides better isolation when testing.


## How should my $profile look like?
It should look like:
```
. /path/to/repo/main.ps1
```
So that all functions can be loaded to the current scope.

To import a single module:
```
. /path/to/repo/modules/module-name/module-name.psd1
```
#### Note
When working in a IDLE or text editor where a PowerShell session is invoked (e.g. VS Code), you might want to disable $profile. Instructions to disable $profile For VS Code can be found [here](https://stackoverflow.com/a/72427464/29272030).


## TODO
- Hide icons from desktop programmatiaclly?
- Have a config.json monolith that carries all configurations.
- Provide style for `remindme`.
- Provide style for Open-YouTubeVideos (.css).
- Provide time parsing support in `remindme`.
- check 2fa: C:\Program Files\WindowsApps\38343JanPhilippWeber.2fastTwoFactorAuthenticat
              orSu_1.5.1.0_x64__nxr4mypqfqb9c\Project2FA.UWP.exe
- Check https://github.com/lexiforest/curl_cffi for parsing youtube.


## Configurations.
* sensitive.psm1: Powershell Module where sensitive data is passed. To check an example, consult [sensitive-example.psm1](./configs/sensitive-example.psm1)
* variables.psm1: Non-sensitive variables that can be safely exposed to public.
* Some files have their own default configurations, will work on a properly exposed config.json. 

## Shout-out to ...
- https://gist.github.com/bobby-tablez/4b5f1ee02c68a93dc8312c4ff858c0a7
- https://github.com/fleschutz/PowerShell/blob/main/scripts/set-wallpaper.ps1
