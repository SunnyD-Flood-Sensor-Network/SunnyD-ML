# SunnyD-ML
Machine learning for flooding classification from images. See docs and test here: https://ml-sunnydayflood.apps.cloudapps.unc.edu/__docs__/

## How it works
This code can be used to compile a Docker image that functions as an API for ML image classification using the Plumber package in R.

1. Dockerfile is used to create image. It installs are required packages (Python and R). Some of this code is from https://github.com/tmobile/r-tensorflow-api
2. When initialized, the Docker image runs `entrypoint.R` that loads the packages and model and starts the plumber API by running `plumber.R`
3. There is currently one function in the plumber API ("detect_flooding_latest"). This function takes a camera_ID, downloads the latest image from that camera, runs it through the model, and prints the output.
