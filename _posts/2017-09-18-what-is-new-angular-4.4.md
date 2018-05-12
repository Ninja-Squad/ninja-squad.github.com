---
layout: post
title: What's new in Angular 4.4?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4"]
description: "Angular 4.4 is out! Which new features are included?"
---

Angular 4.4.1 is here (4.4.0 glitched out and was never released)!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#441-2017-09-15">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a fairly small release, with some bugfixes but not a lot of features.
Angular 5.0, scheduled for next month, will bring more awesomeness but we'll have to wait a little.

Let's see what 4.4 has in stock for us!

## Performance with preserveWhitespaces

A few things changed internally to boost performance,
and a new compiler flag appeared that allows to remove extra whitespaces.
This can look minor, but it can improve the generated code size,
and also speed the components creation.
But it can also break your layout if you rely on several consecutive spaces in your templates :)
That's why the default for the `preserveWhitespaces` flag is `true` for now,
and might become `false` one day. But right now, you have to activate it manually.

You can configure it globally:

    platformBrowserDynamic().bootstrapModule(AppModule, {
      preserveWhitespaces: false
    });

or per component:


    @Component({
      selector: 'pr-home',
      templateUrl: './home.component.html',
      preserveWhitespaces: false
    })
    export class HomeComponent implements OnInit, OnDestroy {

If you really want a whitespace to be kept,
you can use a special entity called `&ngsp;`.
It looks like `&nbsp;` with a typo, but it is not:
it is a special character that the Angular compiler will transform in a whitespace.
Note that it will only keep one whitespace, even if add several consecutive ones, like `&ngsp;&ngsp;`.
If you really want to preserve the whitespaces in a fragment of a template,
you can use `ngPreserveWhitespaces`:

    {% raw %}
    <div ngPreserveWhitespaces>hello     there</div>
    {% endraw %}

Note that the gains were fairly small on our applications,
but a gain is a gain...

## Multiple exportAs names

It's not really important, but it's the second and last feature of this release:
you can now specify several names in the `exportAs` attribute of a directive.
This is mostly introduced for allowing to change the name of existing directives,
while still keeping the old one for backward compatibility.

For example:

    @Directive({
      selector: '[ns-ninja]',
      exportAs: 'ninja, superNinja'
    })
    export class NinjaDirective {

can be used as:

    <div ns-ninja #foo="ninja">
    <!-- or -->
    <div ns-ninja #foo="superNinja">

# Summary

That's all for this release: the next important one will be 5.0!

The Angular CLI also had interesting changes lately.
Check out our blog posts if you missed them:

- [Angular CLI 1.3](/2017/08/10/angular-cli-1.3/)
- [Angular CLI 1.4](/2017/09/14/angular-cli-1.4/)

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
