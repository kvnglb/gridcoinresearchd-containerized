# Containerized all-in-one solution for gridcoin
This repository is intended to provide an easy setup for CPU crunching[^1] in the gridcoin ecosystem.
To achieve this, three containers will be enabled for
- [gridcoinresearchd](https://gridcoin.us/), the headless wallet and the blockchain *buzzword, buzzword*
- [boinc](https://boinc.berkeley.edu/), volunteer computing, support various science
- [Folding@home](https://foldingathome.org/), simulating protein dynamics to fight deseases

![setup](Docs/setup.svg)

gridcoinresearchd and boinc share a volume, that gridcoinresearchd can keep track of the cross-project ID.

# Quickstart
## Preconditions
Make sure, that the following packages are installed
- podman
- podman-compose
- make (this is just used for boinc setup instead of a shell script)

and also that the machine is configured for the user running the containers with
- lingering enabled
  ```
  loginctl enable-linger
  ```
  that the containers do not stop when the user logs out.

- enabled podman restart service
  ```
  systemctl --user start podman-restart.service
  systemctl --user enable podman-restart.service
  ```
  that the restart policy works.

*Docker might be used instead of podman. Make sure to substitute all podman commands with docker, don't forget the Makefile.*

## Clone
Clone this repository and enter its directory by running
```
git clone https://github.com/kvnglb/gridcoinresearchd-containerized.git
cd gridcoinresearchd-containerized
```
on the desired machine.

## gridcoinresearch.conf
Edit the file `./bind-mount/gridcoin/gridcoinresearch.conf` and enter a password for the rpc user

### INVESTOR MODE
everything is done, nothing more to do

### CRUNCHING MODE
- If you plan to also use the boinc container on that machine (does not matter if it crunches or stays idle, when at least one project is added), enter the email address that is used for the boinc project OR
- if the cross-project ID has already settled or the wallet runs on a machine, where boinc should't run, enter the CPID manually.

## fah.xml (only for crunching)
If you want to crunch on folding at home, edit its config `./bind-mount/fah/fah.xml`
- change your username in `<user>`. Must comply with `<name>_GRC_<CPID>`[^2]
- optionally change the team in `<team>`
- optionally enter your passkey in `<passkey>` (gives more points, and thereforce more GRC)[^3]
- adjust the number of CPU cores, you want to use in `<cpus>`

No need to modify the rest. Don't worry about the `0/0` entries. As visible in the compose file, Fah will only bind its listen port on localhost.

## Makefile (only for crunching)
*Well.. Ahm, yes. Maybe makefiles are not intended for this, anyway...*

This file is used to setup boinc and is only relevant for crunchers. Edit the Makefile and modify the lines in `add_project` as wanted. The private key can be found in the respective boinc project in `Your account -> section Account information -> Account keys`. When the CPID has already settled, you can use the weak account key (recommended), otherwise you must use the other account key, that boinc can sync the cross-project ID.

## Compose file
Adjust the `docker-compose.yml` file.
- Uncomment the lines based on your machines architecture for the gridcoin wallet and Fah. Eventually update the link, when newer versions are available: [gridcoin releases](https://github.com/gridcoin-community/Gridcoin-Research/releases) and [F@h releases](https://foldingathome.org/start-folding/)

## Start containers
At the very beginning, build the containers with
```
podman-compose build
```

Investors, who don't need boinc can skip all steps but the last one.

1. Start the boinc container and add all projects (Somehow the wallet has problems getting the CPID when it is started first and boinc has no attached projects; does not matter when `forcecpid` is used).
    ```
    podman-compose up -d boinc
    ```

1. Setup boinc with `make`
    - First, forbid boinc to crunch (will be later allowed again)
      ```
      make stop_crunch
      ```
    - Add your projects, run
      ```
      make add_projects
      ```
    - Adjust the percentage for how much CPU boinc should use. E.g a machine with 16 cores will use 8 for boinc with
      ```
      make cpu_perc perc=50
      ```
    - Allow boinc to crunch
      ```
      make start_crunch
      ```

1. Start the F@h container
    ```
    podman-compose up -d fah
    ```

1. Finally, start the wallet for gridcoinresearchd
    ```
    podman-compose up -d gridcoin
    ```

All [rpc command](https://gridcoin.us/wiki/rpc.html) should work, but they need the prefix `podman exec gridcoin_gridcoin`. So for example to get the mining information, run
```
podman exec gridcoin_gridcoin gridcoinresearchd getmininginfo
```

## Optionally log the wallets balance
When the balance of the wallet should be logged, add `walletlog.sh` to the crontab with `crontab -e` and add the line
```
0 5 * * * /path/to/walletlog.sh > /dev/null 2>&1
```
This will log every day at 5 a.m. the balance, if the wallet is able to stake and the magnitude. The file `balance.log` in the home directory of the user will look like
```
2024-05-18 05:00:02 5000.123 true 80
2024-05-25 05:00:03 5200.456 true 81
2024-05-26 05:00:03 5220.789 true 79
```

## Check if everything is working
```
podman ps -a
```
should show the three containers.

### Gridcoin
```
tail -f bind-mount/gridcoin/debug.log
```
should show a shit load of output, especially when the chain is syncing.

```
podman exec gridcoin_gridcoin gridcoinresearchd getinfo
```
should output something, that doesn't look like an error.

### Boinc
```
htop
```
or `top` should show a higher amout of CPU usage for their container/jobs.

```
podman exec gridcoin_boinc boinccmd --get_state
```
should output something, that doesn't look like an error.

When more projects are addes
```
podman exec gridcoin_boinc boinccmd --get_state | grep -i cross
```
should show the same cross-project ID. If not, wait a few days.

```
podman exec gridcoin_boinc boinccmd --get_state | grep -i job
```
Numbers should increase. Ideally not the `failed` one.

### Folding@home
`htop` like for boinc. To get the web control, forward your local port to the machine. Run on your local machine (not the server that is crunching)
```
ssh -NCL 7396:localhost:7396 <user>@<crunching machine ip>
```
and then enter in your browser `http://localhost:7396/`.


[^1]: I haven't found a comfortable way getting the GPU to work with containers.
[^2]: https://gridcoin.us/guides/foldingathome.htm
[^3]: https://foldingathome.org/support/faq/points/passkey/
