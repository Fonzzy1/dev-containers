import subprocess
import os


def run_vim(
    env_location,
    valut_location,
    mount_dir,
    mount_dir_name=None,
    command="vim",
    check_changes=True,
    clean_mount_dir=False,
):
    current_dir = subprocess.run(["pwd"], capture_output=True, text=True).stdout.strip()
    os.chdir(mount_dir)

    if mount_dir_name == None:
        mount_dir_name = mount_dir.split("/")[-1]

    pre_command = f"""
            cp -r  /tmp/vault /vault &&  chmod -R 600 /vault;
            gh auth setup-git;
            git config --global --add safe.directory /{mount_dir_name};
            """

    command = pre_command + command

    if clean_mount_dir:
        command = f"find /{mount_dir_name} -mindepth 1 -delete;" + command

    if check_changes:
        command += ' \
            CHANGES=$(git status --porcelain); \
            UPSTREAM_CHANGES=$(git cherry -v); \
            if [ -n "$CHANGES" ] || [ -n "$UPSTREAM_CHANGES" ]; then \
                vim -c \':G | only\'; \
            fi'

    subprocess.run(
        [
            "docker",
            "run",
            "-it",
            "--env-file",
            env_location,
            "--net=host",
            "--rm",
            "-w",
            f"/{mount_dir_name}",
            "-v",
            "/var/run/docker.sock:/var/run/docker.sock",
            "-v",
            f"{mount_dir}:/{mount_dir_name}",
            "-v",
            f"{ env_location}:/root/.env",
            "-v",
            f"{ valut_location}:/tmp/vault",
            "fonzzy1/vim",
            "/bin/bash",
            "-c",
            command,
        ]
    )
    os.chdir(current_dir)
