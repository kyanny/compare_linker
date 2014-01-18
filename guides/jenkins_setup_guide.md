CompareLinker Jenkins Setup Guide
=================================

This guide describes how to setup Jenkins job for CompareLinker.

Before setup, you have to install and run your Jenkins CI server.
And you have to install Ruby 1.9 or higher with `bundler` gem in your Jenkins server, too.

1. Install "Parameterized Trigger Plugin"
-----------------------------------------

https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Trigger+Plugin

1. Create new job
-----------------

Create new "Build a free-style software project" job.

3. Check "This build is parameterized" and parameters
-----------------------------------------------------

You need to add two string parameters:

1. `payload` (default value is `none`)
2. `OCTOKIT_ACCESS_TOKEN` (default value is your GitHub access token)

If you don't have GitHub access token, you can get it from https://github.com/settings/tokens/new.

![screen shot 2014-01-19 at 12 07 29 am](https://f.cloud.github.com/assets/10515/1947496/cb857bac-8058-11e3-9e02-598942018d7a.png)

4. Setup "Source Code Management" section
-----------------------------------------

Choose "Git". Repository URL is https://github.com/kyanny/compare_linker.git.

![screen shot 2014-01-19 at 12 07 33 am](https://f.cloud.github.com/assets/10515/1947518/6ebf3cb8-8059-11e3-936a-566797ed8c01.png)

5. Setup "Build Triggers" section
---------------------------------

Check "Trigger builds remotely".

If you want to enable authentication to start build job, fill in "Authentication Token" field.

![screen shot 2014-01-19 at 12 07 38 am](https://f.cloud.github.com/assets/10515/1947537/834b0da0-805a-11e3-8e90-a6a22ca1f2ae.png)

6. Setup "Build" section
------------------------

Choose "Execute Shell". Command is below.

```
#!/bin/bash

bundle install --path vendor/bundle
bundle exec ruby runner.rb
```

7. Add GitHub Webhook to your repository
----------------------------------------

CompareLinker rack app listens GitHub's pull request webhook.
Webhook URL is like `http://example.com/jenkins/[job_name]/buildWithParameters?token=[jenkins_auth_token]`.

You can add webhook to your repository by `curl(1)`:

```
$ curl -H 'Authorization: token [your_github_access_token]' \
  -d '{"name": "web", "active": true, "events": ["pull_request"], "config": {"url": "your_jenkins_webhook_url"}}' \
  https://api.github.com/repos/[repo_owner_account]/[repo_name]/hooks
```

Or by http://www.hurl.it/:

![screen shot 2014-01-19 at 1 25 12 am](https://f.cloud.github.com/assets/10515/1947590/6da9392e-805d-11e3-8304-ab8648c7a7e0.png)

If your jenkins requires authentication, you need basic auth to access jenkins.
You can embed basic auth credential to URL like "http://user@pass:host" style.

8. Open new pull request
------------------------

That's all! When your repository gets new open pull request, you will see new comment like that:

![screen shot](http://gyazo.com/22001fae8ba6ccba602cc6fa9886b05d.png)
