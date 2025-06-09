# staying-alive

Keep-alive for filesystems with admin-level expiry dates

## Why

This refreshes the timestamps on files such that you can prevent your admins from deleting them, if you still need the files. Use intelligently, don't add your entire user-accessible files to it. Your admins probably have expery dates for a reason :P

## How-to

Run `install.sh`

You can specify the `--period/-p` using `systemd` duration format: us, ms, s, m, h, d, w, M, y (microseconds to years). For example, `1w 2d` would be one week and two days. This defaults to `1w`.

You can specify the install directory for the auxiliary files using `--install-dir/-i`. This defaults to `~/.staying-alive`. In this directory, you'll find `staying_alive_timestamps.log` and `to_keep_alive.txt`. To add directories to keep alive, add them on a new line in `to_keep_alive.txt`. The `staying_alive_timestamps.log` just records the times where `staying_alive` was called.

The `install.sh` script will add `staying_alive` to your `.bashrc`. Manually remove it from there if you dont want it lol.

You can also manually call `staying_alive` from the CLI. You can also manually call `poke_files` from the CLI to poke specific directories without adding them to `to_keep_alive.txt`.

## Sbatch mode

Say, you got a ton of files you need to poke. Say, it's wayyy too slow if you put it in `.bashrc` directly. Try putting something like this in your `.bashrc` instead:

```
staying_alive -c \
    --input-file "/home/<user>/.staying-alive/to_keep_alive.txt" \
    --log-file "/home/<user>/.staying-alive/staying_alive_timestamps.log" \
    --period "2w" \
&& sbatch --partition=long-cpu --time=3:00:00 --mem=8G --cpus-per-task 3 \
    --workdir=/home/<user>/.staying-alive \
    --output=/home/<user>/.staying-alive/slurm-%j.out \
    --error=/home/<user>/.staying-alive/slurm-%j.err \
    --wrap="staying_alive \
        --input-file '/home/<user>/.staying-alive/to_keep_alive.txt' \
        --log-file '/home/<user>/.staying-alive/staying_alive_timestamps.log' \
        --period '2w'"
```