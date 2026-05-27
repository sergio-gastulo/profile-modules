# Modularized $PROFILE
A cleaner approach to my old $PROFILE monolith. Modularization provides better isolation when coding and testing.

## TODO
- Fix reminder.

### Configurations.
* sensitive.psm1: Powershell Module where sensitive data is passed. To check an example, consult [sensitive-example.psm1](./configs/sensitive-example.psm1)
* variables.psm1: Non-sensitive variables that can be safely exposed to public.

## Thanks to...
- https://gist.github.com/bobby-tablez/4b5f1ee02c68a93dc8312c4ff858c0a7