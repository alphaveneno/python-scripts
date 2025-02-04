# Python Scripts UPDATE
## 2025_01_19

This repository represents my efforts to update and extend the great work by _carberra_, implementing bash scripts to install and uninstall various versions of python. His original README is found below this preface.

**The salient alterations and additions are:**

1. Scripts for *Redhat*-derived and *Arch*-derived linux distributions are added.

2. It is considered best practice to update your system prior to installing new software. The *upgrade* subcommand for Redhat's *dnf* command includes an update; *dnf* has no separate *update* subcommand. Arch updates and upgrades packages with *pacman -Syu*. To be consistent, the *Debian* install script performs both *update* and *upgrade*, however not *dist-upgrade* and not *full-upgrade*.

3. I left off the installation of *wget* as most distros now either include it automatically or install it with *upgrade*

4. Adjustments are made to some of the original bash language code to enhance robustness. Of note, point 2. above is one example of the subtle bash language differences between *Redhat*, *Arch* and *Debian*

5. Code is added and modified to deal with package changes made by the python developers

6. Code is added and modified to deal with package changes made in the APT (Debian), DNF5 (Redhat) and CORE (Arch) repositories

7. Comments are added and extended in places

8. In line with script security recommendations, many commands are now given as:
$(which *insert your command here*)

9. The verbose output of most commands is diverted from the screen to */dev/null 2>&1*.

10. To speed-up the installation of python, recruitment of all available CPU cores is enforced with *$(nproc)*

11. Universal test scripts are coded to test the results of installation and uninstallation

12. The issues causing some annoying yet benign warnings e.g; "dbm module cannot be installed" have been investigated by me with my appraisal echoed to the screen.

13. The uninstall script now selectively removes python scripts and virtual environments created by the deleted python version. Note: I only tested this with virtual environments created with 'venv'.

14. Description of the testing environments and conditions is found at the top of the scripts

## Notes:

- Using *> /dev/null 2>&1* aggressively removes screen output, as compared to applying the *-q, -qq* or *--quiet* options. You will need to comment this code out to investigate errors.

- I hope I have been able to include all the necessary dependencies for *Redhat*, *Arch* and *Debian*. Any feedback is welcome.

- The python developers seem to have a 'rolling technical debt' approach to deprecation, as a feature is first commented-out with a promise of a more elegant solution in a later distro. This results in a lot of warnings that are usually false alarms. I have done my best to investigate some of the more concerning ones and make adjustments accordingly. I could not eliminate the annoying *build not found* warning.

- These scripts will steadily go stale as changes are made continuously to *python* and to the repositories.

- The test scripts are fairly simple, ensuring the new installation can carry-out some basic python functionality, and that the uninstallation script removes what it is supposed to remove. Any further testing recommendations are welcome and will be considered.

- As of this date, installations of *Debian*-derived distros default to *python 3.11.2*, *Redhat*-derived distros default to *python 3.13.0* and *Arch*-derived distros default to *python 3.13.1*. Release of 3.14 appears to be on the near-horizon.

- As you know, a fresh installation of Linux starts off with a basic PATH variable that is usually a concatenation of the paths of five directories, and may look like this: */usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games*

- For ease-of-use, include bash scripts on your own PATH so that access to them is persistent and available from all directories. It is considered best practice to place these in the **bin** directory at the end of this particular path: **/usr/local/bin**.

- An alternative, described by *carberra* below and also used by me, is to edit the *.bashrc* file in your home directory to add the path of your bash script to the PATH variable.

- This software is unlicensed, presented 'as-is' for free use by anybody, without warranty.


# --------- README.md by carberra, .circa 2022 ---------
# Python Scripts

## Installing the Scripts

1. Clone the repo:
   `git clone https://github.com/parafoxia/python-scripts`
2. Make the scripts executable:
   `chmod +x python-scripts/install-python && chmod +x python-scripts/uninstall-python`
3. Add the scripts to your path by adding the following to your .bashrc/.zshrc/etc.:
   `PATH=$PATH:/path/to/python-scripts`
4. Apply the changes:
   `source .bashrc`

## Installing Python

You can install Python using the following command:

```sh
install-python <ver1> [ver2 ...]
```

This builds and installs Python from sources downloaded from the official FTP server.
While this means you can install any Python version you want, the installation process will take significantly longer.
Alpha, beta, and release candidate versions can also be installed, and multiple version can be installed at once.

For example:

```sh
install-python 3.10.7 3.8.0b2 3.11.0rc1
```

**Note:** If you do not use a Debian-based system, you will need to edit the script to use your distribution's package manager.

## Uninstalling Python

You can uninstall Python using the following command:

```sh
uninstall-python <ver1> [ver2 ...]
```

This removes all files related to the given Python versions.

For example, if you ran the following command...

```sh
uninstall-python 3.9
```

...the following directories and files will be deleted:

* /usr/local/bin/2to3-3.9
* /usr/local/bin/idle3.9
* /usr/local/bin/pip3.9
* /usr/local/bin/pydoc3.9
* /usr/local/bin/python3.9
* /usr/local/bin/python3.9-config
* /usr/local/lib/libpython3.9.a
* /usr/local/lib/python3.9
* /usr/local/lib/python3.9-embed.pc
* /usr/local/lib/python3.9.pc

Like when installing Python, multiple versions can be uninstalled at once.

**Warning:** If you have two installations for a single minor version of Python (i.e. 3.10.1 and 3.10.5), they will both be removed.

**Warning:** Attempting to uninstall Python versions bundled with your OS may render your OS unusable.

