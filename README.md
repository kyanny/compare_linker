Compare Linker
==============

Create GitHub's compare view URLs for pull request from diff of `Gemfile.lock` (and post comment to pull request).

![screen shot 2014-01-27 at 2 25 14 am](https://f.cloud.github.com/assets/10515/2004469/de374152-86ae-11e3-84a0-19e2ef40b959.png)

[GitHub Compare View](https://github.com/blog/612-introducing-github-compare-view) rocks.But [diff of Gemfile.lock](https://github.com/kyanny/compare_linker_demo/pull/14/files) sucks. So I made Compare Linker.

Rack app for listening GitHub Webhook
-------------------------------------

There's rack application for Compare Linker with GitHub's Webhook.

https://github.com/kyanny/compare_linker_rack_app
