---
layout: post
title: What's new in Angular 11.0?
author: cexbrayat
tags: ["Angular 11", "Angular"]
description: "Angular 11.0 is out!"
---

Angular&nbsp;11.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1100-2020-11-11">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

We have some new features,
but most changes in this version are the result of deprecations and removals,
and their associated schematic migrations will do the heavy lifting for you.
Let's see what we have.

## Error codes

The top 8 runtime errors in Angular now have a code!
In the long run, this will help developers to find relevant information on an error.
We can expect the official documentation to reference these codes soon,
but in the meantime, here are the most frequent runtime errors we all have seen once:

- [NG0100: "ExpressionChangedAfterItHasBeenCheckedError" (change detection error)](https://angular.io/errors/NG0100)
- [NG0200: "Circular dependency" (dependency injection error)](https://angular.io/errors/NG0200)
- [NG0201: "No provider for X" (dependency injection error)](https://angular.io/errors/NG0201)
- [NG0300: "Multiple components match node with tagname X" (template error)](https://angular.io/errors/NG0300)
- [NG0301: "Export of name X not found" (template error)](https://angular.io/errors/NG0301)
- NG0302: "The pipe X could not be found" (template error)
- NG0303: "Can't bind to X since it isn't a known property" (template error)
- NG0304: "X is not a known element" (template error)

## Trusted types

To be honest with you, I had never heard of Trusted types before seeing commits about them in Angular 😃.
It turns out it is a new standard API in [modern browsers](https://caniuse.com/trusted-types),
that helps developers prevent XSS attacks by DOM injections.

A browser supporting Trusted types can warn the developers when they are doing unsafe DOM manipulation
(like using `innerHTML` for example).
You can also collect these violations by adding a CSP header to your document,
indicating to the browser where to collect them.
You can fix these violations, or declare a policy using this new API,
and use this policy as a factory to create trusted content.
When you declare a policy, all unsafe content must be handled by the factory you created to make it safe (well, nothing is safe, but at least trusted, hence the name).

Of course, you may use a library or a framework that do some of these unsafe manipulations.
Angular itself does and has some APIs to let us do so as well.
These APIs now use a custom policy to make them compliant with Trusted Types.

So if you work at a place where security is really important,
you may hear about enabling Trusted Types in your applications:
Angular v11 is already ready to help,
and won't raise violations that you can't fix.

If I understand correctly, this has been in use at Google for quite some time,
and the good results lead to the official specification.
The Google security team helped the Angular team
to make the framework ready,
and we should see official documentation soon.
The CLI may even help us detecting potential violations in the future.
You can already start by adding a custom CSP header to dev server (see [our CLI blog post](/2020/11/11/angular-cli-11.0/))

Pretty much all my knowledge comes from [this article](https://web.dev/trusted-types/),
if you want to learn more.

## Service Workers

If you are using the `@angular/pwa` package,
you're probably aware that you're using service workers in the background.
The `SwUpdates` service lets you know when an important event happens,
for example when a new version of the application is available.
Just subscribe to the `available` observable,
and you'll be notified.

You can now also subscribe to the `unrecoverable` observable,
which lets you know if your application reached an unrecoverable state.
It can happen that the service worker can't find a cached asset
(maybe because the browser removed it),
and the server no longer has it (maybe because you deployed a new version of the application).
In that case, the only way to fix the application is to reload the page.
You can now display a nice message to encourage your users to do so
if that (fairly rare) unrecoverable state happens.

## Router

The `navigationExtras` parameter of `navigateByUrl` and `createUrlTree` are now more accurately typed:
they were allowing us to pass some options that have no effect!
It will probably not impact your application,
but a migration will analyze your code and remove them automatically if needed.

Some of these options were deprecated since Angular v4, and are now removed.
The migration will replace them in your code with their recommended alternatives.
For example: `preserveQueryParams: true` will be transformed into `queryParamsHandler: 'preserve'`.

The previous changes probably won't affect your application,
but a last router migration might update your code.
Let me explain an old issue with this route configuration:

    {
      path: '',
      component: ParentComponent,
      children: [
        { path: 'child', component: ChildComponent }
      ]
    }

In the template of parent component we have to use `<a routerLink="../child">Child</a>`
to navigate to the child component,
whereas you would expect `<a routerLink="./child">Child</a>` to properly work.
Since Angular v7, this was fixed if you used `relativeLinkResolution: 'corrected'`
when configuring your RouterModule:

    RouterModule.forRoot(ROUTES, { relativeLinkResolution: 'corrected' })

But, by default, the fix was not applied (the default value of the option was `legacy`),
as it would have break existing applications using `../child`.

The default is changing in v11 to be `corrected`.
To avoid breaking your application,
a migration will rewrite your RouterModule declaration
to explicitly use the `legacy` option:

    RouterModule.forRoot(ROUTES, { relativeLinkResolution: 'legacy' })

You can then test if it works with the new default `corrected`,
and remove the extra option when it does.


## Pipes

The `date` pipe (and the related `formatDate` function) is now able to get the week-numbering year
as specified by [ISO 8601](https://en.wikipedia.org/wiki/ISO_week_date),
which can be tricky to compute for weeks that start or end a year:

    formatDate('2013-12-27', 'YYYY', 'en'); // 2013
    formatDate('2013-12-29', 'YYYY', 'en'); // 2014

Note that most pipes have a more strictly typed signature that should help us catch potential errors.
For example, `date` used to accept `any` value, and now only accept the real types it can handle: ` Date | string | number`.

You may have compilation errors with these stricter signatures when you upgrade,
but they'll probably indicate real issues with your application.

## Forms

The base class for form controls, groups, and arrays has several properties like `invalid`, `dirty`, etc.
It also has a property `parent`, allowing to get the parent form group or array.
The type returned by `parent` has been updated from `FormGroup | FormArray` to `FormGroup | FormArray | null` as it can indeed return `null` (for example for the root form group).
This should not impact you, but if you use `control.parent.something` somewhere,
you now have to take care of the potential null value of `parent`.
As often, the Angular team already wrote a migration for us.
When upgrading to v11, the migration will add the relevant `!` in your code when necessary
(if you use the "strict null checks" option of TypeScript):
`control.parent!.something`.

## i18n

A new option is available for the i18n message extraction: `enableI18nLegacyMessageIdFormat`.

Currently, the `xi18n` command
(renamed  `extract-i18n` in CLI v11,
see [our blog post](/2020/11/11/angular-cli-11.0/))
uses 2 different algorithms to compute the message IDs in an application:

- a legacy one for messages in the template (based on ViewEngine)
- a modern one for messages in code

So if you have the same message `Welcome` in your HTML and in your TypeScript,
then you currently end up with two distinct messages to translate:

    <trans-unit id="7627914200888412251" datatype="html">
      <source>Welcome</source>
      <context-group purpose="location">
        <context context-type="sourcefile">src/app/app.component.ts</context>
        <context context-type="linenumber">13</context>
      </context-group>
    </trans-unit>
    <trans-unit id="5e3335d7f1a430ef14a91507531838c57138b7f2" datatype="html">
      <source>Welcome</source>
      <context-group purpose="location">
        <context context-type="sourcefile">src/app/app.component.html</context>
        <context context-type="linenumber">2</context>
      </context-group>
    </trans-unit>

The legacy method is also not very good at handling spaces in ICU expressions for example.

This new `enableI18nLegacyMessageIdFormat` option can be set to `false`
(in the Angular compiler options of your TS config)
to use the modern algorithm both in the code and in the templates,
resulting in the same ID and a single message to translate:

    <trans-unit id="7627914200888412251" datatype="html">
      <source>Welcome</source>
      <context-group purpose="location">
        <context context-type="sourcefile">src/app/app.component.ts</context>
        <context context-type="linenumber">13</context>
      </context-group>
      <context-group purpose="location">
        <context context-type="sourcefile">src/app/app.component.html</context>
        <context context-type="linenumber">2</context>
      </context-group>
    </trans-unit>

Note that the option will be set to `false` in a newly generated CLI project
(as this will be the default in the long run).
You can of course change it in your applications by adding it to your Angular compiler options.

## ViewEncapsulation

Angular v6.1 introduced a new option called `ShadowDom` to replace the deprecated `Native` option.
You can check out why in [our blog post](/2018/07/26/what-is-new-angular-6.1/) from 2 years ago.
It's now time to say goodbye to `Native`: it has been removed from the codebase.
A migration will automatically replace it with `ShadowDom` in your application
if you were still using it.

## waitForAsync

The `async()` helper has been deprecated and renamed `waitForAsync`
in [v10.1](/2020/09/03/what-is-new-angular-10.1/).
So you've probably replaced it everywhere to get rid of the TSLint warnings,
but if you did not yet, there is now an automatic migration to do it for you.

Check out why you can probably get rid of `waitForAsync` anyway
in our [previous blog post](/2020/09/03/angular-cli-10.1/)


All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!