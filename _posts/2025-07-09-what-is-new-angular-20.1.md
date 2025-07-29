---
layout: post
title: What's new in Angular 20.1?
author: cexbrayat
tags: ["Angular 20", "Angular"]
description: "Angular 20.1 is out!"
---

Angular&nbsp;20.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/20.1.0">
    <img class="rounded img-fluid" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

One month after the huge v20 release,
the Angular team delivers a new minor update.
This release introduces devtools with signal dependency graphs,
improvements in component testing with new binding helpers,
and adds a lot of HTTP client options that can boost your Core Web Vitals scores.
Plus, Angular takes its first steps into the AI-assisted development era with MCP server support.

Let's dive in.

## Devtools

The devtools have been updated with some nice new features.
You can now inspect the details of a route in the router tab,
but most of the improvements are for signals.

We can now inspect a signal from the devtools and jump to its definition.
But more importantly,
we now have a new "Signal Graph" tab
that shows the dependencies between signals in a graph,
and flashing of nodes when a signal changes.
It can be enabled in the devtools settings
by switching on the "Enable signal graph (experimental)" option.
You can then click on a component and on the "Show signal graph" button
to see the graph of signals that are used in this component!

You then get a (still a bit rough) graph with signals and inputs in blue,
computed signals in green, and effects in grey.
It will probably be improved in the future,
but it is already a nice way to visualize the dependencies between signals
and to understand how they are used in your application.
Some compiler magic (a TypeScript transformer) has been implemented to add a "debugName" to each signal,
based on the variable name in the component,
which is used in the graph to display the name of the signal.

## Tests

It is now possible to create a component in a test with its bindings directly set.

Let's say you have a `User` component:

```ts
@Component({
  // ...
})
export class User {
  readonly userModel = input.required<UserModel>();
  readonly selected = output<true>();
  // ...
```

A common practice is to test this type of component with a wrapper component:

```ts
@Component({
  // ...
  template: `<app-user
    [userModel]="userModel()"
    (selected)="isSelected.set(true)"
  />`,
})
export class UserHost {
  readonly userModel = signal<UserModel>({
    /* ... */
  });
  readonly isSelected = signal(false);
}

// ...
it("should display a user", () => {
  const fixture = TestBed.createComponent(UserHost);
  // ....
});
```

This can now be simplified,
thanks to `inputBinding()`, `outputBinding()` and `twoWayBinding()` that were
[introduced in v20](/2025/05/28/what-is-new-angular-20.0/)
and to an evolution of the `TestBed.createComponent` method in v20.1:

```ts
it("should display a user", () => {
  const userModel = signal<UserModel>({
    /* ... */
  });
  const isSelected = signal(false);
  const fixture = TestBed.createComponent(User, {
    // 👇 directly bind inputs/outputs
    bindings: [
      inputBinding("userModel", userModel),
      outputBinding("selected", () => isSelected.set(true)),
    ],
  });
  // ....
});
```

This is a nice improvement, even if the "wrapper component" approach
is still valid and can be useful in some cases, for example,
when you want to test a component
which uses `ng-content` or a directive that requires a host element.

## Performances

The low-level set of instructions that the compiler generates for templates
has been extended with DOM-only instructions,
used when the compiler can safely determine that the element has no directives applied to it.
Those DOM-only instructions are more efficient than the generic ones,
even if this is hard to measure in practice.

A template like the following:

{% raw %}

```html
<figure>
  <img [src]="userImageUrl()" />
  <figcaption>{{ userModel().name }}</figcaption>
</figure>
```

{% endraw %}

used to be compiled into the following instructions:

```ts
if (renderFlags & RenderFlags.Create) {
  elementStart(0, "figure");
  {
    element(1, "img");
  }
  {
    elementStart(2, "figcaption");
    text(3);
    elementEnd();
  }
  elementEnd();
}
if (renderFlags & RenderFlags.Update) {
  advance();
  property("src", ctx.userImageUrl());
  advance(2);
  textInterpolate(ctx.userModel().name);
}
```

It is now compiled into the following instructions:

```ts
if (renderFlags & RenderFlags.Create) {
  domElementStart(0, "figure");
  {
    domElement(1, "img");
  }
  {
    domElementStart(2, "figcaption");
    text(3);
    domElementEnd();
  }
  domElementEnd();
}
if (renderFlags & RenderFlags.Update) {
  advance();
  domProperty("src", ctx.userImageUrl());
  advance(2);
  textInterpolate(ctx.userModel().name);
}
```

The `elementStart`, `element`, `elementEnd`,
and `property` instructions still exist,
but they are now used only when the component has dependencies.

## Templates

The compiler now supports assignment operators in templates:
`+=`, `-=`, `*=`, `/=`, `%=`, `**=`, `&&=`, `||=` and `??=` are now allowed.

The `NgOptimizedImage` directive now offers a `decoding` option,
which can be set to `async`, `sync`, or `auto` (default).
You can use `async` to decode the image off the main thread,
or `sync` to decode it immediately (blocking).
`auto` lets the browser decide the best strategy.

## HTTP

The `HttpClient` gained a bunch of new options in v20.1:

- `timeout` which indicates the maximum time to wait for a response.
  It can be set to a number of milliseconds.
  If the request takes longer than this time, it will be aborted.
- `cache` (with the Fetch API only) which indicates if the request should use the browser cache.
  It can be set to `default`, `no-store`, `reload`, `no-cache`, `force-cache` or `only-if-cached`,
  see [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/cache) for more details.
- `priority` (with the Fetch API only) which indicates the priority of the request.
  It can be set to `auto` (default), `high` or `low`.
  It can be useful to improve your Core Web Vitals scores
  by distinguishing between high-priority requests that impact LCP and low-priority requests.
- `mode` (with the Fetch API only) which indicates the mode of the request.
  It can be set to `cors` (default), `no-cors`, `same-origin` or `navigate`.
  This is used to determine if cross-origin requests lead to valid responses,
  and which properties of the response are readable, see [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/mode).
- `redirect` (with the Fetch API only) which indicates how to handle redirects.
  It can be set to `follow` (default), `error` or `manual`.
- `credentials` (with the Fetch API only) which indicates whether to include credentials in the request.
  It can be set to `omit` (default), `same-origin` or `include`.
  This is used to determine if cookies and HTTP authentication are included in the request,
  see [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials).
  This option is more flexible than the existing `withCredentials` option
  (which is still available and is equivalent to `include`) and should be preferred.
- `referrer` (with the Fetch API only) which indicates the referrer of the request.
  It can be set to a URL, an empty string for no referrer or `about:client`.
  This is used to determine the referrer of the request,
  see [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/referrer).
- `integrity` (with the Fetch API only) which indicates the integrity of the request.
  It can be set to a hash of the response body.
  This is used to verify that the response has not been tampered with,
  see [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Request/integrity).

Most of these options are not supported when using the XHR backend.

The `HttpResource` also supports all these options
as well as `keepalive` (introduced in v20 for the `HttpClient`).

## Router

The router `loadChildren` and `loadComponent` functions now run
in the injection context of the route,
allowing you to inject services within the functions.

## Service worker

The Service Worker Push service `SwPush` now supports the [`notificationclose`](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerGlobalScope/notificationclose_event) and the [`pushsubscriptionchange`](https://developer.mozilla.org/en-US/docs/Web/API/ServiceWorkerGlobalScope/pushsubscriptionchange_event) events,
with the new `notificationCloses` and `pushSubscriptionChanges` observables (in addition of the existing `notificationClicks` observable).

## Angular CLI

This is a fairly small release for the CLI.

A notable feature is the possibility to use `base64` and `dataurl` loaders,
in addition to the pre-existing `text`, `binary`, and `file` loaders.
`dataurl` inlines the content as a data URL
and `base64` inlines the content as a Base64-encoded string.

This can be used to inline small assets in your application:

```ts
import contents from './assets/small-image.png' with { loader: 'dataurl' };
```

The experimental unit-test builder now allows to define some options (only for vitest):

- `setupFiles` which are files that are loaded before the tests are run,
  allowing you to set up the test environment.
- `codeCoverageReporters` which allows you to specify the code coverage reporters to use.

But the main feature of CLI v20.1 is the new `ng mcp` command,
which allows you to start an MCP server,
a hot topic in the AI community.

So let's talk about AI!

## AI

Angular is fully embracing the AI trend.
We now have a new documentation page explaining how to properly configure your favorite AI tool to help you with Angular development:
[Develop with AI](https://angular.dev/ai/develop-with-ai).
The page provides rules files for the most popular AI tools, such as Copilot, Cursor, VSCode, etc.

The CLI has also been updated and now includes an MCP server.
MCP stands for "Model Control Protocol"
and is the hot new protocol that allows LLMs to communicate with external tools and resources.
This protocol was introduced by Anthropic last year and is now supported by many AI tools.

You can run:

```bash
ng mcp
```

which outputs the configuration you need to add to your AI tool:

```
To start using the Angular CLI MCP Server, add this configuration to your host:

{
  "mcpServers": {
    "angular-cli": {
      "command": "npx",
      "args": ["@angular/cli", "mcp"]
    }
  }
}

Exact configuration may differ depending on the host.
```

This means that you can now use the CLI to start an MCP server,
then configure your favorite AI tool to connect to it.
The MCP server is quite minimalist for now,
as it offers only one resource (the best practice file mentioned above)
and one tool (the ability to list the Angular projects and their options in your workspace).

In my experiment with Copilot and Claude Code,
it seems that extending the context with the resources the MCP server provides
does make a difference in the quality of the suggestions.

## Summary

Most features of v20.1 are oriented towards improving the developer experience.
We also saw a new RFC about [the future of the animation package](https://github.com/angular/angular/discussions/62212).
We can expect movements in this area in the next releases
and hopefully some movements in the signal forms area as well.

Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
