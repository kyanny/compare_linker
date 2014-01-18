Compare Linker
==============

Create GitHub's compare URL by parsing diff of `Gemfile.lock` from pull request.

What is "Compare URL"?
----------------------

Compare URL is link of "[GitHub Compare View](https://github.com/blog/612-introducing-github-compare-view)".
This is very useful to check diff of two revisions of any GitHub repository.

Many of rubygems' source code are hosted by GitHub, so they will have compare URL represents changes between any two versions.

If you use Bundler to manage your gem dependencies of your Ruby project, you might see diff of `Gemfile.lock` in your pull requests many time.
That diff shows only version number of updated gems, but there's no other information so it's not reviewer-friendly.

CompareLinker creates compare URL of updated gems by parsing diff of `Gemfile.lock`.
You no longer have to edit compare URL by your hand.

This is intended to integrate with GitHub's webhook feature.
You can boot CompareLinker webhook receiver on Heroku, or you can run CompareLinker on your Jenkins job.
See [guides](guides) section to read further information of setup guides.

CompareLinker listens "open new pull request" event of your repository and comment compare URLs of updated gems to pull request.

Guides
------

* [Heroku Setup Guide](guides/heroku_setup_guide.md)
* [Jenkins Setup Guide](guides/jenkins_setup_guide.md)
