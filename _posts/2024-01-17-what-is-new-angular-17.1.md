---
layout: post
title: What's new in Angular 17.1?
author: cexbrayat
tags: ["Angular 17", "Angular"]
description: "Angular 17.1 is out!"
---

Angular&nbsp;17.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/17.1.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## TypeScript 5.3 support

Angular v17.1 now supports TypeScript 5.3. This means that you can use the latest version of TypeScript in your Angular applications. You can check out the [TypeScript 5.3 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-3/) to learn more about the new features.

## Inputs as signals

In Angular v17.1, a new feature was added to allow the use of inputs as signals.
This is a first step towards signal-based components.
The framework team added an `input()` function in `@angular/core`.

```ts
@Component({
  standalone: true,
  selector: 'ns-pony',
  template: `
    @if (ponyModel(); as ponyModel) {
      <figure>
        <img [src]="imageUrl()" [alt]="ponyModel.name" />
        <figcaption>{{ ponyModel.name }}</figcaption>
      </figure>
    }
  `
})
export class PonyComponent {
  ponyModel = input<PonyModel>();
  imageUrl = computed(() => `assets/pony-${this.ponyModel()!.color}.gif`);
}
```

As you can see in the example above, the `input()` function returns a signal,
that can be used in the template or in computed values
(which would be the modern equivalent of `ngOnChanges`).

It can be undefined though,
hence the `@if` in the template and the `!` in the computed value.

If an input is mandatory,
you can use the `input.required()` version of the function:

{% raw %}
```ts
@Component({
  standalone: true,
  selector: 'ns-pony',
  template: `
    <figure>
      <img [src]="imageUrl()" [alt]="ponyModel().name" />
      <figcaption>{{ ponyModel().name }}</figcaption>
    </figure>
  `
})
export class PonyComponent {
  ponyModel = input.required<PonyModel>();
  imageUrl = computed(() => `assets/pony-${this.ponyModel().color}.gif`);
}
```
{% endraw %}

You can also provide a default value, an alias, and a transformer function.
Here the `ponySpeed` field is aliased as `speed`,
provided with a default value, and transformed to a number (even if the input is a string):

```ts
ponySpeed = input(10, {
  alias: 'speed',
  transform: numberAttribute
});
```

You can also use the signal as the source of an observable,
to trigger an action when the input changes.
For example, to fetch data from a server:

```ts
export class PonyComponent {
  ponyService = inject(PonyService);
  ponyId = input.required<number>();
  // entity fetched from the server every time the ponyId changes
  ponyModel = toSignal(toObservable(this.ponyId)
    .pipe(switchMap(id => this.ponyService.get(id))));
  imageUrl = computed(() => `assets/pony-${this.ponyModel()!.color}.gif`);
}
```

When coupled with the recent addition to the router called "Component Input Binding",
where the router binds the route parameters to the inputs of a component,
it can lead to an interesting pattern.
Note that the input `transform` is necessary as the router parameters are strings:

```ts
ponyId = input.required<number, string>({
  transform: numberAttribute
});
```

This behavior is enabled via `withComponentInputBinding` in the router configuration:

```ts
provideRouter(
  [
    {
      path: 'pony/:ponyId',
      component: PonyComponent
    }
  ],
  withComponentInputBinding()
),
```

## Zoneless change detection

The framework is making progress towards zoneless change detection.
A new private API called `ɵprovideZonelessChangeDetection` was added to `@angular/core`.
When you add this provider to your application,
the framework no longer relies on Zone.js for change detection (and you can remove it from the application).

So how does it work?
Every time an event is fired, an input is set, an output emits a value, an `async` pipe receives a value, a signal is set, `markForCheck` is called, etc.,
the framework notifies an internal scheduler that something happened.
It then runs the change detection on the component marked as dirty.
But this doesn't catch what Zone.js usually does:
a `setTimeout`, a `setInterval`, a `Promise`, an `XMLHttpRequest`, etc.

But that shouldn't be a problem because the idea is that when a `setTimeout`, `setInterval` or `XMLHttpRequest` callback is triggered, and you want it to update the state of the application, you should do it by modifying a signal, which will in turn trigger change detection.

This is far from being complete, as the "private API" part suggests.
However, it indicates that the framework is making progress towards zoneless change detection.


## Router

The router now has an `info` option in the `NavigationExtras` 
that can be used to store information about the navigation.
Unlike the `state` option,
this information is not persisted in the session history.
The `RouterLink` directive now supports this option as well:

```html
<a [routerLink]="['/pony', pony.id]" [info]="{ ponyName: pony.name }">{{ pony.name }}</a>
```


## Control flow migration

The control flow migration is still experimental but has been improved
with a ton of bug fixes and new features.
It now removes the useless imports from your component imports after the migration.
It also now has a new option `format` to reformat your templates after the migration.
The option is `true` by default, but can be turned off:

```sh
ng g @angular/core:control-flow --path src/app/app.component.html --format=false
```

## INFINITE_CHANGE_DETECTION

This is not a new feature, but this bug fix is worth mentioning.
Angular v17.1 fixes a bug for transplanted views, but this will also be useful for signals.

The framework now runs change detection while there are still dirty
views to be refreshed in the tree.
If too many loops are detected, the framework will throw an error: `INFINITE_CHANGE_DETECTION`.

This will remind the oldest Angular developers of the good old days of AngularJS,
when we had to be careful with infinite digest loops 👴.

Angular v17.1 will throw this error if you have 100 loops in a row at the moment.


## Angular CLI

### Vite v5

The Angular CLI v17.1 now uses Vite v5 under the hood.
Vite v5 was recently released,
you can read more about it in the [official blog post](https://vitejs.dev/blog/announcing-vite5).

### Application builder migration

If you haven't migrated to the new application builder yet,
there is now a migration schematic to help you with that:

```sh
ng update @angular/cli --name=use-application-builder
```

### Keyboard shortcuts in dev server

After running `ng serve`, you can now see in the terminal the following line:

```sh
Watch mode enabled. Watching for file changes...
  ➜  Local:   http://localhost:4200/
  ➜  press h + enter to show help
```

If you press 'h + enter', you will see the list of available keyboard shortcuts:

```sh
Shortcuts
press r + enter to force reload browser
press u + enter to show server url
press o + enter to open in browser
press c + enter to clear console
press q + enter to quit
```

Quite cool!

### Running tests with Web Test Runner

An experimental builder is now available to run tests with
[Web Test Runner](https://modern-web.dev/docs/test-runner/overview/).
It is _very_ early stage, but you can try it out by replacing the `karma` builder with `web-test-runner` in the `angular.json` file:

```json
"test": {
  "builder": "@angular-devkit/build-angular:web-test-runner",
}
```

You then need to install the `@web/test-runner` package,
and here you go!
Running `ng test` will now use Web Test Runner instead of Karma
(and bundle the files with the `application` builder, which uses esbuild,
and not Webpack as the current `karma` builder does).

A lot of options aren't available yet,
so you can't change the browser for example (it only runs in Chrome for now),
or define reporters, or use any kind of configuration.

In the future, we will be able to define a configuration file for Web Test Runner,
use other browsers (WTR supports using Playwright to download and run tests in other browsers), etc.

This builder will probably be the default in the future,
as Karma is now deprecated.

### loader option

The `application` builder gained a new `loader` option.
It allows defining the type of loader to use for a specified file extension.
The file matching the extension can then be used
within the application code via an import.

The available loaders that can be used are:

- `text` which treats the content as a string
- `binary` which treats the content as a Uint8Array
- `file` which emits the file and provides the runtime location of the file
- `empty` which considers the content to be empty and will not include it in bundles

For example, to inline the content of SVG files into the bundled application,
you can use the following configuration in the `angular.json` file:
```
loader: {
    ".svg": "text"
}
```

Then an SVG file can be imported in your code with:
```
import content from './logo.svg';
```

TypeScript needs to be aware of the module type for the import to prevent type-checking
errors during the build, so you'll need to add a type definition for the SVG file:

```
declare module "*.svg" {
  const content: string;
  export default content;
}
```

### Output location

It is now possible to customize the output location of the build artifacts:

```json
"outputPath": {
  "base": "dist/my-app",
  "browser": "",
  "server": "node-server",
  "media": "resources"
}
```

### Retain special CSS comments

By default, the CLI removes comments from CSS files during the build.
If you want to retain them because you use some tools that rely on them,
you can now set the `removeSpecialComments` option to `false` in the `optimization` section of your `angular.json` file:

```json
"optimization": {
  "styles": {
    "removeSpecialComments": false
  }
}
```

### Allowed CommonJS dependencies

You can now specify `*` as a package name in the `allowedCommonJsDependencies` option to allow all packages in your build:

```json
"allowedCommonJsDependencies": ["*"]
```

### --no-browsers in tests

You can now use the `--no-browsers` option when running tests with the CLI.
This will prevent the browser from opening when running tests,
which can be useful if you are inside a container for example.
This was already possible by setting the `browsers` option to `[]` in the `karma.conf.js` file, but not from the CLI command.

```sh
ng test --no-browsers
```

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
