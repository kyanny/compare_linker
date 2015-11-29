# Compare Linker [![Build Status][travis-badge]][travis-link] [![Gem Version][gem-badge]][gem-link]

Create GitHub's compare view URLs for pull request from diff of `Gemfile.lock` (and post comment to pull request).

![screen shot 2014-01-27 at 2 25 14 am](https://f.cloud.github.com/assets/10515/2004469/de374152-86ae-11e3-84a0-19e2ef40b959.png)

[GitHub Compare View](https://github.com/blog/612-introducing-github-compare-view) rocks.But [diff of Gemfile.lock](https://github.com/kyanny/compare_linker_demo/pull/14/files) sucks. So I made Compare Linker.

## Usage

```ruby
require 'compare_linker'

ENV['OCTOKIT_ACCESS_TOKEN'] = 'xxx'

compare_linker = CompareLinker.new('masutaka/compare_linker', '17')
compare_linker.formatter = CompareLinker::Formatter::Markdown.new
comment = compare_linker.make_compare_links.to_a.join("\n")
compare_linker.add_comment('masutaka/compare_linker', '17', comment)
```

## Rack app for listening GitHub Webhook

There's rack application for Compare Linker with GitHub's Webhook.

https://github.com/kyanny/compare_linker_rack_app

[travis-badge]: https://travis-ci.org/masutaka/compare_linker.svg?branch=master
[travis-link]: https://travis-ci.org/masutaka/compare_linker
[gem-badge]: https://badge.fury.io/rb/compare_linker.svg
[gem-link]: http://badge.fury.io/rb/compare_linker
