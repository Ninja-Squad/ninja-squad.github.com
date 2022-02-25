---
layout: post
title: Taste our new speculoos
author: jbnizet
tags: ["Angular", "ngx-speculoos", "test", "jasmine"]
description: "Taste our new ngx-speculoos"
---

<div style="float: right;"><img src="/assets/images/ngx-speculoos.svg" alt="ngx-speculoos logo" style="width: 250px;"/></div>

In 2018, we released the [first version of ngx-speculoos](/2018/06/05/announcing-ngx-speculoos/),
a small library to help writing Angular unit tests.

Since then, the library hasn't evolved much, but we keep using it on all of our Angular projects
and are quite happy with it. 

We're now even happier, because we just released a new version, 7.1.0, with [a batch of new features](https://github.com/Ninja-Squad/ngx-speculoos/releases/tag/v7.1.0). In particular, [stubbing the `ActivatedRoute`](https://ngx-speculoos.ninja-squad.com/documentation/classes/ActivatedRouteStub.html) 
is now done in a much better way than it was before, and [creating Jasmine mocks is much less verbose](https://github.com/Ninja-Squad/ngx-speculoos#mocking-helper) 
thanks to this new version.

We also improved queries to make it easier to query elements, but also components or custom test elements,
by CSS and by type.

And last but not least, we completely revamped [the documentation](https://github.com/Ninja-Squad/ngx-speculoos/blob/master/README.md) to make it much more 
complete, structured and readable. Reading it should not take you more than a few minutes, and should give you an 
pretty good idea of how ngx-speculoos tastes. 

We see ngx-speculoos as a little unknown gem. If you haven't already, you should give it a try.

And while you're at it, our other Angular library, [ngx-valdemort](https://ngx-valdemort.ninja-squad.com/)
is another gem that we use everywhere to help with form validation.
Give it a try, too.
