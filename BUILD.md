# Building LiberNT with Docker

The Docker build runs the whole LiberNT build in a container, so the only thing your machine needs is Docker with Compose. The image holds every build dependency and the RosBE toolchain. Your source tree is mounted into the container, and the output folders are written into it, as with a build on the host.

## Files

| File | What it does |
| --- | --- |
| `docker/Dockerfile` | The builder image: Ubuntu 24.04, the build tools, and RosBE in `/opt/rosbe`. |
| `docker/libernt-build.sh` | The entry point. It runs `./configure.sh` with the container's arguments and builds the targets you ask for. |
| `docker-compose.yml` | Mounts the current directory at `/libernt` and runs the build as your user. The `command` property holds the arguments passed to `configure.sh`. |

## Build the image

Run this once from the source tree, and again when the toolchain changes:

```sh
docker compose build
```

## Build LiberNT

Run the build from the root of the source tree:

```sh
docker compose run --rm libernt
```

This configures the tree with the arguments in `command` (by default `["-a", "amd64"]`, an AMD64 Debug build with Clang) and builds `LiberNT.img`.

To build something else, change `command` in `docker-compose.yml` or pass `configure.sh` options on the command line. These replace `command`:

```sh
docker compose run --rm libernt -a arm64              # ARM64 Debug build with Clang
docker compose run --rm libernt -a i386 --gcc         # 32-bit x86 build with GCC
docker compose run --rm libernt -a amd64 --release    # optimized AMD64 build
docker compose run --rm libernt menuconfig            # choose the options in a menu first
```

The container accepts every `configure.sh` option listed in [Building](README.md#building-libernt-yourself). Start `menuconfig` with `docker compose run`, which gives the menu a terminal.

## Settings

Set these in the environment when you start the build:

| Variable | Default | What it does |
| --- | --- | --- |
| `LIBERNT_TARGET` | `liberntimg` | The targets to build, separated by spaces: `bootcd`, `liberntimg`, `liberntvhd` or any other build target. |
| `LIBERNT_JOBS` | the number of host CPUs | The number of parallel build jobs. Lower it to keep the machine usable during a build. |
| `LIBERNT_UID`, `LIBERNT_GID` | `1000` | The user and group the build runs as, so the files it writes belong to you. |

For example:

```sh
export LIBERNT_UID=$(id -u) LIBERNT_GID=$(id -g)
LIBERNT_TARGET="bootcd liberntimg" docker compose run --rm libernt -a arm64
LIBERNT_JOBS=8 docker compose run --rm libernt
```

## Output

The output folder follows the usual pattern with a `-docker` suffix, for example `output-Clang-amd64-debug-docker`. The suffix keeps container builds apart from builds made with RosBE installed on the host, because each output folder works only with the toolchain that configured it.

Running the same build again reuses its output folder and rebuilds only what changed. An interrupted build continues where it stopped.

## Shell in the container

Any command that is not a `configure.sh` option runs as is. To work in the container by hand:

```sh
docker compose run --rm libernt bash
```
