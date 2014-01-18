CompareLinker Heroku Setup Guide
================================

This guide describes how to setup your CompareLinker app on Heroku.

Before setup, you have to install Heroku toolbelt and login to Heroku API via `heroku` command.

1. Clone compare_linker from GitHub
-----------------------------------

```
$ git clone https://github.com/kyanny/compare_linker.git
```

2. Create your own Heroku app
-----------------------------

```
$ cd compare_linker
$ heroku apps:create
```

3. Deploy compare_linker to Heroku
----------------------------------

```
$ git push heroku master
```

4. Set `OCTOKIT_ACCESS_TOKEN` config
------------------------------------

```
$ heroku config:set OCTOKIT_ACCESS_TOKEN=[your_githu_access_token]
```

If you don't have GitHub access token, you can get it from https://github.com/settings/tokens/new.

5. Add GitHub Webhook to your repository
----------------------------------------

CompareLinker rack app listens GitHub's pull request webhook.
Webhook URL is like `http://kyanny-compare-linker.herokuapp.com/webhook`.
Don't forget `/webhook` path!

You can add webhook to your repository by `curl(1)`:

```
$ curl -H 'Authorization: token [your_github_access_token]' \
  -d '{"name": "web", "active": true, "events": ["pull_request"], "config": {"url": "your_heroku_app_url"}}' \
  https://api.github.com/repos/[repo_owner_account]/[repo_name]/hooks
```

Or by http://www.hurl.it/:

![screen shot 2014-01-19 at 12 33 29 am](https://f.cloud.github.com/assets/10515/1947448/77f1b53e-8056-11e3-8eba-edb2fec5bd8e.png)

6. Open new pull request
------------------------

That's all! When your repository gets new open pull request, you will see new comment like that:

![screen shot](http://gyazo.com/22001fae8ba6ccba602cc6fa9886b05d.png)
