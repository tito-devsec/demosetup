# Local-only demo scaffolding

Everything in this directory is excluded from git (`/demo-local/` in
`.gitignore`) on purpose. PreRan is a general-purpose Linux prevention/
response tool - a fake healthcare company's demo dataset is presentation
scaffolding for one event, not a feature of the product, and must never
be part of the tool's own repository or install.

Because it's gitignored, **`git clone`/`git pull` on the VM will not
bring this file over**. Get it onto the VM some other way: `scp
demo-local/demo_setup.sh you@vm:~/`, a VirtualBox shared folder, or just
paste its contents into a new file on the VM directly.

## What it does

One script, `demo_setup.sh`, run once on the VM after `sudo ./install.sh`:

1. Generates ~95 synthetic files (patient records, billing, HR, lab
   results, insurance claims, legal, IT, vendor contracts, backups,
   shared) under `/srv/medcore` - all clearly marked `[FAKE]`/`DEMO`,
   nothing here is a real record.
2. Seeds a real local PostgreSQL database (`medcore_clinic`) with ~95
   rows across 5 tables.
3. Registers `/srv/medcore` with the engine's real-time watcher
   (`watch_dirs` in `/etc/warden/config.toml`) and with preran-cli's own
   vault/honeyfiles layer, and switches `protection_mode` to `enforce`.
4. Plants PreRan honeyfiles among the fake data.
5. Ends by tailing `warden.service` + `preran-watch.service` live, so you
   just trigger your ransomware simulator against `/srv/medcore` in
   another terminal and watch the reaction in this one.

```bash
chmod +x demo_setup.sh
sudo ./demo_setup.sh
```

Re-running it is safe - it recreates the fake files/DB rows and re-checks
`watch_dirs` rather than duplicating it.

## Cleanup after the demo

```bash
sudo rm -rf /srv/medcore
sudo find /var/lib/warden/quarantine -mmin -180 -delete
sudo -u postgres dropdb medcore_clinic
sudo -u postgres dropuser medcore_app
```
