# deploy-hugo.sh

**Fast, safe, and nearly foolproof publishing for Hugo static sites.**

This script builds your Hugo blog, snapshots changes with git, and securely deploys your site to a remote server via `rsync`—with plenty of prompts and color warnings so you don’t nuke your own site by accident.

I wrote it to automate my manual procedure to reduce the chance of error and it add nice logic to deal with git and rsync. The script errs on the side of caution and has worked reliably for me. I hope you find it useful. 

---

## 🚀 Quick Start

1. **Copy `deploy-hugo.sh` into your Hugo site folder** (or wherever you want to run it).
2. Edit the `CONFIGURABLES` section at the top of the script to match your setup.
3. Run it:

    ```sh
    ./deploy-hugo.sh
    ```

*Pro-tip:*
Set `DRYRUN=1` to test your config **without** pushing any files!

---

## 🛠️ Configuration

Open the script in your editor and set the following variables:

```bash
REMOTE_HOST="yourwebhost"                # SSH host, alias, or IP
REMOTE_PATH="/home/USERNAME/public_html" # Remote path to site’s web root
HUGO_PROJECT_DIR="$HOME/path/to/your-hugo-project"  # Local path to Hugo site
RSYNC_FLAGS="-av --delete"               # Adjust for your risk tolerance
DRYRUN=0                                 # 1 = Test mode (no changes)
```

Minimal config:
Change at least REMOTE_HOST, REMOTE_PATH, and HUGO_PROJECT_DIR.

Use SSH keys for painless auth.

Consider keeping secrets/paths in an .env file and sourcing it at the top for fancier setups.

## 🧩 What does it do?
- Stops any running hugo server dev process.

- Cleans and rebuilds your site with hugo --cleanDestinationDir.

- Warns you if there are uncommitted git changes (and can auto-commit them for you).

- Checks for draft posts before deploy.

- Deploys your built site via rsync (with a last-chance prompt!).

- Prints a random fortune for style points if successful. 

## ✏️ Customization

This script is simple. To use, just customize the following: 

- For staging/prod:
  Duplicate the script and set different remote hosts/paths.

- For multi-site:
  Set different HUGO_PROJECT_DIR and REMOTE_PATH for each project.

- Want to auto-pull git on remote?
  Add an ssh $REMOTE_HOST step after deploy.

- More rsync flags:
  Read up on rsync and tweak RSYNC_FLAGS for your paranoia level (or speed).

- Want color output but not ANSI?
  Remove the \033[1;36m and similar bits.


## ⚠️ Safety Tips
Always run with DRYRUN=1 the first time!

Double-check your REMOTE_PATH before blasting files.

Backup your remote site periodically (use versioning if possible).

```bash
REMOTE_HOST="myhost"
REMOTE_PATH="/var/www/html"
HUGO_PROJECT_DIR="$HOME/code/blog"
RSYNC_FLAGS="-av --delete"
DRYRUN=1
```

💡 Want more features?
- Log file support

- Email/push notification on deploy

- Auto-upload media/screenshots

Open a PR or send ideas to [feedback@adminjitsu.com](mailto:feedback@adminjitsu.com) and I might just add it!
