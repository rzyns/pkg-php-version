# SYNOPSIS
#   php-version [options]
#
#   Based on the excellent php-version bash and zsh scripts by Wil Moore:
#     https://github.com/wilmoore/php-version#setup
#
# USAGE
#    php-version --help     Show this message
#    php-version --version  Print the version
#    php-version <version>  Modify PATH to use <version>
#    php-version            Show all available versions and denote the currently activated version
#
#  Example:
#    php-version 5          Activate the latest available 5.x version
#    php-version 5.5        Activate the latest available 5.5.x version
#    php-version 5.5.13     Activate version 5.5.13 specifically
#

function php-version --description 'function allowing one to switch between PHP versions'
  set PROGRAM_APPNAME 'php-version'
  set PROGRAM_VERSION 0.1.0
  set PROGRAM_DISPLAY_VERSION "$PROGRAM_APPNAME v$PROGRAM_VERSION"

  # colors
  set COLOR_NORMAL (tput sgr0)
  set COLOR_REVERSE (tput smso)

  function php-version.help
    set -l PROGRAM_APPNAME $argv[1]
    echo "\
      Usage:
        $PROGRAM_APPNAME --help     Show this message
        $PROGRAM_APPNAME --version  Print the version
        $PROGRAM_APPNAME <version>  Modify PATH to use <version>
        $PROGRAM_APPNAME            Show all available versions and denote the currently activated version

      Example:
        $PROGRAM_APPNAME 5          Activate the latest available 5.x version
        $PROGRAM_APPNAME 5.5        Activate the latest available 5.5.x version
        $PROGRAM_APPNAME 5.5.13     Activate version 5.5.13 specifically

      Configuration Options:
        https://github.com/wilmoore/php-version#setup

      Uninstall:
        https://github.com/wilmoore/php-version#deactivate--uninstall

    "
  end

  function php-version.current_php_version
    echo (echo (php-config --version 2>/dev/null) | tr -d '[[:space:]]')
  end

  # target version
  set -l _TARGET_VERSION $argv[1]

  # PHP installation paths
  set -l _PHP_VERSIONS ""

  # add ~/.phps if it exists (default)
  if test -d $HOME/.phps
    set _PHP_VERSIONS $_PHP_VERSIONS $HOME/.phps
  end

  # add default Homebrew directories if brew is installed
  if test -n (command -v brew)
    set _PHP_VERSIONS (find (brew --cellar) -maxdepth 1 -type d | grep -E 'php[0-9]*$')
  end

  # add extra directories if configured
  if test -n $PHP_VERSIONS
    set _PHP_VERSIONS $_PHP_VERSIONS $PHP_VERSIONS
  end

  for _PHP_VERSION in $_PHP_VERSIONS
    set _PHP_REPOSITORIES $_PHP_REPOSITORIES $_PHP_VERSION
  end

  if test -n "$argv[1]"
    if printf $argv[1] | grep -q -E '^-(h|-help|u|-usage)$'
      php-version.help $PROGRAM_APPNAME
      return 0
    else if printf $argv[1] | grep -q -E '^-(v|-version)$'
      echo $PROGRAM_DISPLAY_VERSION

      return 0
    else if printf $argv[1] | grep -q -E '^-.*$'
      printf "\e[0;31m%s: %s: unrecognized option\e[0m\n\n" (basename (status -f)) $argv[1] >&2
      php-version --help >&2

      return 1
    end
  else
    # bail-out if _PHP_REPOSITORIES is an empty array
    if test (count $_PHP_REPOSITORIES) -eq 0
      echo 'Sorry, but you do not seem to have any PHP versions installed.' >&2
      echo 'See https://github.com/wilmoore/php-version#install for assistance.' >&2
      return 1
    end

    # Loop through all repositories and get every single php-version
    set -e _PHP_VERSIONS
    for _PHP_REPOSITORY in $_PHP_REPOSITORIES
      for _dir in (find (echo $_PHP_REPOSITORY) -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
        set _PHP_VERSIONS $_PHP_VERSIONS (eval "$_dir/bin/php-config" --version 2>/dev/null)
      end
    end

    # for _PHP_VERSION in (echo $_PHP_VERSIONS | tr '[[:space:]]' "\n" | sort | uniq | sort -r -t . -k 1,1n -k 2,2n -k 3,3n)
    #   set _PHP_VERSIONS $_PHP_VERSIONS $_PHP_VERSION
    # end

    for _PHP_VERSION in $_PHP_VERSIONS
      set _PHP_VERSION (echo $_PHP_VERSION | tr -d '[[:space:]]')

      set -l selected " "
      set -l color $COLOR_NORMAL

      if test "$_PHP_VERSION" = (php-version.current_php_version)
        set selected "*"
        set color $COLOR_REVERSE
      end

      printf "$color%s %s$COLOR_NORMAL\n" "$selected" "$_PHP_VERSION"
    end

    return 0
  end

  # locate selected PHP version
  set _PHP_ROOT ""
  for _PHP_REPOSITORY in $_PHP_REPOSITORIES
    if test -d "$_PHP_REPOSITORY/$_TARGET_VERSION"  -a -z $_PHP_ROOT
      set _PHP_ROOT "$_PHP_REPOSITORY/$_TARGET_VERSION"
      break
    end
  end

  if test -z $_PHP_ROOT
    for _PHP_REPOSITORY in $_PHP_REPOSITORIES
      for _dir in (find $_PHP_REPOSITORY -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
        set _TARGET_VERSION_FUZZY $_TARGET_VERSION_FUZZY (eval "$_dir/bin/php-config --version 2>/dev/null")
      end
    end

    set _TARGET_VERSION_FUZZY (echo "$_TARGET_VERSION_FUZZY" | tr '[[:space:]]'  \n | sort -r -t . -k 1,1n -k 2,2n -k 3,3n | grep -E "^$_TARGET_VERSION" 2>/dev/null | tail -1)

    for _PHP_REPOSITORY in $_PHP_REPOSITORIES
      for _dir in (find $_PHP_REPOSITORY -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
        set -l _PHP_VERSION (eval "$_dir/bin/php-config --version 2>/dev/null")
        if test -n "$_TARGET_VERSION_FUZZY" -a "$_PHP_VERSION" = "$_TARGET_VERSION_FUZZY"
          set _PHP_ROOT $_dir
        end
      end
    end

    # bail-out if we were unable to find a PHP matching given version
    if test -z "$_PHP_ROOT" 
      echo "Sorry, but $PROGRAM_APPNAME was unable to find version '$argv[1]'." >&2
      return 1
    end

    set -g -x PHPRC ""
    test -f "$_PHP_ROOT/etc/php.ini" ; and set -g -x PHPRC "$_PHP_ROOT/etc/php.ini"
    test -d "$_PHP_ROOT/bin"         ; and set -g -x PATH "$_PHP_ROOT/bin" $PATH
    test -d "$_PHP_ROOT/sbin"        ; and set -g -x PATH "$_PHP_ROOT/sbin" $PATH

    set -l _MANPATH (php-config --man-dir)
    test -z $_MANPATH ; and set _MANPATH "$_PHP_ROOT/share/man"
    test -d $_MANPATH ; and set -g -x MANPATH "$_MANPATH" $MANPATH

  end
end
