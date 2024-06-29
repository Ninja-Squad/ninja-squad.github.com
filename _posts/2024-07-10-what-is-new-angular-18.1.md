---
layout: post
title: What's new in Angular 18.1?
author: cexbrayat
tags: ["Angular 18", "Angular"]
description: "Angular 18.1 is out!"
---

Angular&nbsp;18.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/18.1.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## TypeScript 5.5 support

Angular v18.1 now supports TypeScript 5.5. This means that you can use the latest version of TypeScript in your Angular applications. You can check out the [TypeScript 5.5 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-5/) to learn more about the new features: it's packed with new things! For example, it's no longer necessary to manually define type guards when filtering arrays, with the new [inferred type predicate feature](https://devblogs.microsoft.com/typescript/announcing-typescript-5-5/#inferred-type-predicates).

## @let syntax

The main feature of this release is undoubtedly the new `@let` syntax in Angular templates.
This new syntax (in developer preview) allows you to define a template variable in the template itself,
without having to declare it in the component class.

The syntax is `@let name = expression;`, where `name` is the name of the variable (and can be any valid JavaScript variable name) and `expression` is the value of the variable.
Let’s say our component has a count field defined in its class, then we can define a variable in the template like this:

{% raw %}
```html
@let countPlustwo = count + 2;
<p>{{ countPlustwo }}</p>
```
{% endraw %}

If the `count` value changes, then the `countPlustwo` value will be updated automatically.
This also works with the `async` pipe (and the other ones, of course):

{% raw %}
```html
@let user = user$ | async;
@if (user) {
  <p>{{ user.name }}</p>
}
```
{% endraw %}

Note that you can't declare several variables (with `@let` or `#`) with the same name in the same template:

```
NG8017: Cannot declare @let called 'value' as there is another symbol in the template with the same name.
```

You also can't use a variable before its declaration:

```
NG8016: Cannot read @let declaration 'user' before it has been defined.
```

which prevents to use it like `@let user = user()` in case you thought about unwrapping a signal value into a variable of the same name.

This new feature can be handy when you want to use a value in several places in your template, especially if it is a complex expression. Sometimes you can create a dedicated field in the component class, but sometimes you can’t, for example in a for loop:

{% raw %}
```html
@for(user of users; track user.id) {
  <div class="name">{{ user.lastName }} {{ user.firstName }}</div>
  <div class="address">
    <span>{{ user.shippingAddress.default.number }}&nbsp;</span>
    <span>{{ user.shippingAddress.default.street }}&nbsp;</span>
    <span>{{ user.shippingAddress.default.zipcode }}&nbsp;</span>
    <span>{{ user.shippingAddress.default.city }}</span>
  </div>
}
```
{% endraw %}

This can be written more cleanly using `@let` 🚀:

{% raw %}
```html
@for(user of users; track user.id) {
  <div class="name">{{ user.lastName }} {{ user.firstName }}</div>
  <div class="address">
    @let address = user.shippingAddress.default;
    <span>{{ address.number }}&nbsp;</span>
    <span>{{ address.street }}&nbsp;</span>
    <span>{{ address.zipcode }}&nbsp;</span>
    <span>{{ address.city }}</span>
  </div>
}
```
{% endraw %}

## afterRender/afterNextRender APIs

Angular v16.2 introduced two new APIs to run code after the rendering of a component: `afterRender` and `afterNextRender`.
You can read more about them in our [Angular 16.2 blog post](/2023/08/09/what-is-new-angular-16.2/).

In Angular v18.1, these APIs have been changed (they are still marked as experimental) to no longer need a `phase` parameter, which was introduced in Angular v17, as we explained
in our [Angular 17 blog post](/2023/11/09/what-is-new-angular-17.0/).

The `phase` parameter is now deprecated: we now pass to these functions an object instead of a callback, to specify the phases you want to use.
You can still use the callback form with no phase,
which is equivalent to using the `MixedReadWrite` mode.
There are 4 phases available in the new object form:
`earlyRead`, `mixedReadWrite`, `read`, and `write`.
If you only need to read something, you can use the `read` phase.
If you need to write something that affects the layout, you need to use `write`.
For example, to initialize a chart in your template:

```ts
export class ChartComponent {
  @ViewChild('canvas') canvas!: ElementRef<HTMLCanvasElement>;

  constructor() {
    afterNextRender({
      write: () => {
        const ctx = this.canvas.nativeElement;
        new Chart(ctx, { type: 'line', data: { ... } });
      }
    });
  }
}
```

If your `write` callback depends on something you need to read first,
you must use `earlyRead` to get the information you need before the `write` phase,
and Angular will call the `write` callback with the value returned by the `earlyRead` callback:

```ts
afterRender({
  earlyRead: () => nativeEl.getBoundingClientRect(),
  //👇 The `rect` parameter is the value returned by the `earlyRead` callback
  write: (rect) => {
    otherNativeEl.style.width = rect.width + "px";
  },
});
```

This exists to avoid intermixing reads and writes if possible,
and thus make things faster by avoiding "layout trashing".
We previously had to call `afterRender` twice, once for the read and once for the write phase,
but now we can do it in a single call, which is more efficient and cleaner.

The `phase` option still exists but is now deprecated.
Even if these APIs are an experimental feature, the Angular team provided a migration schematics to update your code to the new syntax 😍.

## toSignal equality function

As you may know, if you read [our blog post about signals](/2023/04/26/angular-signals/),
a `Signal` can define its own equality function (it uses `Object.is` by default).

In Angular v18.1, the `toSignal` function now also accepts an `equal` parameter to specify the equality function to use in the signal it creates.

## RouterLink with UrlTree

The `RouterLink` directive now accepts an `UrlTree` as input. This allows you to pass a pre-constructed `UrlTree` to the `RouterLink` directive, which can be useful in some cases.

Until now, we could pass either a string or an array to the `RouterLink` directive. For example, we could write:

{% raw %}
```html
<a [routerLink]="['/users', user.id]">User {{ user.name }}</a>
```
{% endraw %}

Now we can also use an `UrlTree`:

```typescript
export class HomeComponent {
  userPath = inject(Router).createUrlTree(["/users", user.id]);
}
```

and in the template:

{% raw %}
```html
<a [routerLink]="userPath">User {{ user.name }}</a>
```
{% endraw %}

Note that when doing so, you can't define the `queryParams`, `fragment`, `queryParamsHandling`
and `relativeTo` inputs of the `RouterLink` directive in the template.
You have to define them in the `UrlTree` itself, or you'll see the following error:

```
Error: NG04016: Cannot configure queryParams or fragment when using a UrlTree as the routerLink input value.
```

## Router browserUrl

The `NavigationBehaviorOptions` object,
used for the options of the `navigate`/`navigateByUrl` of the `Router` service
or the `RedirectCommand` object introduced in [Angular v18](/2024/05/22/what-is-new-angular-18.0/)
now accepts a `browserUrl` option.
This option allows you to specify the URL that will be displayed in the browser's address bar when the navigation is done, even if the matched URL is different.
This does not affect the internal router state (the `url` of the `Router` will still be the matched one) but only the browser's address bar.

```ts
const canActivate: CanActivateFn = () => {
  const userService = inject(UserService);
  const router = inject(Router);
  if (!userService.isLoggedIn()) {
    const targetOfCurrentNavigation = router.getCurrentNavigation()?.finalUrl;
    const redirect = router.parseUrl("/401");
    // Redirect to /401 internally but display the original URL in the browser's address bar
    return new RedirectCommand(redirect, {
      browserUrl: targetOfCurrentNavigation,
    });
  }
  return true;
};
```

## Extended diagnostic for uncalled functions

A new extended diagnostic has been added to warn about uncalled functions in event bindings:

So for example:

```html
<button (click)="addUser">Add user</button>
```

yields the following error (if you have `strictTemplates` enabled):

```
NG8111: Functions must be invoked in event bindings: addUser()
```

## Angular CLI

### faster builds with isolatedModules

TypeScript has an [option called `isolatedModules`](https://www.typescriptlang.org/tsconfig/#isolatedModules)
that warns you if you write code that can't be understood by other tools
by just looking at a single file.

If you enable this option on your project, you should hopefully have no warnings,
and you can get a nice boost in build performances, as CLI v18.1 will delegate the transpilation of your TS files into JS files to esbuild instead of the TypeScript compiler 🚀

On a rather large application, `ng build` went from 49s to 32s, just by adding `isolatedModules: true` in my `tsconfig.json` file 🤯.

`isolatedModules` will be enabled by default in the new projects generated by the CLI.

### WASM support

The CLI now supports the usage of Web Assembly... in zoneless applications!
The application can't use ZoneJS as the CLI needs to use native async/await to load WASM code
and ZoneJS prevents that.

Anyway this can be interesting for some people, and you can write code like:

```ts
import { hash } from "./hash.wasm";

console.log(hash(myFile));
```

### inspect option

We can note the addition of a `--inspect` option for `ng serve`/`ng dev`, only possible for SSR/SSG applications.
This flag starts a debug process, by default on port 9229,
allowing to attach a debugger to go through the code executed on the server.
You can use Chrome Inspect, VS Code, or your favorite IDE to attach to the process
(see the [NodeJS docs](https://nodejs.org/en/learn/getting-started/debugging)).
You can then add breakpoints into your code,
and the debugger will stop when this code is executed on the server when you load the corresponding page in your browser.
You can specify a different host or port if needed with `ng serve --inspect localhost:9999` for example.

### chunk optimizer

If you want to reduce the number of chunk files,
an experimental optimization has been added to the build step.
You may have noticed that since we shifted from webpack to esbuild as the underlying build tool,
the number of generated chunks has increased quite a bit.
This is because there is no real optimization done on chunks.
So we sometimes end up with really small chunks when running `ng build`.
Some build tools have options to specify a minimal size, but esbuild doesn't.
That's why the CLI team is experimenting with an additional rollup pass
to optimize the generated chunks and try to merge some of them
or add some directly into the main bundle when it makes sense.

On one of our largest applications, it reduces by half the number of chunks,
and the initial page now only needs to load 3 JS files instead of... 118 😲.
It does add a bit of build time though.

To try this on your own application, you can run:

```
NG_BUILD_OPTIMIZE_CHUNKS=1 ng build
```

This is still experimental for now but will probably be enabled automatically in a future version,
based on the initial file entry count and size.

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
