# BioThings Docker

## Build complete BioThings Studio + Hub
1. `docker compose build`
2. `docker compose up`
3. Visit `localhost:8080` for Biothings Studio
4. Connect to `localhost:7080` for local Biothings Hub

## Build BioThings Studio only
1. `docker compose build biothings-studio-webapp`
2. `docker compose up biothings-studio-webapp`
3. Visit `localhost:8080` for Biothings Studio

# or, using Makefile
make biothings_studio       # build image
make biothings_studio save  # save image

## Other Targets:

prerequisite:  docker, make

- `make studio4mygene`
- `make studio4myvariant`
- `make studio4mychem`


# Testing
- Follow tutorial http://docs.biothings.io/en/latest/tutorial/studio.html
  (using https://github.com/sirloon/mvcgi datasource). Tests the whole process
- https://github.com/sirloon/gwascatalog for dumper custom release
- https://github.com/sirloon/FIRE for parallelization

Tests are located in the `tests` directory.


# If your newly built container does not run

Contrary to usual docker containers that are single purpose, this container
runs multiple applications, for historical and compatibility reasons.

In essence, it runs Nginx, MongoDB, and Elasticsearch in the background, and then switches
to the `biothings` user and starts up tmux. Inside tmux, the BioThings Hub is run.

If something went wrong and you need to figure out what's going on, here are a few
tips:

1. You can use `docker exec -it <CONTAINER> /bin/bash` to get inside the container, or
you can elect not to run the container in the background. This way you get a root shell
prompt so you can inspect things.

2. Usually Nginx, ES and MongoDB don't tend to break. So once you have the root prompt, 
you can run `su - biothings` to switch user, and then attach to the running tmux session
to figure out what actually went wrong with BioThings Hub.

3. Usually it's because a dependency has changed, in this case make up your mind whether 
you want to pin the version of the dependency or upgrade BioThings to be compatible with
the new version.

4. Or BioThings SDK was changed in a way that the old default configuration files are no
longer compatible. In this case just fix the config files. Some of them come from 
Ansible making patches here and there but most of the file should be what you see in the
repos.


# update README: How to run integration tests

Step 0: Prepare your S3 bucket & IAM user:
   - Create two S3 buckets, we will fill two bucket name the `config.py` at step 2 : <SNAPSHOT_BUCKET_NAME> with default private access and <PUBLISH_BUCKET_NAME> with public read access, example policy:
   ```{
    "Version": "2012-10-17",
    "Id": "Policy1649048240823",
    "Statement": [
        {
            "Sid": "Stmt1649048235557",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<PUBLISH_BUCKET_NAME>/*"
        }
    ]
    }```

   - Create an IAM user with at least read/wrire permission on two above buckets, or AmazonS3FullAccess - not recommend
   - Create new Access keys, we will use this info on the step 4.

Step 1: Install Docker, tavern-ci, pytest

Step 2: Run `copy tests/hubapi/demohub/biothing_studio/config.py.example tests/hubapi/demohub/biothing_studio/config.py`, edit file `config.py` (fill your: SNAPSHOT_BUCKET_NAME, PUBLISH_BUCKET_NAME, AWS_ACCESS_KEY, AWS_SECRET_KEY)

Step 3: Run `copy tests/hubapi/demohub/testcases/config.yaml.example tests/hubapi/demohub/testcases/config.yaml`, edit file `config.yaml`

Step 4: Run `copy .env.example .env.local`, edit file `.env.local`

  - Fill: AWS_ACCESS_KEY, AWS_SECRET_KEY if you want to test S3 snapshot
  - Fill: BIOTHINGS_REPOSITORY, BIOTHINGS_VERSION if you want to build a specific Biothing SDK repo/git branch
  - When you want to use a custom python version, use PYTHON_VERSION params, and run `make demohub-test` on step 6.
  - Supported PYTHON_VERSION from 3.6.2 to 3.10.x

Step 5: Load environment vars: `source .env.local`

Step 6: Run make command to build image
  - If you want to use default Python on Ubuntu 20.04, run `make demohub` (it will create a image with tag: demohub:$BIOTHINGS_VERSION)
  - If you want to use a custom Python version (ex: 3.10.0, 3.9.0) run `make demohub-test` (it will create a image with tag: demohub:$BIOTHINGS_VERSION$PYTHON_VERSION)

Step 7: Run `make start-demohub`, and waiting services fully boot up

Step 8: Create `make run-test-demohub` for running test

Step 9: Run `make stop-demohub`, and waiting services fully stop
