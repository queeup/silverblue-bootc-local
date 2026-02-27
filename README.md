# Build Silverblue bootc image locally

## Install

```bash
sh -c "$(curl -fsSL https://github.com/queeup/silverblue-bootc-local/raw/main/git-install.sh)"
```

### Build and switch to the image by running

```bash
sudo systemctl start --verbose system-build.service
```

### And enable the timer for it by running

```bash
sudo systemctl enable --now system-build.timer
```
