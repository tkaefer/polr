import tempfile
import structlog
import subprocess
import glob
import os
import sys

logger = structlog.get_logger(__name__)
deploy_dir = os.path.dirname(os.path.realpath(__file__))


for environment in ("production",):
    deploy_dir = os.path.join(deploy_dir, environment)
    logger.info("Scanning environment", glob=deploy_dir)

    with tempfile.NamedTemporaryFile(
        mode="w+", prefix=f"krane-render-{environment}", encoding="utf8"
    ) as f:
        try:
            f.write(
                subprocess.check_output(
                    [
                        "krane",
                        "render",
                        "--filenames",
                        deploy_dir,
                        "--bindings=container_registry=test-registry.docker.io",
                        f"--current-sha={os.environ['REVISION']}",
                    ],
                    stderr=sys.stderr,
                ).decode("utf-8")
            )
        except subprocess.CalledProcessError as e:
            logger.exception(e.output.decode("utf-8"))
            raise

        f.flush()

        logger.info(
            "Validating rendered template", environment=environment, filename=f.name
        )
        subprocess.check_call(
            [
                "kubeval",
                "--kubernetes-version",
                "1.17.0",
                "--strict",
                "--schema-location",
                "https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master",
                f.name,
            ]
        )
