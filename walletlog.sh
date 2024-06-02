#!/bin/bash
# crontab: 0 5 * * * /path/to/walletlog.sh > /dev/null 2>&1

log() {
	echo $(date '+%Y-%m-%d %H:%M:%S') $1 >> $HOME/balance.log
}

balance_staking="$(podman exec gridcoin_gridcoin gridcoinresearchd getwalletinfo | grep -E "balance|staking" | sed "s/.*: //" | tr "\n" " " | tr -d ",")"
magnitude="$(podman exec gridcoin_gridcoin gridcoinresearchd getmininginfo | grep current_magnitude | sed "s/.*: //" | tr "\n" " " | tr -d ",")"

log "$balance_staking $magnitude"
