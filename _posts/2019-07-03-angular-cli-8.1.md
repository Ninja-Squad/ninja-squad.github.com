---
layout: post
title: What's new in Angular CLI 8.1?
author: cexbrayat
tags: ["Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular CLI 8.1 is out! Read all about the new options for several commands and changes in the default configuration!"
---

[Angular CLI 8.1.0](https://github.com/angular/angular-cli/releases/tag/v8.1.0) is out!✨

Of course this brings us the support of the brand new Angular 8.1 version,
but also a lot of new features.

If you want to upgrade to 8.1.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (7.2.1 for example), and the target version (8.1.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/7.2.1...8.1.0](https://github.com/cexbrayat/angular-cli-diff/compare/7.2.1...8.1.0).
It can be a great help along the official `ng update @angular/core @angular/cli` command.
You have no excuse for staying behind anymore!

Let's see what we've got in this release,
and start with new options for several commands.

## Fun with flags

### ng generate component --skip-selector

It is now possible to generate a component without a selector,
by using the `--skip-selector` option.
This can be handy when you are generating components
that will only be instantiated dynamically,
for example by the router.
In that case, the component doesn't really need a selector,
so this option allows you to generate a component skeleton without one.

### ng generate module --route

The `module` schematics can now take a `--route` option to indicate
that you want to generate a lazy-loaded module.
For example:

    ng generate module admin --module users --route admin

will generate a new module `AdminModule` in its own directory,
as it already previously did.
But it will now also automatically add a route (here `admin`),
to lazy-load this module in the (already existing in my example) `users.module.ts`:

    export const USERS_ROUTES: Routes = [
      ...
      // automatically added by the schematic
      { path: 'admin', loadChildren: () => import('../admin/admin.module').then(m => m.AdminModule) }
    ];

    @NgModule({
      imports: [CommonModule, ..., RouterModule.forChild(USERS_ROUTES)],
      declarations: [...]
    })
    export class UsersModule {}

Note that it also creates a new component `AdminComponent`,
already registered in the route configuration of the new `AdminModule`:

    const routes: Routes = [
      { path: '', component: AdminComponent }
    ];

    @NgModule({
      declarations: [AdminComponent],
      imports: [CommonModule, RouterModule.forChild(routes)]
    })
    export class AdminModule { }

### ng test --include

You can now specify a file or a directory when running `ng test`
thanks to the new `--include` flag:

    # all specs in src/app/admin/*
    ng test --include app/admin
    # just src/app/user.service.spec.ts
    ng test --include app/user.service.spec.ts

You could already focus a test suite by changing the `describe`
function to `fdescribe` or the `it` function to  `fit`,
but `ng test` was still rebuilding all your tests.
By specifying `--include`, only the provided files are rebuilt,
so it's faster and doesn't care if you have compilation errors in other files 🌈.
And of course, you won't forget to replace `fdescribe`
by `describe` before committing anymore.

### ng doc --version

`ng doc` is not very well-known but it is quite handy,
as you can search the official documentation directly from your command line.
For example `ng doc component` opens your browser to the search results for component
on angular.io.
The command now allows to specify a specific version to search,
for example `ng doc --version 6 component`.
It is also possible to use `ng doc --version next`
to search the docs of the next Angular version.
And if you don't specify a version,
the command now searches the docs for the Angular version you are using in your project
(whereas it was looking in the docs of the most recent Angular version until now).
I'm really happy about this tiny new feature,
because it was the [first open-source contribution of a developer](https://github.com/angular/angular-cli/pull/14788)
I mentored during the [HackCommitPush](http://hack-commit-pu.sh/) event in Paris! 🚀

### ng build --cross-origin

You can now define the crossorigin attribute setting of elements that provide CORS support.
3 values are currently possible, very similar to what the
[official specification allows](https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_settings_attributes):
- `none` which doesn't do anything and is the default. CORS will not be used at all.
- `anonymous` which automatically adds `crossorigin="anonymous"` to your scripts. There will be no exchange of user credentials via cookies, client-side SSL certificates or HTTP authentication, unless it is in the same origin. That still checks for the origin though.
- `use-credentials` which automatically adds `crossorigin="use-credentials"` to your scripts,
meaning that user credentials will be needed even if the file is from the same origin.

### ng upgrade --allow-dirty

`ng upgrade` has now a new `--allow-dirty` option
to allow updating when the repository contains modified or untracked files.
Previously, trying to run `ng upgrade` in a project with unsaved modifications
was always resulting in an error.

## AoT by default for Ivy

The framework team has been working hard at squashing bugs in Ivy,
and also improved the build mechanisms,
resulting in faster AoT builds.
The CLI team now considers that the performances with AoT and Ivy enabled
are good enough to always serve your application with AoT enabled.
If you generate a new project with `--enable-ivy`,
you'll see that the `aot` option in `angular.json`
is now `true` by default.
In their experiments, the CLI team found that the AoT builds with Ivy enabled
were much faster than with View Engine,
and pretty much on par with JiT builds.
I gave it a try on one of our projects,
and here are the results of how much time rebuilds are taking after a modification:

    Ivy disabled, JiT mode: 190-250ms (initial 11.5s)
    Ivy disabled, AoT mode: 630-1700ms (initial 11.8s)
    Ivy enabled, AoT mode: 210-270ms (initial 13.0s)

So I have a slightly slower initial compilation,
but then the AoT rebuilds are roughly as fast as the JiT rebuilds without Ivy✨!

## TypeScript configuration changes

A side-note about the TypeScript configuration to conclude.
If you check out the
[differences between version 8.0 and 8.1](https://github.com/cexbrayat/angular-cli-diff/compare/8.0.0...8.1.0),
you'll notice that the `tsconfig.json` file lost the `emitDecoratorMetadata` option.
This option was only needed for JiT development
for the dependency injection (you can [read an old blog post of mine about that](/2016/12/08/angular-injectable/)).
As it was only useful for that use-case,
the CLI is now handling it itself when building your application in dev mode.
So you can now remove this option from your project!

The default configuration now includes `downlevelIteration`,
a TS compiler option to enable iterating over iterators.
Check out [this article](https://mariusschulz.com/blog/typescript-2-3-downlevel-iteration-for-es3-es5)
if you want to have a better understanding of this option.

You will also note that two `angularCompilerOptions` are now enabled by default:

    "angularCompilerOptions": {
      "fullTemplateTypeCheck": true,
      "strictInjectionParameters": true
    }

The first one is one of my favorites,
as it allows a deeper check of your templates.
I [explained this option](/2017/11/02/what-is-new-angular-5/)
when it was introduced in Angular 5.0.
`strictInjectionParameters` errors when an injection type can't be determined.

As you can see, this 8.1 release was packed with new features!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
