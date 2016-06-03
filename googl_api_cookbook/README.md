# Googl API Cookbook

The Googl API Cookbook installs and configures ruby, unicorn, and nginx to run 
the [googl_api](https://github.com/GovWizely/googl_api) Rails app. This cookbook supports Chef 12.10+ and 
implements support for testing with test-kitchen 1.8+.

## Pre-requisites

- [Google API Key](https://developers.google.com/url-shortener/v1/getting_started#APIKey) 
- AWS OpsWorks with Chef 12 or Chef Server
- SSL certificate information
- Security group that allows all inbound HTTPS traffic to port 443 and all outbound traffic to destinations

## Recipes

### setup

The setup recipe installs `curl` and `nginx`, creates a `deploy` user & group, and configures `apt` to update the cache daily.

### configure

The configure recipe sets the `PATH` and `GOOGL_API_KEY` environment variables, installs the SSL credentials for `nginx`, 
and configures log rotation for `unicorn` and `nginx`. 

### deploy

The deploy recipe checks out the latest Rails application code from the `googl_api` repository master branch, 
ensures the proper versions of ruby and required gems are available, and sets up `unicorn` to serve the app. It then 
enables the `nginx` site.

## AWS OpsWorks settings

### Stack settings

- Operating system: Ubuntu 16.04 LTS
- Repository URL: `git@github.com:GovWizely/googl_api_cookbook.git`
- Branch/Revision: `master`

### Layer settings

- Name: `api`
- Short name: `api`
- Custom chef recipes
  * Setup: `googl_api::setup`
  * Configure: `googl_api::configure`
  * Deploy: `googl_api::deploy`

### App settings

- Name: `googl_api`
- Data source type: `None`
- Repository URL: `https://github.com/GovWizely/googl_api`
- Branch/Revision: `master`
- Protected environment variables:
  - `GOOGL_API_KEY`
- Enable SSL: Yes

## Testing

A full test run of all test-kitchen tests and Rubocop and Foodcritic evaluations would look like:

```bash
$ foodcritic ./recipes/*
$ rubocop
$ kitchen test
```

There are no overrides for foodcritic rules, however the adjustments to
rubocop are made using the supplied `.rubocop.yml` file

### Fixtures

This cookbook supplies a data bag called `aws_opsworks_app` under `test/integration/` that mimics the 
JSON for an AWS OpsWorks app.

# Workflow

- Make your changes in `source` branch.
- Commit and push your changes to origin.
- Run `rake build_remote` to push vendored cookbooks to `master`.

## Acknowledgments

Thanks to [David Pranata](https://github.com/davidpranata) for all the help, code, and advice!
