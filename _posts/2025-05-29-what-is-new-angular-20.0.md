---
layout: post
title: What's new in Angular 20.0?
author: cexbrayat
tags: ["Angular 20", "Angular"]
description: "Angular 20.0 is out!"
---

Angular&nbsp;20.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/20.0.0">
    <img class="rounded img-fluid" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

It sounds a bit incredible that we are already at version 20,
but here we are!
This is a major release with a lot of new features,
improvements and breaking changes.
Let's dive into the details of this new version
and also look at what to expect in Angular v21 👀.

## TypeScript v5.8 and Node v20 required

Angular v20 now requires TypeScript v5.8 (it has been supported since v19.2).
You can check out the [TypeScript v5.8 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-8-rc/)
to learn more about the new features.
Older versions of TypeScript are not supported anymore.

Angular v20 also requires Node v20.
Angular v19 was the last version to support Node v18.

## 2025 Angular style guide

A major update of the Angular style guide has been released,
with a lot of recommendations removed to focus on the most important ones.

You can check it out at [angular.dev/style-guide](https://angular.dev/style-guide).

The recommended naming convention for files has changed,
with most of the suffixes being removed.
A user component should now be named `User`,
or `UserCard`, or `UserPage` (for example) instead of `UserComponent`.
in a file named `user.ts` (or `user-card.ts`, or `user-page.ts`)
instead of `user.component.ts`.
The same applies to directives, pipes, etc.
The CLI has been updated to use this new naming convention by default,
as explained below.

The folder structure has also evolved, with the removal of the top-level `app` folder.
The CLI does not comply with this new structure yet,
but I imagine it will be the new default soon.

Among other notable changes,
it is now recommended to use `protected` for properties that are only accessed in the template,
and `readonly` for all the properties that are initialized by Angular,
like `input()`, `output()`, etc.

It is also now official that `[class.something]` and `[style.something]`
are the recommended way to bind classes and styles in templates over `ngClass` and `ngStyle`.

This new naming convention and style guide
is a big change for Angular,
and even if new projects will use it by default,
existing projects will either have to migrate to it
or keep using the old style guide (see the CLI section below for more details).

## Signal APIs are stable

Signals are the future of Angular reactivity,
and the Angular team has been working hard to stabilize the APIs around them.

Most of the APIs related to signals are now stable:

- `effect()`
- `toSignal()`
- `toObservable()`
- `afterRenderEffect()`
- `afterNextRender()`
- `linkedSignal()`
- `PendingTasks`

Two developer preview APIs are being renamed.

The biggest change is that `afterRender()` has been renamed to `afterEveryRender()`
and is now stable.
Unlike stable APIs, the old name wasn't kept for backward compatibility,
and no migration was provided.

`TestBed.flushEffects()`,
which was introduced in v17 to trigger pending effects in tests,
has been deprecated and should now be replaced with `TestBed.tick()`.
This new method runs the entire synchronization process instead of
manually triggering the effects in a way that would not happen in a running application.
`flushEffects` had a special treatment and was kept around as deprecated
because it was not visible on the docs that it was in developer preview 🤷.

Note that `effect()` lost its `forceRoot` option, which was not very useful,
and `toSignal()` lost its `rejectErrors` option, which was deemed a not-so-good practice.

`pendingUntilEvent()`, the RxJS operator [introduced in v19](/2024/11/19/what-is-new-angular-19.0/), has been promoted from experimental to developer preview.

## Zoneless is now in developer preview

If signals are the future of Angular reactivity,
zoneless change detection is the future of Angular change detection.

Zoneless is no longer experimental, but not yet stable.
It is now in developer preview and, to reflect that,
the provider has been renamed from `provideExperimentalZonelessChangeDetection`
to `provideZonelessChangeDetection`.
Similarly, `provideExperimentalCheckNoChangesForDebug` has been renamed to `provideCheckNoChangesForDebug`
(check [our article about Angular v18 to learn more about these providers](/2024/05/22/what-is-new-angular-18.0/)).

The `ng new --experimental-zoneless` flag has also been renamed to `--zoneless` in the CLI
and the CLI now asks if you want to enable it when creating a new project.

## Deprecations, removals and breaking changes

As usual with major releases,
Angular v20 comes with a few deprecations, removals, and breaking changes.

The structural directives `ngIf`, `ngFor` and `ngSwitch`
are now officially deprecated in favor of the
[control flow syntax](/2023/10/11/angular-control-flow-syntax/).
Note that structural directives in general are not deprecated,
but only the `ngIf`, `ngFor`, and `ngSwitch` ones.
These directives will likely be removed in Angular v22.
The control flow migration can help you migrate
and you will be asked if you want to run it during `ng update`.

The `fixture.autoDetectChanges()` method previously accepted a boolean parameter,
now deprecated due to limited utility.
If you used `fixture.autoDetectChanges(true)`,
you can now just use `fixture.autoDetectChanges()`.
`fixture.autoDetectChanges(false)` is now even throwing if used in a zoneless test.

`TestBed.get()` has finally been removed
(it had been deprecated in Angular v9).
An automatic migration will run when you `ng update`
to replace these calls with `TestBed.inject()` if you still have some.

Probably not much used, but worth noting,
the `InjectFlags` enum is also removed.
As explained in our [Angular v14.1 blog post](/2022/07/21/what-is-new-angular-14.1/),
these flags were deprecated in v14.1
when most of the DI APIs like `inject()` started to accept an options object instead.
You probably did not have the time to use it,
but a migration is nonetheless run during `ng update`
to take care of it if that was the case.

The `DOCUMENT` token moved from `@angular/common` to `@angular/core`.
Here as well, a migration will rewrite the imports in your project if needed.

The `@angular/platform-browser-dynamic` package
has been deprecated in favor of `@angular/platform-browser`,
but here you'll have to manually update the imports as there is no schematics for now.
You can then remove the dependency from your project.

Another package got deprecated but with no replacement `@angular/platform-server/testing`.
It is now recommended to use e2e tests to check your SSR applications.

The HammerJS integration has been deprecated.
HammerJS has not been updated for the past 8 years
so the team is planning to remove all HammerJS entities
from the framework in the future.

Another breaking change that may go unnoticed
is the removal of the generated `ng-reflect-*` attributes
by default.
These attributes have been present in dev mode since v2.4
for historical debugging reasons (I think the old devtools used them).
If you rely on this in your application, which is a bad idea,
you can re-enable them in dev mode using `provideNgReflectAttributes()`.

## Templates

Angular v20 supports a few new things in templates.

Exponentiation is now supported in templates, using the `**` operator.

{% raw %}

```html
<p>{{ 2 ** 3 }}</p>
```

{% endraw %}

Angular v19.2 introduced
[the support for template strings in expressions](/2025/02/26/what-is-new-angular-19.2/),
and we now have the ability to use tagged template literals as well:

{% raw %}

```html
<p>{{ translate`app.title` }}</p>
```

{% endraw %}

`void` is now also supported in template expressions.
This can be useful to ignore the return value of a function,
for example for event listeners (as returning `false` prevents the default behavior):

```html
<button (click)="void selectUser()">Select user</button>
```

`in` is supported as well in v20:

```html
@if ('invoicing' in permissions) {
  <a routerLink="/invoices">Invoices</a>
}
```

## Extended diagnostics

As a proof that structural directives are still alive,
a new extended diagnostic has been added to check if
you're using a structural directive without importing it: `missingStructuralDirective`.

If that's the case, you'll get the [following error](https://next.angular.dev/extended-diagnostics/NG8116)
with `strictTemplates` enabled if you are using `*ngTemplateOutlet` without importing it for example:

```
[ERROR] NG8116: A structural directive `ngTemplateOutlet` was used in the template without a corresponding import in the component.
Make sure that the directive is included in the `@Component.imports` array of this component.
```

Another extended diagnostic has been added to check that a function is properly invoked when used in a track expression of a `@for` block.
For example, `@for (user of users; track getUserId) {` throws the following error:

```
[ERROR] NG8115: The track function in the @for block should be invoked: getUserId(/* arguments */) [plugin angular-compiler]
```

A last one has been added to check if you are mixing nullish coalescing
with boolean operations in templates.
TypeSCript forces you to use parentheses in this case when using the nullish coalescing operator (`??`)
and a boolean operator (`&&`, `||`, etc.) in the same expression like `a ?? b && c`.

In templates, there was no such check before
and it is now recommended to use parentheses to avoid confusion.
You now need to write {%raw%}`{{ a ?? (b && c) }}`{%endraw%} instead of {%raw%}`{{ a ?? b && c }}`{%endraw%} for example,
otherwise you'll get the [following error](https://next.angular.dev/extended-diagnostics/NG8114):

```
[ERROR] NG8114: Parentheses are required to disambiguate precedence when mixing '??' with '&&' and '||'.
```

To disable these checks, you can add the following to your `tsconfig.json` file:

```json
"angularCompilerOptions": {
  "extendedDiagnostics": {
    "checks": {
      "missingStructuralDirective": "suppress",
      "unparenthesizedNullishCoalescing": "suppress",
      "uninvokedTrackFunction": "suppress"
    }
  }
}
```

## Host type checking

The type-checking has been improved in an area that was not type-checked before.

If you ever used the `host` metadata in
a directive or component decorator
(or the `@HostBinding()` and `@HostListener()` decorators),
then you may have noticed this was not checked by the compiler.
This is no longer the case in v20 if you use a new option of the compiler
called `typeCheckHostBindings` (this is already configured in new CLI project):

```json
"angularCompilerOptions": {
  "typeCheckHostBindings": true,
```

The compiler now checks that:

- the left side of the host binding/listener is valid for the element on which the component/directive is applied to
- the right side references something that exists in the component/directive class

For example, the following code errors as `value` does not exist on labels:

```ts
@Directive({
 selector: 'label',
 host: {
    '[value]': 'value()'
    // ☝️ [ERROR] NG8002: Can't bind to 'value' since it isn't a known property of 'label'
  }
}
export class FormLabel {
```

The type checker is smart enough to understand if the binding works with _all_
elements declared in the selector.

It also checks the right side of the binding to see if it exists.
So the following throws as well:

```ts
@Directive({
  selector: 'label',
  host: {
    '[class.text-danger]': 'isInvalid'
    // ☝️ [ERROR] NG9: Property 'isInvalid' does not exist on type 'FormLabel'.
```

Note that extended diagnostics are not running on these bindings for now,
so it does not catch if a signal is not called for example.

## Error handling

Some changes have been made
to avoid letting errors slip through the cracks.

A new `provideBrowserGlobalErrorListeners` provider has been added in Angular v20.
It allows to register global error listeners in the browser.
This is useful to catch errors that are not caught by Angular.
This provider is automatically added to the `app.config.ts` file
when you create a new project with the CLI.

Note that the errors thrown in event listeners are now reported
to the internal Angular error handler, which means that
you may see errors in tests that were not reported before.
You can fix them or use `rethrowApplicationErrors: false`
in `configureTestingModule` as a last resort.

## Dynamically created components

The `createComponent()` API ([v14.2](/2022/08/26-what-is-new-angular-14.2/))
allows to dynamically create components to manually insert them.

The function (and `ViewViewContainerRef.createComponent`) gained
a few possible options in v20.
You can specify the directives to apply to dynamically created components,
as well as the input values you want to provide to the component (or its applied directives) using the brand new `inputBinding()` function.
It is also possible to declare two-way bindings with `twoWayBinding()`
and to listen to outputs with ``:

```ts
const user = createComponent(User, {
  bindings: [
    twoWayBinding("name", name)
  ],
  // ☝️ two-way binding with the signal `name`
  directives: [
    {
      type: CdkDrag,
      // ☝️ applies the Drag directive
      bindings: [
        inputBinding("cdkDragLockAxis", () => 'x')),
        // ☝️ binds its lock axis to 'x' (has to be a signal or a function)
        outputBinding<CdkDragEnd>('cdkDragEnded', event => console.log(event))
        // ☝️ listens to the end of the dragging action
      ]
    }
  ]
});
```

This is a step up from the current `setInput` that could be called on the created component,
but that would set the input _after_ the first change detection.
We can also imagine that this could be used in other APIs like `TestBed.createComponent()`
in the future?

## Forms

Still no signal support in the forms APIs,
but the Angular team is working on it.
Check out our sneak peek of the new forms APIs below 😉.

The forms APIs are relatively quiet in v20,
but we have two minor changes worth mentioning.

It is now possible to reset forms without emitting events
with `userForm.resetForm(undefined, { emitEvent: false })`.

We also now have a `markAllAsDirty()` method on `AbstractControl`,
which allows us to mark a control and all its descendants as dirty.
The `markAllAsTouched()` method already existed
but for some reason, `markAllAsDirty()` was not available until v20.

## Router

### Scroll options

It is now possible to pass options to
`ViewportScroller.scrollToAnchor()/scrollToPosition()`.
All native scroll [options]() are supported,
for example `behavior`:
`this.scroller.scrollToPosition([0, 10], { behavior: 'smooth' })`.

### Resolvers

A good news for those using resolvers in the router:
they can now read the resolved data from the parent route:

```ts
provideRouter([
  {
    path: "users/:id",
    resolve: { user: userResolver },
    // ☝️ user resolver in the parent route
    children: [
      {
        path: "posts",
        resolve: { posts: postsResolver },
        // ☝️ route.data.user is now available in the posts resolver
        component: UserPosts,
      },
      // ...
    ],
  },
]);
```

### Asynchronous redirects

When defining a redirect in the route configuration,
the `redirectTo` option accepts a function that can now be asynchronous
by returning a promise or an observable that resolves to a redirect.
This is technically a breaking change as the returned type evolved.

### Custom elements support

Developers writing Web Components out there will be pleased
to know that it is now possible to use a custom element
as the host of a `RouterLink`.

## Http

### Resource API changes

The resource APIs continue to evolve with the feedback from the RFCs,
slowly shaping them into a more stable API that we will use to build future applications.

`resource()` had its `query` parameter renamed to `params`
and `rxResource()` had its `loader` parameter renamed to `stream`.
The `reload` method has been moved from the base `Resource` class
to the `WritableResource` class which means only mutable resources can now be reloaded.

`httpResource` also received some changes in v20
(you can check out [our previous article](/2025/02/20/angular-http-resource/)
to refresh your memory):

- the `map` option has been renamed `parse`;
- the HTTP `context` can now be specified in the options;
- the request must now always be reactive.

The last point means that you can no longer write
`httpResource<Array<UserModel>>('/users')`
but now have to use `httpResource<Array<UserModel>>(() => '/users')`.

### keepalive support

The `HttpClient` now supports the
[keepalive](https://developer.mozilla.org/en-US/docs/Web/API/Request/keepalive)
option when using the Fetch API (which is the case if you use the `withFetch()` option).
When set to `true`, the browser will not abort the associated request
if the page that initiated it is unloaded before the request is complete.

## Profiling

A new `enableProfiling()` function has been added to `@angular/core`.

If called in your application, it will enable some profiling features in Angular that will help you to analyze the performance of your application.
Angular internally uses the [Performance API](https://developer.mozilla.org/en-US/docs/Web/API/Performance/mark) to tag the usage of some of the framework APIs (change detection, template, outputs, defer, etc.).
You can then use the Chrome Devtools to record a performance profile of your application and analyze the time spent in Angular, using the custom track added by Angular:

<p style="text-align: center;">
  <img class="img-fluid" src="/assets/images/2025-05-29/angular-performance-devtools.png" alt="Angular custom track in Chrome Devtools" />
</p>

This can be useful to identify why a specific page
or the startup of an application is slow.

## Devtools

The Angular Devtools now mark `OnPush` components as such in the component tree.
Deferred blocks are now also displayed.
The signal support is also improving
and we should soon be able to see the signals tree in the devtools.

## SSR

On the SSR side,
the `withI18nSupport()` and `withIncrementalHydration()` APIs have been stabilized.

The schematics now generate a server based on Express v5,
and the code is slightly different as you can see
in our [angular-cli-ssr-diff](https://github.com/cexbrayat/angular-cli-ssr-diff/compare/19.0.0...20.0.0).

`provideServerRendering()` and `provideServerRoutesConfig(serverRoutes)`
are now combined into a single `provideServerRendering(withRoutes(serverRoutes))` function.
`provideServerRendering` is now in `@angular/ssr` instead of `@angular/platform-server`.
A migration will take care of this refactoring for you if you run `ng update`.

When generating a new application with the CLI the `--server-routing` option
has been removed and the `--ssr` option now generates a server with routing support by default.

## Angular CLI

As you can see in [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff/compare/19.2.0...20.0.0),
the project generated by the CLI has changed a lot.

Let's dive into the changes.

### Updated naming for 2025 style guide

As mentioned above, the Angular style guide has changed a lot.
The CLI has been updated to use the new naming convention by default.
The generated files when running `ng g c user` are now named `user.ts` instead of `user.component.ts`,
`user.html` instead of `user.component.html`,
and `user.css` instead of `user.component.css`, etc.
The name of a component is now `User` instead of `UserComponent`.
You can opt out of this behavior by using the `--type=component` option
when generating a component,
or by setting the `type` option to `component` in the CLI configuration file.

If you want to, you can generate a component template with the `.ng.html` extension
by using `ng g c user --ng-html` or by setting the `ngHtml` option to `true` in the CLI configuration file (the option is disabled by default).

The same goes for:

- directives: `ng g d highlight` will generate a `highlight.ts`
  file instead of `highlight.directive.ts`,
  and the class will be named `Highlight` instead of `HighlightDirective`,
  except if you use the `--type=directive` option.
- same thing for services: `ng g s user` will generate a `user.ts`
  file instead of `user.service.ts`,
  and the class will be named `User` instead of `UserService`,
  except if you use the `--type=service` option.

For pipes, resolver, interceptors guards, and modules:
the names are the same as previously but the separator in the file name becomes
a dash instead of a dot by default.

For example, `ng g p from-now` will generate a `from-now-pipe.ts`
file instead of `from-now.pipe.ts`, except if you use the `--type-separator=.` option
The class will still be named `FromNowPipe` though.

To keep the same behavior as before,
an automatic migration has been added to the CLI
to configure `angular.json` to use the old naming convention:

```json
"schematics": {
  "@schematics/angular:component": { "type": "component" },
  "@schematics/angular:directive": { "type": "directive" },
  "@schematics/angular:service": { "type": "service" },
  "@schematics/angular:guard": { "typeSeparator": "." },
  "@schematics/angular:interceptor": { "typeSeparator": "." },
  "@schematics/angular:module": { "typeSeparator": "." },
  "@schematics/angular:pipe": { "typeSeparator": "." },
  "@schematics/angular:resolver": { "typeSeparator": "." }
}
```

### TypeScript configuration

There are two big changes in the TypeScript configuration.

The `module` option is now set to `preserve` instead of `es2022`
to reflect more accurately how modern bundlers work.
This removes the need to set the `esModuleInterop` and `moduleResolution` options.

The other change is more notable:
the generated `tsconfig.json` file now uses a "solution" style
configuration with references
to `tsconfig.app.json` and `tsconfig.spec.json`
(instead of having the `tsconfig.app.json` and `tsconfig.spec.json` files
extend the base `tsconfig.json`).
This should greatly help tools and IDEs understand the project structure!

### Simplified angular.json

A new project now directly uses the `@angular/build` package
instead of `@angular-devkit/build-angular`.
This removes the need to install this package and all the
Webpack-related transitive dependencies
and results in a big reduction in the `node_modules` installed (nearly 200Mb!).

If you're updating a CLI project, a migration will update
your `angular.json` file to use the new builder
if you aren't already using it.

The `angular.json` file has also been simplified a bit,
with some options like `outputPath`, `index`, and `scripts` removed
as they now have a sensible default value.

### Browserslist configuration

The CLI has been using `browserslist` for a while now,
and you can tweak the supported browsers by generating the `browserslist` file
using `ng generate config browserslist`.

The generated configuration used to target the last 2 versions of each browser,
which is a moving target and depends on the time of the build.

The Angular team changed its support policy
and now targets the "widely available" baseline.
It includes browsers released less than 30 months
of the chosen date within Baseline's core browser set (Chrome, Edge, Firefox, Safari) and
targets supporting approximately 95% of web users (see https://web.dev/baseline).

The CLI now generates a `browserslist` file with the following content
for v20, targeting browsers released in the last 30 months:

```
Chrome >= 107
ChromeAndroid >= 107
Edge >= 107
Firefox >= 104
FirefoxAndroid >= 104
Safari >= 16
iOS >= 16
```

If you use a custom `browserslist` configuration with a different set of browsers,
you will see a warning like this:

```
One or more browsers which are configured in the project's Browserslist configuration fall outside Angular's browser support for this version.
Unsupported browsers:
chrome 106, chrome 105
```

### Sass package importers

Sass supports `pkg:` importers to import packages from package managers
(see [Sass blog post](https://sass-lang.com/blog/announcing-pkg-importers/)).
The CLI now supports this feature as well when using Sass as a preprocessor,
so you can write `@use 'pkg:@angular/material' as mat;` in your Sass files for example.

### Ahead of Time testing and code coverage for templates

If you've been using Angular for a while, you may remember a time when
we had both Ahead-of-Time (AoT) and Just-in-Time (JiT) compilation for our applications.
Ivy came around with a faster compiler, allowing us to always use AoT compilation.
The CLI introduced the support of AoT testing with the `ng test` command in v19.2,
but it was not really usable at that time,
mostly because the `TestBed` allows to overwrite component metadata
and this was not compatible with AoT compilation.

This has been fixed, and you can now use AoT compilation for your tests!
This is a great improvement for consistency,
as it allows you to run your tests in the same mode as your production code.

To do so, you can add the `"aot": true` option to your `angular.json` file:

```json
"test": {
  "builder": "@angular/build:karma",
  "options": {
    "aot": true,
```

Note that you may have to fix issues in your tests when switching to AoT compilation,
as you may have forgotten some required inputs in your tests for example.
There are still a few issues left with `overrideComponent` that you may run into as well.

Running tests with AoT compilation also provides code coverage for the templates,
which is a nice addition and may help to catch some untested parts of your components.

It looks like the test times are roughly the same with AoT compilation.

### Testing with Vitest 🚀

The CLI now supports running tests with [Vitest](https://vitest.dev/),
a fast and modern test framework that is based on Vite.

The Angular team is still looking for a good replacement for Karma
and Vitest was at first discarded as an option
when the team focused on Jest (v16) and Web Test Runner (in v17).
These Jest and WTR integrations are still experimental,
and have not been updated in a while.

In the meantime, Vitest has exploded in popularity in other ecosystems,
and the Angular team decided to give it a try.

A new builder has been added to the CLI, named `unit-test`.
You can use it by replacing the `@angular/build:karma` or `@angular-devkit/build-angular:karma` builders
with `@angular/build:unit-test` in your `angular.json` file.

```json
"test": {
  "builder": "@angular/build:unit-test",
  "options": {
    "tsConfig": "tsconfig.spec.json",
    "buildTarget": "::development",
    "runner": "vitest",
  }
}
```

With this configuration, you can remove all the karma and jasmine dependencies from your project and will need to install the `vitest` package instead.

Note the `runner` option which specifies `"vitest"` (but can also accept `"karma"`).
With this builder, you no longer need to configure how the tests should run with polyfills, assets, etc.
You must now use a `"buildTarget"` with one of your build configurations as a value.
Note that in my example above, I used the `development` build configuration,
which means that the tests will run with AoT compilation.

By default, Vitest runs in a Node environment,
and uses [jsdom](https://github.com/jsdom/jsdom)
to simulate a browser environment,
which you'll need to install as a dev dependency.

If you are migrating a project from Karma/Jasmine to Vitest,
you'll need to update your tests to use Vitest APIs instead of Jasmine ones.
You shouldn't have to add imports for the Vitest APIs though,
as the CLI configures them to be global.
To make sure your IDE picks them up,
replace the `jasmine` types in your `tsconfig.spec.json` file with `vitest/globals`:

```json
"types": ["vitest/globals"]
```

You can also run your tests in a real browser environment.
Vitest has a `browser` mode, which is still experimental
but works well enough.
You'll need to install the `@vitest/browser` package
and can remove the JSDOM dependency from your project.

```json
"runner": "vitest",
"browsers": ["chromium"], // can be "firefox", "webkit"
```

The browser will be downloaded automatically when you run your tests,
using either [playwright](https://playwright.dev/) or [WebdriverIO](https://webdriver.io/),
as the CLI indicates in the error message below when you run `ng test` without having one of these packages installed:

```
The "browsers" option requires either "playwright" or "webdriverio"
to be installed within the project.
Please install one of these packages and rerun the test command.
```

Once Playwright or WebdriverIO is installed,
you can run your tests in a real browser environment:
the CLI will download the browsers automatically
and run the tests in it 🚀.

The execution times are a bit slower than with Karma though for a complete run.
But the watch mode is faster, as it only runs the tests that are affected by the changes,
whereas Karma runs all the tests every time.

The watch mode is by default as with the current Karma builder,
but it is automatically disabled on CI or if there is no interactive terminal,
which is closer to what vitest does by default.
This means you no longer have to add the `--no-watch` option
to the `ng test` command to run the tests in CI.

Speaking of flags, there is a new one with this builder called `--debug`.
The debug mode only works with vitest as a runner,
and with jsdom or in browser mode using Playwright.
It hooks the Node Inspector into the test runner to allow you to debug your tests
by connecting to it with a debugger.

There are a few limitations with this new test runner as it is still experimental.
For example, you can't define a "setup" file to set up your tests as you can with Karma
which is usually very handy to add custom matchers or do some assertions after each test.
But the `unit-test` builder allows you to define a `providersFile` option,
which is a file that will be loaded before the tests are run,
with whatever providers you want to add to the test bed.
This is useful for setting up zoneless testing,
as you can add `provideZonelessChangeDetection()` in this file:

```ts
import { provideZonelessChangeDetection } from "@angular/core/testing";

export default [provideZonelessChangeDetection()];
```

You can't specify a Karma config file or Vitest config file for now,
which means that you can't run the tests in headless mode for example,
or configure a custom reporter.

You can configure a reporter or code coverage exclusions directly in the `angular.json` file though:

```json
"test": {
  "builder": "@angular/build:unit-test",
  "options": {
    "tsConfig": "tsconfig.spec.json",
    "buildTarget": "::development",
    "runner": "vitest",
    "reporter": ["html", "json"], // uses @vitest/ui
    "codeCoverage": true, // uses @vitest/coverage-v8
    "codeCoverageExclude": ["src/app/ignore.ts"]
  }
}
```

### Automatic Chrome workspace folders

The vite server now automatically serves a `com.chrome.devtools.json` file
that the Chrome Devtools automatically picks up
(behind a flag for now, but it will be enabled by default in the future).
This file contains the project location on your disk
and allows to directly edit source files from the Devtools,
with the changes being saved in the original files.

You can enable this feature in Chrome by following the [docs here](https://chromium.googlesource.com/devtools/devtools-frontend/+/main/docs/ecosystem/automatic_workspace_folders.md).
When done, you'll see a new "Workspace" tab in the Source panel of the Devtools.
You'll be asked to connect to the workspace,
and then you'll see a file tree with all the files in your project.
You can then open any file in the Devtools and edit it.
When saving the file, it will be saved in the original file on your disk
and the changes will be reflected in the application.

### Sourcemaps without sources

The CLI can now generate sourcemaps without the `sourcesContent` field
which contains the original source code.
To do so, you can set the `sourceMap` option to:

```json
"sourceMap": {
  "scripts": true,
  "styles": true,
  "sourcesContent": false
}
```

This can be useful if you want to deploy sourcemaps to production
to have better error reporting that includes the original source names,
but you don't want to expose the original source code to the users.

## Angular joins the AI train

As AI is everywhere nowadays, Angular could not avoid joining the hype train.
The Angular docs are now exposed in a text file for LLMs
at the root of the repository following the `llms-full.txt` emerging convention.
If added to your AI favorite tool's context,
it should help generate better Angular code.

## What to expect in Angular v21

The Angular team will probably communicate about these features soon,
but I can't resist sharing two projects that they have been cooking behind the scenes!

### Selectorless components 😲

The beginning of a new experiment started: selectorless components.
In the future, we may be able to use components and directives
without a selector in our templates
and without having to add the `imports` array in our component metadata!

```ts
import { User } from './user/user';
// ☝️ TS import is still necessary

import
@Component({
  template: '<User [name]="name()" (selected)="selectUser()" />',
  // but no Angular imports are needed! 😲
})
export class App {
```

Components can be used in templates without a selector
by using their class name directly.
Same thing for directives, but they currently require an `@` prefix:

```html
<User @CdkDrag(cdkDragLockAxis="y") [name]="name()" (selected)="selectUser()" />
```

Pipes can also be used without a name:

{% raw %}

```ts
import { FromNowPipe } from './from-now-pipe';

@Component({
  template: '<p>{{ date | FromNowPipe }}</p>'
})
export class App {
```

{% endraw %}

Super big warning: the syntax is far from being decided.
Only the compiler part has been done in v20,
so nothing of the above is testable for now
but we can already see that it opens a lot of possibilities.
A RFC should probably come soon.

### Signal Forms

In parallel, some prototyping has been done for signal forms.
Is it based on template forms or reactive forms?
Nope, it looks like it is going to be a brand new third way to write forms in Angular.
Let's say we have a `userModel` signal data we want to edit.
Angular will provide a `form()` function to get a `Field`,
a new class that owns the state of the form (valid, touched, etc).

This code below is only available in the prototyping branch,
so don't expect to use it in v20 😉:

```ts
@Component({
  selector: "user-form",
  imports: [FieldDirective],
  // ☝️ new directive
  template: `
    <form>
      <label>Username: <input [field]="userForm.username" /></label>
      <!-- ☝️ used to bind fields -->
      <label>Name: <input [field]="userForm.name" /></label>
      <label>Age: <input type="number" [field]="userForm.age" /></label>
    </form>
  `,
})
class UserFormComponent {
  userModel = signal<UserModel>({ username: "", name: "", age: 0 });
  protected readonly userForm: Field<User> = form<User>(
    // ☝️ form() is a new function and returns a Field
    userModel,
    // data to edit
    (userPath: FieldPath<User>) => {
      disabled(userPath.username, () => true, "Username cannot be changed");
      required(userPath.name);
      error(userPath.age, ({ value }) => value() < 18, "Must be 18 or older");
    }
    // ☝️ schema that allows to define the dynamic behavior of fields (enabled/disabled)
    // and the validation, with provided and custom validators
  );
}
```

If you want to learn more, you can check out the
[current design doc](https://github.com/angular/angular/blob/37c5ff61c69cc0460e9540800ba2cecceacf9e11/packages/forms/experimental/docs/signal-forms.md)
which is really interesting or wait for the probably not very far RFC that will discuss all this.

## Summary

That were a lot of new features in Angular v20!

v21 will hopefully bring us the first usable version of signal forms
and/or this new selectorless syntax.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
