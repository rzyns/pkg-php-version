![][license-badge]

<div align="center">
  <a href="http://github.com/oh-my-fish/oh-my-fish">
  <img width=90px  src="https://cloud.githubusercontent.com/assets/8317250/8510172/f006f0a4-230f-11e5-98b6-5c2e3c87088f.png">
  </a>
</div>
<br>

# php-version

Provides PHP version switching functionaility as an Oh My Fish plugin. It's pretty much a line-for-line port of Wil Moore's excellent php-version for bash and zsh, https://raw.githubusercontent.com/wilmoore/php-version

## Install

```fish
$ omf install php-version
```


## Usage

```fish
 Usage:
    php-version --help     Show this message
    php-version --version  Print the version
    php-version <version>  Modify PATH to use <version>
    php-version            Show all available versions and denote the currently activated version

  Example:
    php-version 5          Activate the latest available 5.x version
    php-version 5.5        Activate the latest available 5.5.x version
    php-version 5.5.13     Activate version 5.5.13 specifically

```

## Usage Examples

### Switch to a specific PHP version

    % php-version <version>

### List installed and active (*) PHP version(s)

    % php-version
      5.3.9
      5.3.10
      5.4.0RC8
      5.4.0RC6
      5.4.0
    * 5.4.8



# License

[MIT][mit] © [rzyns][author] et [al][contributors]


[mit]:            http://opensource.org/licenses/MIT
[author]:         http://github.com/rzyns
[contributors]:   https://github.com/rzyns/pkg-php-version/graphs/contributors
[omf-link]:       https://www.github.com/oh-my-fish/oh-my-fish

[license-badge]:  https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square
