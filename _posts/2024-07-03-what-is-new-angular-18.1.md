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
This new syntax allows you to define a template variable in the template itself,
without having to declare it in the component class.

The syntax is `@let name = expression;`, where `name` is the name of the variable (and can be any valid JavaScript variable name) and `expression` is the value of the variable.
Let’s say our component has a count field defined in its class, then we can define a variable in the template like this:

```html
@let countPlustwo = count + 2;
<p>{{ countPlustwo }}</p>
```

If `count` value changes, then the `countPlustwo` value will be updated automatically.
This also works with the `async` pipe:

```html
@let user = user$ | async;
<p>{{ user.name }}</p>
```

Note that you can't declare several variables with the same name in the same template:

```
NG8017: Cannot declare @let called 'user' as there is another @let declaration with the same name.
```

This new feature can be handy when you want to use a value in several places in your template, especially if it is a complex expression. Sometimes you can create a dedicated field in the component class, but sometimes you can’t, for example in a for loop:

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

This can be written more cleanly using `@let` 🚀:

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


## afterRender/afterNextRender APIs

Angular v16.2 introduced two new APIs to run code after the rendering of a component: `afterRender` and `afterNextRender`.
You can read more about them in our [Angular 16.2 blog post](/2023/08/09/what-is-new-angular-16.2/).

In Angular v18.1, these APIs have been changed (they are still marked as experimental) to no longer need a `phase` parameter, that was introduced in Angular v17, as we explained
in our [Angular 17 blog post](/2023/11/09/what-is-new-angular-17/).

We can now use them without the `phase` parameter, which is equivalent to using the `MixedReadWrite` mode.
Or you pass to these functions an object instead of a callback, to specify the phase you want to use.
There are 4 phases available: `earlyRead`, `mixedReadWrite`, `read`, and `write`.
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

This is quite advanced, and I'm not sure we're going to use these phases a lot in application code
(library authors might find them useful, though).

The `phase` option still exist but is now deprecated.
Even if these APIs are an experimental feature, the Angular team provided a migration schematics to update your code to the new syntax 😍.

## toSignal equality function

As you may know if you read [our blog post about signals](/2023/04/26/angular-signals/),
a `Signal` can define its own equality function (it uses `Object.is` by default).

In Angular v18.1, the `toSignal` function now also accepts an `equals` parameter to specify the equality function to use in the signal it creates.

## RouterLink with UrlTree

The `RouterLink` directive now accepts an `UrlTree` as input. This allows you to pass a pre-constructed `UrlTree` to the `RouterLink` directive, which can be useful in some cases.

Until now, we could pass either a string or an array to the `RouterLink` directive. For example, we could write:

```html
<a [routerLink]="['/users', user.id]">User {{ user.name }}</a>
```

Now we can also use an `UrlTree`:

```typescript
export class HomeComponent {
  userLink = inject(Router).createUrlTree(["/users", user.id]);
}
```

and in the template:

```html
<a [routerLink]="userLink">User {{ user.name }}</a>
```

Note that when doing so, you can't define the `queryParams`, `fragment`, `queryParamsHandling`
and `relativeTo` inputs of the `RouterLink` directive in the template.
You have to define them in the `UrlTree` itself, or you'll see the following error:

```
Error: NG04016: Cannot configure queryParams or fragment when using a UrlTree as the routerLink input value.
```

## Router browserUrl

The `NavigationBehaviorOptions` object,
used for the options of the `navigate`/`navigateByUrl` of the `Router` service
or the `RedirectCommand` object introduced in [Angular v18](/2024/05/22/what-is-new-angular-18/)
now accepts a `browserUrl` option.
This option allows you to specify the URL that will be displayed in the browser's address bar when the navigation is done, even if the matched URL is different.
This does not affect the internal router state (the `url` of the `Router` will still be the matched one) but only the browser's address bar.

```ts
const canActivate: CanActivateFn = () => {
  const userService = inject(UserService);
  const router = inject(Router);
  if (!userService.isLoggedIn()) {
    const targetOfCurrentNavigation = router.getCurrentNavigation()?.finalUrl;
    const redirect = router.parseUrl('/404');
    // Redirect to /404 internally but display the original URL in the browser's address bar
    return new RedirectCommand(redirect, { browserUrl: targetOfCurrentNavigation });
  }
  return true;
};
```

## Angular CLI

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
