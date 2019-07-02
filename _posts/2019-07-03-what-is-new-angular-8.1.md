---
layout: post
title: What's new in Angular 8.1?
author: cexbrayat
tags: ["Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 8.1 is out!"
---

Angular&nbsp;8.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#810-2019-07-02">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

To be honest, not much to say for this 8.1 release 🙃.
But let's try nevertheless!

## Ivy

As you may have understood if you read our last
[blog](/2019/05/07/what-is-angular-ivy/)
[posts](/2019/05/29/what-is-new-angular-8.0),
Ivy is still a big part of the work done by the Angular team
for this release.
The plan is still to enable it by default in v9,
with no regression if possible.
As some users have been trying it since v8,
the team is squashing bugs in corner cases,
and tries to squeeze some perf improvements here and there.
Some instructions were redesigned,
the styles and animations APIs are getting a makeover:
overall it looks good.

And I'm amazed at the amount of work the team has to do
to make sure that none of the (thousands of) Google applications
using Angular are broken.
Which is good news for everybody in the community,
because Ivy will have been thoroughly tested when it goes live!

## Indexing API

A new package called `indexer` has been added to the Angular repository.
Behind this mysterious name is an API to allow for generation
of semantic analysis of components and their templates.
So far the scope of the API is very limited,
but the idea is to allow language analysis tools
to more easily parse Angular templates.

Right now the indexer is targeted for internal Google usage if I understand correctly
(with the language analysis tooling called [Kythe](https://github.com/kythe/kythe/)).
But we can hope to see tools built by the community
that would use it and allows us to analyze our applications.

That's all for Angular&nbsp;8.1 🙂
You can check out our other article about
the [CLI&nbsp;8.1 release](/2019/07/03/angular-cli-8.1/)
which contains much more features!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
