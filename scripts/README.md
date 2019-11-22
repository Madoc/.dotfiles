Those scripts are called on every shell start.
They define certain functions, which get called in a certain sequence.

# Startup sequence

Please note that the scripts contained in this directory should _not directly_ do the initialization.
Instead, they define certain functions, which then get called in the correct order.

Actually, every script may be run several times over, so it might be harmful to do some initialization outside of those
 functions.

The scripts will be `source`d, so no explicit exporting of global variables is required.

## Startup functions

Here is the list of functions that those scripts may define, all optional:

| Function | Called when | Purpose |
| --- | --- | --- |
| `init_env` | First on every shell start. | Initialize environment variables, for all shell types. |
| `init_env_other` | After `init_env`, if the shell type is not Zsh. | Initialize variables, only for shells other than Zsh. |
| `init_env_zsh` | After `init_env`, if the shell type is Zsh. | Initialize variables, only for Zsh. |
| `init_rc` | After all applicable `init_env*` functions, on every shell start. | Run commands for initialization, after the environment is set up. |
| `init_rc_other` | After `init_rc`, if the shell type is not Zsh. | Run commands for initialization, only for shells other than Zsh. |
| `init_rc_zsh` | After `init_rc`, if the shell type is Zsh. | Run commands for initialization, only for Zsh. |
| `init_post_rc`, `init_post_rc_other`, `init_post_rc_zsh` | After all applicable `init_rc*` scripts. | Run commands for initialization that require the other `rc` commands to have run first. |

So there are three phases in total:
* `env` for environment initialization.
* `rc` for initialization scripts.
* `post_rc` for initialization scripts that run after the other initialization scripts.

For each of those phases, three optional functions can be defined:
* `init_${phase}`: gets called every time.
* `init_${phase}_other`: only for shells that are not Zsh.
* `init_${phase}_zsh`: only for Zsh.

Since all of the scripts define functions with the same names, one might wonder if they do not overwrite each other's
 function definitions.
However, the common [`shell-start-setup` script](../util/shell-start-setup) takes care of that:
It runs all of the scripts, and for each script first calls the applicable functions, then unsets those functions.

# Intended use

As mentioned before, the main body of the initialization scripts should not run any initalization at top level.
They should define the functions mentioned above, and do the initializations in those functions.

The `init_env*` functions should only initialize environment variables.
`init_rc*` run commands for initialization, potentially relying on the previously defined environment variables.
`init_post_rc*` runs after that, running commands that rely on previously run commands.

## Antipatterns

Here are some things that the initialization scripts should _not_ do:

* They should _not_ run initialization code directly on top level.
* They should _not_ define any functions other than the `init_*` functions described above.
  Global functions can be defined within the body of one of the initialization functions, like so:
  
  ```bash
  init_rc() {
    my_global_function() {
      # ...
    }
  }
  ```
  
  In the example above, `my_global_function` will be globally available after shell startup.
* They should _not_ call each other, as they will get undefined some time after they have been run.
