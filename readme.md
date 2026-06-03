# Modularized $PROFILE
A cleaner approach to my old $PROFILE monolith. Modularization provides better isolation when coding and testing.

## How should my $PROFILE look like?
It should look like:
```
. /path/to/repo/main.ps1
```
So that all functions can be loaded to the current scope.

To import a single module:
```
. /path/to/repo/modules/module-name/module-name.psd1
```


## TODO
- Have a config.json monolith that carries all configurations.
- Provide style for `remindme`.
- Implemente "Has-Internet" function.
- Provide style for Open-YouTubeVideos (.css).

## Configurations.
* sensitive.psm1: Powershell Module where sensitive data is passed. To check an example, consult [sensitive-example.psm1](./configs/sensitive-example.psm1)
* variables.psm1: Non-sensitive variables that can be safely exposed to public.
* Some files have their own default configurations, working on a properly exposed config.json. 

## Thanks to...
- https://gist.github.com/bobby-tablez/4b5f1ee02c68a93dc8312c4ff858c0a7
