---
layout: post
title: What's new in Angular 19.0?
author: cexbrayat
tags: ["Angular 19", "Angular"]
description: "Angular 19.0 is out!"
---

Angular&nbsp;19.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/19.0.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a major release with a lot of features.
Components are now standalone by default and most of the new Signal APIs are stable!

We have been hard at work these past months to completely re-write our 
["Become a Ninja with Angular" ebook](https://books.ninja-squad.com/angular)
and [our online workshop](https://angular-exercises.ninja-squad.com/)
to use signals from the start! 🚀
The update is free if you already have it, as usual 🤗.
I can't believe we have been maintaining this ebook
and workshop for nearly 10 years.
If you don't have it already, go grab it now!

## TypeScript 5.6 support

Angular v19 now supports TypeScript 5.6.
This means that you can use the latest version of TypeScript in your Angular applications.
You can check out the [TypeScript 5.6 release notes](https://devblogs.microsoft.com/typescript/announcing-typescript-5-6/) 
to learn more about the new features.
TypeScript 5.4 is no longer supported.

## Standalone by default

We no longer need to add `standalone: true` in the component/directive/pipe decorator,
as it is now the default behavior!

A migration will take care of removing it for you when running `ng update`,
and add `standalone: false` to your non-standalone entities if needed.

If you want to make sure all your components are standalone,
you can use the new `"strictStandalone": true` option in the `angularCompilerOptions`.
If that's not the case, you'll see:

```ts
TS-992023: Only standalone components/directives are allowed when 'strictStandalone' is enabled.
```

## Unused imports in standalone components

A wonderful extended diagnostic has been added to the Angular compiler,
allowing it to detect unused imports in standalone components!

This is a great addition, as it will help you to keep your components clean and tidy.
If you forget to remove an import after refactoring your code,
you'll see a message like this:

```ts
TS-998113: Imports array contains unused imports [plugin angular-compiler]

src/app/user/users.component.ts:9:27:
  9 │   imports: [UserComponent, UnusedComponent],
    ╵                            ~~~~~~~~~~~~~
```

A code action is provided to remove the unused import for you via the language service
(but there is no automatic migration doing it for you, unfortunately).

You can disable the diagnostic if needed with:

```json
"extendedDiagnostics": {
  "checks": {
    "unusedStandaloneImports": "suppress"
  }
}
```

## Signal APIs are stable (well, most of them)

Most of the Signal APIs (and RxJS interoperability functions) are no longer in developer preview
and can safely be used.

The `input()`, `output()`, `model()`, `viewChild()`, `viewChildren()`,
`contentChild`, `contentChildren()`, `takeUntilDestroyed()`, `outputFromObservable()`,
and `outputToObservable()` are now marked as stable.

Of course, migrating complete applications to these new APIs can be a bit of work.
But you know what, the Angular team cooked some automatic migrations! 😍
We will talk about them in the next section.

`effect` went through some changes and is still in developer preview.
`toObservable` (which uses an effect) and `toSignal` are still in developer preview as well.

All effects aren't handled the same way anymore.
Angular distinguishes two kinds of effects:
- component effects, which are created in components or directives;
- root effects, which are created in root services, or with the `forceRoot` option.

Component effects now run _during_ change detection
(just before the actual change detection of their owning component)
and not _after_ it as it was the case before.
This is a breaking change.
You might thus see some changes in their behavior,
for example when an effect is triggered by a change of a view query signal.
To solve this case, a new `afterRenderEffect` function has been added.
It is similar to `effect`, but its function runs after the rendering rather than before.
Like `afterRender` and `afterNextRender`
(check our [blog post](/2023/08/09/what-is-new-angular-16.2/) if you need a refresher), 
it can also specify what should be executed in each rendering phase
but values are propagated from phase to phase as signals instead of as plain values.
As a result, later phases may not need to execute
if the values returned by earlier phases do not change.
All these `afterRender` functions are still in developer preview.

Root effects are not tied to a component lifecycle
and are usually used to synchronize the state of the application
with the outside world
(for example, to write it to the local storage).
These effects don't run as part of the change detection but as a microtask
(and can be triggered in tests using `TestBed.flushEffects()`).

Another notable change is that you can now write to signals in effects,
without the need to specify the (now deprecated) option `allowSignalWrites: true`.
The team found out that it was not preventing basic usages
but was just making the code more verbose when really needed.

All in all, effects should be stabilized in the next release.
However their usage is still not recommended for most cases,
and it seems like they should be the last resort to solve a problem.
That's why the framework introduced the new experimental functions `linkedSignal`,
`resource`, and `rxResource`.

## Linked signals with linkedSignal()

Angular v19 introduced a new (developer preview) concept called "linked signals".
A linked signal is a _writable_ signal,
but it is also a _computed_ signal,
as its content can be reset thanks to a computation that depends on another signal (or several ones).

Imagine we have a component that displays a list of items received via an input,
and we want our users to select one of them.
By default, let’s say we want to select the first item of the list.
But every time the list of items changes,
the selected item may no longer be valid,
so we want to reset the selected item to the first one.

We can imagine a component like this:

```ts
export class ItemListComponent {
 items = input.required<Array<ItemModel>>();
 selectedItem = signal<ItemModel | undefined>(undefined);

  pickItem(item: ItemModel) {
    this.selectedItem.set(item);
  }
}
```

Using an effect may come to mind to solve the selection problem:

```ts
constructor() {
  // ⚠️ This is not recommended
  effect(() => {
    this.selectedItem.set(this.items()[0]);
  });
}
```

Every time the list of items changes,
the effect will be triggered and the first item will be selected.

There is a nice trick that I can show you before we dive into the now-recommended solution:
we can use a computed value that returns…​ a signal!

```ts
export class ItemListComponent {
  items = input.required<Array<ItemModel>>();
  selectedItem = computed<WritableSignal<ItemModel | undefined>>(
    () => signal(this.items()[0])
  );

  pickItem(item: ItemModel) {
    this.selectedItem().set(item);
  }
}
```

As you can see, the computed value returns a signal that represents the selected item
(whereas they usually return a value directly).
Every time the list of items changes, the computed function is re-evaluated,
and returns a new signal that represents the selected item.
The downside of this solution is that we have to use `selectedItem()()` to read the value,
or `selectedItem().set()` to update it, which is a bit ugly.

This is where we can use a `linkedSignal`:

```ts
export class ItemListComponent {
  items = input.required<Array<ItemModel>>();
  // ✅ This is recommended
  selectedItem: WritableSignal<ItemModel> = linkedSignal(() => this.items()[0]);
```

A `linkedSignal` is a `WritableSignal`,
but its value can be reset thanks to a computation.
If the items change, then the computation will be re-executed
and the value of the signal will be updated with the result.

The computation can of course depend on several signals.
Here `selectedItem` is reset when the items input changes,
but also when the enabled input changes.

```ts
export class ItemListComponent {
  items = input.required<Array<ItemModel>>();
  enabled = input.required<boolean>();
  // recomputes if `enabled` or `items` change
  selectedItem = linkedSignal(() => (this.enabled() ? this.items()[0] : undefined));
```

Note that you can use the previous value of the source signal in the computation function if you need to.
For example, if you want to access the previous items value to compare it with the new one,
you can declare the `linkedSignal` with the source and computation options.
In that case, the computation function receives the current and previous values of the source as parameters.

```ts
export class ItemListComponent {
  items = input.required<Array<ItemModel>>();
  selectedItem = linkedSignal</* source */ Array<ItemModel>, /* value */ ItemModel>({
    source: this.items,
    computation: (items, previous) => {
      // pick the item the user selected if it's still in the new item list
      if (previous !== undefined) {
        const previousChoice = previous.value; // previous.source contains the previous items
        if (items.map(item => item.name).includes(previousChoice.name)) {
          return previousChoice;
        }
      }
      return items[0];
    }
 });
```

## Async resources with resource() and rxResource()

Most applications need to fetch data from a server, depending on some parameters,
and display the result in the UI: `resource` aims to help with that.

This API is experimental, and will go through an RFC process soon:
I would not advise you to use it yet.

The `resource` function takes an object with a mandatory loader function that returns a promise:

```ts
list(): ResourceRef<Array<UserModel> | undefined> {
  return resource({
  loader: async () => {
    const response = await fetch('/users');
      return (await response.json()) as Array<UserModel>;
    }
  });
}
```

This example doesn’t use the HTTP client, but the native `fetch()` function, which returns a promise.
Indeed, the `resource()` function is not linked to RxJS,
and can thus use any client that returns promises.
`rxResource`, which we will discuss in a few seconds,
is the alternative to `resource` that can be used with an Observable-based client.
This is another example of Angular decoupling itself from RxJS,
but still providing interoperability functions allowing you to use it smoothly.

The function returns a `ResourceRef`, an object containing:

- an `isLoading` signal that indicates if the resource is loading;
- a `value` signal that contains the result of the promise;
- an `error` signal that contains the error if the promise is rejected;
- a `status` signal that contains the status of the resource.

You can then use these signals in your template:

{% raw %}
```html
@if (usersResource.isLoading()) {
  <p>Loading...</p>
} @else {
  <ul>
  @for (user of usersResource.value(); track user.id) {
    <li>{{ user.name }}</li>
  }
  </ul>
}
```
{% endraw %}

The `status` signal can be:

- `ResourceStatus.Idle`, the initial state;
- `ResourceStatus.Loading`, when the promise is pending;
- `ResourceStatus.Error`, when the promise is rejected;
- `ResourceStatus.Resolved`, when the promise is resolved;
- `ResourceStatus.Reloading`, when the resource is reloading;
- `ResourceStatus.Local`, when the value is set locally.

The resource also has a `reload` method that allows you to reload the resource.
In that case, its status will be set to `ResourceStatus.Reloading`.

But the reloading can also be automatic, thanks to the `request` option.
When provided, the resource will automatically reload if one of the signals used in the request changes.
Here, for example, the component has a `sortOrder` option that is used in the request:

```ts
sortOrder = signal<'asc' | 'desc'>('asc');
usersResource = resource({
  // 👇 The `sortOrder` signal is used to trigger a reload
  request: () => ({ sort: this.sortOrder() }),
  loader: async params => {
    // 👇 Params also contains the `abortSignal` to cancel the request
    // and the previous status of the resource
    // here we are only interested in the request
    const request = params.request;
    const response = await fetch(`/users?sort=${request.sort}`);
    return (await response.json()) as Array<UserModel>;
  }
});
```

If the `sortOrder` signal changes,
the resource will automatically reload!
You can also cancel the previous request if needed when the resource is reloaded
using the [`abortSignal`](https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal) parameter of the loader
(for example to implement a debounce).
You can choose to ignore the reload request
and thus keep the current value by returning `undefined` from the request function.

Last but not least, the returned `ResourceRef` is in fact writable.
You can use its `set` or `update` methods to change the value of the resource
(on the `value` or on the resource itself, both work).
In that case, its status will be set to `ResourceStatus.Local`.
If you’re only interested in reading the resource,
you can use the `asReadonly` method to get a read-only version of the resource.

Finally, the `ResourceRef` has a destroy method that can be used to stop the resource.

Now, let’s see how we can use an observable-based resource instead of a promised-based one.

You can use the `rxResource()` function in that case.
This function is really similar to `resource()`,
but its loader must return an observable instead of a promise.
This allows you to use our good old `HttpClient` service to fetch data from a server,
using all your interceptors, error handling, etc:

```ts
sortOrder = signal<'asc' | 'desc'>('asc');
usersResource = rxResource({
  request: () => ({ sort: this.sortOrder() }),
  // 👇 RxJS powered loader
  loader: ({ request }) => this.httpClient.get<Array<UserModel>>('/users', { params: { sort: request.sort } })
});
```

Note that the `rxResource()` function is from the `@angular/core/rxjs-interop package`,
where the `resource()` function is from `@angular/core`.
Another noteworthy detail is that only the first value of the observable is taken into account,
so you can’t have a stream of values.

Some of you may get a feeling of déjà vu with all this,
as it’s quite similar to the [TanStack Query](https://tanstack.com/query/) library.
I must insist that this is experimental and will probably evolve in the future.
It will also probably be used by higher-level APIs or libraries.
Let’s see what the RFC process will bring us!

## Automatic migration for signals

Now that signal inputs, view queries and content queries are stable,
why not refactor all our components to use them?
That can be automated using the following migration:

```
ng generate @angular/core:signals
? Which migrations do you want to run? (Press <space> to select, <a> to toggle all, <i> to invert selection, and <enter> to proceed)
❯◉ Convert `@Input` to the signal-based `input`
 ◉ Convert `@Output` to the new `output` function
 ◉ Convert `@ViewChild`/`@ViewChildren` and `@ContentChild`/`@ContentChildren` to the signal-based `viewChild`/`viewChildren` and
`contentChild`/`contentChildren`
```

You can then choose which directory you want to migrate (all the application by default).
The migration, by default, is conservative.
If it can't migrate something without breaking the build, it will leave it as it is.
But you can be more aggressive by passing the option `--best-effort-mode` as we'll see.
For a complete list of options, run `ng generate @angular/core:signals --help`.

After the migration, a report is displayed,
showing how many inputs/outputs/viewChildren/contentChildren have been migrated.
If you picked the less aggressive option, some of them might not have been migrated,
and you can re-run the migration with `--insert-todos`
to add explanation comments in the code where the migration couldn't be done.

For example, an `@Input` used on a setter yields the following TODO:

```ts
// TODO: Skipped for migration because:
//  Accessor inputs cannot be migrated as they are too complex.
```

Another example that you'll encounter fairly often is when an `@Input` is used in a template inside an `@if`,
the migration can't update it due to type-narrowing issues:

```ts
// TODO: Skipped for migration because:
//  This input is used in a control flow expression (e.g. `@if` or `*ngIf`)
//  and migrating would break narrowing currently.
```

These incompatibility reasons can then be migrated with the more aggressive option `--best-effort-mode`,
but you'll probably have to fix some errors manually.

The migration works astonishingly well, and you can then enjoy the new Signal APIs!
Of course, it does not refactor the code to use `computed` instead of `ngOnChanges` or other patterns that could be used with signals,
but it's a good start and will save you a lot of time.

You should also be able to trigger the migration for a specific file or property from your IDE with the new version of the language service!

After running these migrations on a few projects,
my advice would be to first run the `outputs` one,
as it is fairly trivial.

Then you can run the `queries` one,
which is a bit more complex but still quite safe
(with a few possible incompatible cases).
Finally, you can run the `inputs` one,
which is the most complex and may require manual intervention.

```
ng generate @angular/core:signals --migrations=outputs --defaults
ng generate @angular/core:signals --migrations=queries --defaults
ng generate @angular/core:signals --migrations=inputs --defaults
```

You can then lint, build, and test your application to see if everything is still working as expected.
You can then re-run the migration with `--insert-todos` to see the reasons why some fields have been skipped.
Then you can re-run the migration with `--best-effort-mode` to try to migrate them anyway.

## provideAppInitializer instead of APP_INITIALIZER

The `APP_INITIALIZER` token is now deprecated in favor of `provideAppInitializer`.
This new function is a more elegant way to provide an initializer to your application.

Before v19, you would provide an initializer like this:

```ts
{
  provide: APP_INITIALIZER,
  useValue: () => inject(InitService).init(),
  multi: true
},
```

Now you need to use `provideAppInitializer`:

```ts
provideAppInitializer(() => inject(InitService).init())
```

`ENVIRONMENT_INITIALIZER` and `PLATFORM_INITIALIZER` Are also deprecated in favor of `provideEnvironmentInitializer` and `providePlatformInitializer`.

As usual, an automatic migration will take care of this for you when running `ng update` (you may have to refactor a bit if you want to have a nice function with `inject` as I used in the example above).

## Templates

The `@let` syntax, introduced in [Angular v18.1](/2024/07/10/what-is-new-angular-18.1/), is now stable.

Expressions in the template can now use the `typeof` operator,
so you can write things like `@if (typeof user === 'object') {`.

The `keyvalue` pipe also has a new option.
This pipe has been around for a long time
and allows you to iterate over the entries of an object.
But it, perhaps surprisingly, orders the entries by their key by default,
as we explained in our [Angular 6.1 blog post (back in 2018 😅)](/2018/07/26/what-is-new-angular-6.1/).
You could already pass a comparator function,
but you can now pass `null` to disable the ordering:

{% raw %}
```html
@for (entry of userModel() | keyvalue: null; track entry.key) {
  <div>{{ entry.key }}: {{ entry.value }}</div>
}
````
{% endraw %}

## Router

It is now possible to pass data to a `RouterOutlet`,
making it easy to share data from a parent component to its nested children.

```html
<router-outlet [routerOutletData]="userModel"></router-outlet>
```

Then in a child component, you can get the data via DI and the token `ROUTER_OUTLET_DATA`:

```ts
readonly userModel = inject<Signal<UserModel>>(ROUTER_OUTLET_DATA);
```

Note that, for the first time I believe, the value you get via DI is not a static value, but a signal!
That means that every time `userModel` changes in the parent component,
the signal in the child component will be updated as well.

## Service worker

A few features have been added to the service worker support in Angular.

First, it is now possible to specify a `maxAge` for the entire application,
via a new configuration option called `applicationMaxAge`.
This allows us to configure how long the service worker will cache any requests.
Within the `applicationMaxAge`, files will be served from the cache.
Beyond that, all requests will only be served from the network.
This can be particularly useful for the `index.html` file,
to make sure a user returning several months later
will get the latest version of the application and not an old cached version.
You can define the `applicationMaxAge` in the `ngsw-config.json` file:

```json5
{
  "applicationMaxAge": "1d6h" // 1 day and 6 hours
}
```

Another new feature is the ability to define a `refreshAhead`
delay for a specific data group. 
When the time before the expiration of a cached resource is less than this `refreshAhead` delay,
Angular refreshes the resource.
Fun fact: this feature was already implemented,
but not publicly exposed.

```json5
{
  "dataGroups": [
    {
      "name": "api-users",
      "urls": ["/api/users/**"],
      "cacheConfig": {
        "maxAge": "1d",
        "timeout": "10s",
        "refreshAhead": "10m"
      }
    }
  ]
}
```

## SSR

There are tons of changes in the Server-Side Rendering (SSR) part of Angular,
both in the framework and in the CLI.

### Event Replay is stable

The event replay feature, introduced in [Angular v18](/2024/05/22/what-is-new-angular-18.0/), is now stable.
The CLI will now generate the necessary `withEventReplay()` call for you
when you create a new application with SSR.

### Application stability

When working with SSR, Angular needs to know when the application is stable,
meaning that all the asynchronous operations have been completed,
in order to render the application to a string and send it to the client.
Zone.js usually allows knowing this but in a zoneless application,
you need to do it yourself.

Angular does the bulk of the work for you,
by internally keeping track of the asynchronous operations it triggers
(an HTTP request done via the `HttpClient`, for example),
using a service called `PendingTasks`.
It has been renamed from `ExperimentPendingTasks` and stabilized in v19,
and an automatic migration will take care of this renaming for you during `ng update`.

You can also use `PendingTasks` in your application to track your own asynchronous operations.
The service has an `add` method to manually create a task that you can later clean,
but a `run` method has been added for convenience in v19,
allowing you to directly pass an async function:

```ts
const userData = await inject(PendingTasks).run(() => fetch('/api/users'));
//☝️ Angular will wait for the promise to resolve
this.users.set(usersData);
```

A new (experimental) RxJS operator called `pendingUntilEvent`
has also been added to the framework (in the `@angular/core/rxjs-interop` package):
it allows marking an observable as important for the application stability until a first event is emitted:
  
```ts
this.users = toSignal(users$.pipe(pendingUntilEvent()));
```

### Partial and incremental hydration

Building upon the event replay feature,
and the `@defer` feature (check [our blog post](/2023/11/02/angular-defer/) if you need a refresher),
the Angular team has introduced a new feature called 
["incremental hydration"](https://github.com/angular/angular/discussions/57664).

With incremental hydration, deferred content is rendered on the server side
(instead of rendering the defer placeholder),
but skipped over during client-side hydration
(it's left dehydrated, hence the "partial hydration" concept).

It means that the application is fully rendered,
but some parts are not yet interactive when the application bootstraps.
When a user interacts with a dehydrated component,
Angular will download the necessary code and hydrate the component
(and its perhaps dehydrated parent components) on the fly,
then replay the events that happened while the component was dehydrated,
leaving the impression that the component was already active 🤯.

This feature is in developer preview in v19,
and can be activated with `withIncrementalHydration()`:

```ts
bootstrapApplication(AppComponent, {
  providers: [provideClientHydration(withIncrementalHydration())]
});
```

The syntax to enable it is quite simple and uses the `@defer` block
with an additional `hydrate` option to define the hydration condition.
The possible hydration triggers are the same as the `@defer` conditions
(that we explained in detail in the blog post mentioned above).

```html
@defer(on timer(15s); hydrate on interaction) {
  <app-users />
} @placeholder {
  <span>Loading</span>
}
```

Until v19, the loading placeholder would be rendered in SSR.
With the `withIncrementalHydration()` option,
the `UsersComponent` will be rendered, but not hydrated on the client.

For example, the DOM will look like:

```html
<app-users>
  <!-- Dehydrated content -->
  <h1>User</h1>
  <button jsaction="click:;">Refresh users</button>
  <!-- more content -->
</app-users>
```

When the user clicks on the button,
Angular will download the necessary code for the `UsersComponent`,
then hydrate it and replay the events that happened
while the component was dehydrated (here, refreshing the list of users).

This is a powerful feature
for those who are looking to improve the performance of their applications,
and it highlights the flexibility of the control flow syntax in Angular.

### Route configuration for hybrid rendering

Until now, an SSR application with pre-render was pre-rendering the pages with no parameters but ignored parameterized pages.
In v19, [after an RFC](https://github.com/angular/angular/discussions/56785),
the CLI team introduced a new feature called "hybrid rendering".

All this work is part of the ongoing effort to improve the SSR experience in Angular,
which includes new APIs (App Engine APIs).

It is now possible to define the rendering mode per route of the application.
Instead of adding options to the existing route configuration,
the team decided to add a configuration file,
dedicated to the server-side,
which defines the rendering mode for each route.

Three rendering modes are available:

- `RenderMode.Prerender` for pre-rendering the page at build time;
- `RenderMode.Server` for rendering the page on the server;
- `RenderMode.Client` for rendering the page on the client.

For example, let's say you have the following routes in your application:

```ts
const routes: Routes = [
  // Home component
  { path: '', component: HomeComponent },
  // About component
  { path: 'about', component: AboutComponent },
  // User component with a parameter
  { path: 'users/:id', component: UserComponent }
];
```

In v18, `ng build` generated a `browser` folder with `index.html` and `about/index.html` files.
In v19, the same configuration throws with:

```ts
✘ [ERROR] The 'users/:id' route uses prerendering and includes parameters, but 'getPrerenderParams' is missing. Please define 'getPrerenderParams' function for this route in your server routing configuration or specify a different 'renderMode'.
```

This means there are 2 solutions.
First, we can add a server routing configuration file, `app.routes.server.ts`.

This file is now generated in a project when using `ng new --ssr --server-routing` or `ng add @angular/ssr --server-routing`.
The `--server-routing` option enables both the server routing configuration and the new App Engine APIs
(all these APIs are in developer preview for now).
It also uses a new option in `angular.json` called `outputMode` to define the output mode of the application:
- `server` generates a server bundle, enabling server-side rendering (SSR) and hybrid rendering strategies.
 This mode is intended for deployment on a Node.js server or a serverless environment. 
- `static` generates a static output suitable for deployment on static hosting services or CDNs.
 This mode supports both client-side rendering (CSR) and static site generation (SSG).

`ng add @angular/ssr --server-routing` sets the `outputMode` to `server` by default.
Note that the `prerender` and `appShell` options are no longer used if you define the `outputMode`.

Let's define the server routes configuration for the previous example:

```ts
export const serverRoutes: Array<ServerRoute> = [
  {
    path: '',
    renderMode: RenderMode.Prerender,
  },
  {
    path: 'about',
    renderMode: RenderMode.Server,
  },
  {
    path: '**',
    renderMode: RenderMode.Client,
  }
];
```

This file is then loaded in the `app.config.server.ts` file,
using `provideServerRoutesConfig(serverRoutes)`.

The server routes configuration doesn't need to define all the routes as you can see,
with a possible "catch-all" route '**' to define a default behavior.
If a route doesn't exist though, you'll get an error at build time:

```ts
✘ [ERROR] The 'unknown' server route does not match any routes defined in the Angular routing configuration (typically provided as a part of the 'provideRouter' call). Please make sure that the mentioned server route is present in the Angular routing configuration.
```

The second solution is to define a `getPrerenderParams` function, to prerender routes with parameters.

```ts
{
  path: 'users/:id',
  renderMode: RenderMode.Prerender,
  async getPrerenderParams(): Promise<Array<Record<string, string>>> {
    // API call to get the user IDs
    const userIds = await inject(UserService).getUserIds(); 
    // build an array like [{ id: '1' }, { id: '2' }, { id: '3' }]
    return userIds.map(id => ({ id }));
  }
},
```

This will prerender the `users/:id` route for each user ID found by the `UserService`,
generating `users/1/index.html`, `users/2/index.html`, etc.

A really nice change is that `server.ts` is now used during prerendering,
allowing access to locally defined API routes.
`server.ts` is now also used by the Vite server during development!
If needed you can disable it with the `--no-server` option, for example,
to make a static build: `ng build --output-mode static --no-server`.

As you may not want to prerender all the user pages, you can also define a `fallback` option,
that can be `PrerenderFallback.Client` (falls back to CSR),
`PrerenderFallback.Server` (falls back to SSR),
or `PrerenderFallback.None` (the server will not handle the request).

When using the `RenderMode.Server` mode,
you can also define a `status` and `headers` options to customize the response:

```ts
{
  path: '404',
  renderMode: RenderMode.Server,
  status: 404,
  headers: {
    'Cache-Control': 'no-cache'
  }
}
```

You can also define which route should serve as the app shell of the application
(see the [App shell pattern](https://angular.dev/ecosystem/service-workers/app-shell) in the Angular documentation),
by setting the `appShellRoute` option: `provideServerRoutesConfig(serverRoutes, { appShellRoute: 'shell' })`.

The "App Engine APIs" mentioned earlier are a set of APIs
that allow you to interact with the server-side rendering process,
based on the new `AngularAppEngine` and its node version `AngularNodeAppEngine`.
They are used in the generated `server.ts` file:

- `createNodeRequestHandler` allows you to create a request handler for the server-side rendering process
 You can pass it the handler you want to use like an [Express](http://expressjs.com/) app,
 which is still the default used when using `ng add @angular/ssr`,
 or another like [Fastify](https://fastify.dev/), [Hono](https://hono.dev/), etc.
 This should make it simpler to use a different server framework than Express.
- `writeResponseToNodeResponse` allows you to write the response from your server of choice to the node response object.

All these functions aim to make the interactions easier between Node.js
and the framework you picked to handle the requests to your Angular application.
This should provide greater flexibility compared to the previous APIs,
and make it easier to deploy Node.js applications, whatever the server framework you want to use.
And you can build your own variants of `AngularAppEngine` to fit your needs for other platforms.

The CLI team also wants to make it easier to target other runtimes than Node.js.
That's why a new option `ssr.experimentalPlatform` has been added, which lets you define the platform you want to target:
- `node` (default) generates a bundle optimized for Node.js;
- `neutral` generates a platform-neutral bundle suitable for environments like edge workers, and other serverless platforms that
 do not rely on Node.js APIs.
As the option name indicates, this is an experimental feature.

### Request and response via DI

It is now easy to access the request and response objects in your components during SSR,
thanks to new DI tokens in `@angular/core`:
- `REQUEST` to access [the current HTTP request object](https://developer.mozilla.org/en-US/docs/Web/API/Request);
- `REQUEST_CONTEXT` to pass custom metadata or context related to the current request in server-side rendering;
- `RESPONSE_INIT` to access [the response initialization options](https://developer.mozilla.org/en-US/docs/Web/API/Response/Response);


## Angular CLI

The CLI has also been released in version v19, with some notable features.

If you want to upgrade to 19.0.0 without pain (or to any other version, by the way), I have created a Github project to help: [angular-cli-diff](https://github.com/cexbrayat/angular-cli-diff). Choose the version you're currently using (18.1.0 for example), and the target version (19.0.0 for example), and it gives you a diff of all files created by the CLI: [angular-cli-diff/compare/18.1.0...19.0.0](https://github.com/cexbrayat/angular-cli-diff/compare/18.1.0...19.0.0).
It can be a great help along with the official `ng update @angular/core @angular/cli` command.

Let's see what's new in the CLI!

### Better HMR by default

A ton of work has been done to improve the Hot Module Replacement (HMR) experience in Angular.

When using the `application` builder for `ng serve`,
HMR is now enabled by default for styles!
This means that when you change a style file (or inline style),
the browser will update the styles without reloading the page
and without rebuilding the application.

This is sooo nice to see, as you can now change the styles and see the results
in real-time without losing the state of your application.
For example, when working in a modal,
you won't have to re-open it after each style change!
Definitely a game-changer for day-to-day work.

The work done in the framework goes even further than that,
and we should be able to have HMR that properly works for templates soon.
It is in fact already possible to try it using `NG_HMR_TEMPLATES=1 ng serve`
(this is experimental as you can guess).

When using this option, the templates will be reloaded,
refreshing all component instances, without reloading the page,
and the state of the application will be preserved!

### Karma can run with esbuild!

Even if Karma is slowly dying,
it is still the default testing solution in newly generated Angular CLI projects.
The Karma integration in Angular was still relying on Webpack until now,
which was a bit sad as all other builders were now using esbuild under the hood.

This is no longer the case as you can use esbuild with Karma as well!

To do so, a new option can be used in the Karma builder options in `angular.json`:
`builderMode`.
This option can have 3 different values:
- `browser` which is the same as the current behavior, using Webpack under the hood
- `application` which uses esbuild
- `detect` which uses the same builder as `ng serve`

When using `application`, you can also remove the `@angular-devkit/build-angular/plugins/karma` webpack plugin from your `karma.conf.js` (if you have one).

Shifting to `builderMode: application` is quite a bit faster.
On a project with thousands of tests, the full test suite was ~40% faster,
cutting nearly a minute from the total time.
In watch mode, the difference is also quite noticeable,
shaving a few seconds on each re-run.

### Zoneless experiment

A new option `--experimental-zoneless` has been added to the `ng new` command,
generating a new project without Zone.js.
Unit tests are also generated with the proper providers to make them work without Zone.js.
You can check out our [blog post on Angular 18.0](/2024/05/22/what-is-new-angular-18.0/#zoneless-experiment) for more information on this experiment.

### ng generate component

A new `--export-default` option has been added to the `ng generate component` command.
It changes the component to use the default export syntax: `export default class AdminComponent`.
This can be interesting for lazy-loaded components, as the `loadComponent` syntax then [allows to write](/2022/11/16/what-is-new-angular-15.0/) `loadComponent: () => import('./admin/admin.component')` instead of the usual `loadComponent: () => import('./admin/admin.component').then(m => m.AdminComponent)`.

### Sass deprecation warnings

It's now possible to silence the deprecation warnings coming from the Sass compiler:

```json
"stylePreprocessorOptions": {
  "sass": {
    "silenceDeprecations": ["import"]
  }
},
```

It's also possible to throw an error if a deprecation warning is emitted with `fatalDeprecations`
and to prepare for future deprecations with `futureDeprecations`.
This feature is going to be really useful to all Sass users,
as some APIs are getting deprecated and will be removed in Sass v3,
so you may see a bunch of deprecation warnings appear.

### Strict CSP

A new option has been added to the `ng build` command to enable a
strict Content Security Policy (CSP) in the generated `index.html` file.
This option applies the recommendations from this [Web.dev article](https://web.dev/articles/strict-csp#choose-hash)
and enables automatic generation of a hash-based CSP based on scripts in the `index.html` file.

To enable this option, set the `security.autoCsp` configuration to `true` in your `angular.json` file.

## Summary

Wow, that was a lot of new features in Angular v19!

v20 will probably continue to stabilize
the signals APIs introduced these past months.
We can also hope for more news about how the router and forms will integrate with signals.
Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
