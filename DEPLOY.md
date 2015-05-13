# Deploying
The `Makefile` (yes, `Makefile`) has a series of commands to simplify the development and deployment process.

## `make`

Running `make` by itself will show you a list of available sub-commands.

```bash
$ make
all
docs
gem
install
pushdocs
pushgem
tag
test
version
```

## `make pushdocs`
You will need to have write-access to the `wepay/Ruby-SDK` repository on GitHub. You should have already set up:

* Your SSH key with your GitHub account.
* Had your GitHub user given write-access to the repository.

Then you can run:

```bash
make pushdocs
```

You can view your changes at <https://wepay.github.io/Ruby-SDK/>.

## `make pushgem`
You will need to have pulled-down the proper gem credentials first. When prompted, enter your
[RubyGems](http://rubygems.org) password.

Login and view your [RubyGems profile page](https://rubygems.org/profile/edit) to see the proper command.

Then you can run:

```bash
make pushgem
```

If you need to [add an additional gem owner](https://stackoverflow.com/questions/8487218/how-to-add-more-owners-to-a-gem-in-rubygem):

```bash
gem owner wepay -a api@wepay.com
```

You can view your changes at <https://rubygems.org/gems/wepay>.

## `make tag`
You will need to have a [Keybase](https://keybase.io) account first, including setting-up the
[`keybase` CLI tool](https://keybase.io/docs/command_line/prerequisites).

Then you can run:

```bash
make tag
```

You can view your changes in the `SIGNED.md` file.
