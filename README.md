UCSB Jupyter All Spark Base Notebook
=================

Base image for launching Jupyter notebooks via JupyterHub.  This is based on the [Jupyter upstream](https://hub.docker.com/r/jupyter/all-spark-notebook) and adds features and libraries commonly used in data science lab courses at [UCSB](https://ucsb.edu) that make use of [Python](https://www.python.org/) and [R](https://www.r-project.org/).  In addition, these builds also include updates to the base OS image as available at the time of build.

Looking for RStudio support?  Check out our [RStudio base image](https://hub.docker.com/u/ucsb/rstudio-base).

## How to run

The most basic way to demo this locally: 

`podman -it -p8888:8888 ucsb/all-spark-base:latest`

In the stdout, there will be a link that includes a token that will allow you to login locally with a browser.  Common endpoints are `/lab` and `/hub`.

Generally, refer to [upstream documentation](https://jupyter-docker-stacks.readthedocs.io/en/latest/) for running these containers. These are also suitable images for deployment via [JupyterHub helm chart](https://zero-to-jupyterhub.readthedocs.io/en/latest/) or as a standalone deployment.

## How to build an image from this

In order to build a downstream image, the user should be first set to root, and then reset back once changes are complete:

```
FROM ucsb/all-spark-base:latest

USER root

# Add your changes here
RUN mamba install ...

USER $NB_USER
```

## Tags

`latest` - Periodically a Jupyter release version is tagged in the Containerfile and this tags tracks the most recent build against that particular version.  That version may get updated at least quarterly.

`weekly` - This tag is primarily for integration testing and tracks the upstream `latest` tag.  These images are generally built, tested, and updated weekly on Monday mornings (PDT time).

`v...` - The numbers in these tags represent a date and are effectively a snapshot of the `latest` tag as it was on that particular day.
