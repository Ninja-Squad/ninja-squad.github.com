---
layout: post
title: What's new in Angular 17.2?
author: cexbrayat
tags: ["Angular 17", "Angular"]
description: "Angular 17.2 is out!"
---

Angular&nbsp;17.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/17.2.0">
    <img class="rounded img-fluid" style="max-width: 60%" src="/assets/images/angular_gradient.png" alt="Angular logo" />
  </a>
</p>

This is a minor release with some nice features: let's dive in!

## Queries as signals

A new developer preview feature has been added to allow the use of queries as signals. `viewChild()`, `viewChildren()`, `contentChild()`, and `contentChildren()` functions have been added in @angular/core and return signals.

Let’s go through a few examples.

You can use viewChild to query the template:

```ts
// <canvas #chart></canvas>
canvas = viewChild<ElementRef<HTMLCanvasElement>>('chart');
// ^? Signal<ElementRef<HTMLCanvasElement> | undefined>

// <form></form> with FormsModule
form = viewChild(NgForm);
// ^? Signal<NgForm | undefined>
```

As you can see, the return type is a Signal containing the queried `ElementRef<HTMLElement>` or `undefined`, or the queried component/directive or `undefined`.

You can specify that the queried element is required to get rid of `undefined`:

```ts
canvas = viewChild.required<ElementRef<HTMLCanvasElement>>('chart');
// ^? Signal<ElementRef<HTMLCanvasElement>>
```

If the element is not found, you’ll have a runtime error:

```
'NG0951: Child query result is required but no value is available.
Find more at https://angular.io/errors/NG0951'
```

This error can also happen if you try to access the query result too soon, for example in the constructor of the component. You can access the query result in the `ngAfterViewInit`/`ngAfterViewChecked` lifecycle hooks, or in the `afterNextRender`/`afterRender` functions.

You can also use `viewChildren` to query multiple elements. In that case, you get a Signal containing a readonly array of elements, or an empty array if no element is found (we no longer need QueryList \o/):
chart.component.ts

```ts
canvases = viewChildren<ElementRef<HTMLCanvasElement>>('chart');
// ^? Signal<ReadonlyArray<ElementRef<HTMLCanvasElement>>>
```

The functions accept the same option as `@ViewChild` and `@ViewChildren`, so you can specify the `read` option to query a directive or provider on an element.

As you can imagine, the same is possible for `contentChild` and `contentChildren`.

For example, if we want to build a `TabsComponent` that can be used like this:

{% raw %}
```html
<ns-tabs>
  <ns-tab title="Races" />
  <ns-tab title="About" />
</ns-tabs>
```
{% endraw %}

We can build a `TabDirective` to represent a tab:

```ts
@Directive({
  selector: 'ns-tab',
  standalone: true
})
export class TabDirective {
  title = input.required<string>();
}
```

then build the `TabsComponent` with `contentChildren` to query the directives:

{% raw %}
```ts
@Component({
  selector: 'ns-tabs',
  template: `
    <ul class="nav nav-tabs">
      @for (tab of tabs(); track tab) {
        <li class="nav-item">
          <a class="nav-link">{{ tab.title() }}</a>
        </li>
      }
    </ul>
  `,
  standalone: true
})
export class TabsComponent {
  tabs = contentChildren(TabDirective);
  // ^? Signal<ReadonlyArray<TabDirective>>
}
```
{% endraw %}

As for the `@ViewChild`/`@ViewChildren` decorators, we can specify the descendants option to query the tab directives that are not direct children of `TabsComponent`:

```ts
tabs = contentChildren(TabDirective, { descendants: true });
// ^? Signal<ReadonlyArray<TabDirective>>
```

{% raw %}
```html
<ns-tabs>
  <div>
    <ns-tab title="Races" />
  </div>
  <ns-tabgroup>
    <ns-tab title="About" />
  </ns-tabgroup>
</ns-tabs>
```
{% endraw %}

As `viewChild`, `contentChild` can be required.

## `model` signal

Signals also allow a fresh take on existing patterns. As you probably know, Angular allows a "banana in a box" syntax for two-way binding. This is mostly used with `ngModel` to bind a form control to a component property:

{% raw %}
```html
<input name="login" [(ngModel)]="user.login" />
```
{% endraw %}

Under the hood, this is because the `ngModel` directive has a `ngModel` input and a `ngModelChange` output.

So the banana in a box syntax is just syntactic sugar for the following:

{% raw %}
```html
<input name="login" [ngModel]="user.login" (ngModelChange)="user.login = $event" />
```
{% endraw %}

The syntax is, in fact, general and can be used with any component or directive that has an input named `something` and an output named `somethingChange`.

You can leverage this in your own components and directives, for example, to build a pagination component:

```ts
@Input({ required: true }) collectionSize!: number;
@Input({ required: true }) pageSize!: number;

@Input({ required: true }) page!: number;
@Output() pageChange = new EventEmitter<number>();

pages: Array<number> = [];

ngOnChanges(): void {
  this.pages = this.computePages();
}

goToPage(page: number) {
  this.pageChange.emit(page);
}

private computePages() {
  return Array.from({ length: Math.ceil(this.collectionSize / this.pageSize) }, (_, i) => i + 1);
}
```

The component receives the collection, the page size, and the current page as inputs, and emits the new page when the user clicks on a button.

Every time an input changes, the component recomputes the buttons to display.
The template uses a for loop to display the buttons:

{% raw %}
```html
@for (pageNumber of pages; track pageNumber) {
  <button [class.active]="page === pageNumber" (click)="goToPage(pageNumber)">
    {{ pageNumber }}
  </button>
}
```
{% endraw %}

The component can then be used like:

{% raw %}
```html
<ns-pagination [(page)]="page" [collectionSize]="collectionSize" [pageSize]="pageSize"></ns-pagination>
```
{% endraw %}

Note that `page` can be a number or a signal of a number,
the framework will handle it correctly.

The pagination component can be rewritten using signals,
and the brand new `model()` function:

```ts
collectionSize = input.required<number>();
pageSize = input.required<number>();
pages = computed(() => this.computePages());

page = model.required<number>();
// ^? ModelSignal<number>;
goToPage(page: number) {
  this.page.set(page);
}

private computePages() {
  return Array.from({ length: Math.ceil(this.collectionSize() / this.pageSize()) }, (_, i) => i + 1);
}
```

As you can see, a `model()` function is used to define the input/output pair, and the output emission is done using the `set()` method of the signal.

A model can be required, or can have a default value, or can be aliased, as it is the case for inputs. It can’t be transformed though. If you use an alias, the output will be aliased as well.

If you try to access the value of the model before it has been set, for example in the constructor of the component, then you’ll have a runtime error:

```
'NG0952: Model is required but no value is available yet.
Find more at https://angular.io/errors/NG0952'
```

## Defer testing

The default behavior of the `TestBed` 
for testing components using `@defer` blocks has changed from
`Manual` to `Playthrough`.

Check out our blog post about [defer](https://blog.ninja-squad.com/2023/11/09/what-is-new-angular-17.0/) for more details.

## NgOptimizedImage

The NgOptimizedImage directive
(check out [our blog post](/2022/08/26/what-is-new-angular-14.2) about it)
can now automatically display a placeholder while the image is loading,
if the provider supports automatic image resizing.

This can be enabled by adding a `placeholder` attribute to the directive:

{% raw %}
```html
<img ngSrc="logo.jpg" placeholder />
```
{% endraw %}

The placeholder is 30px by 30px by default, but you can customize it.
It is displayed slightly blurred to give a hint to the user that the image is loading. The blur effect can be disabled with `[placeholderConfig]="{ blur: false }`.

Another new feature is the ability to use Netlify as a provider,
joining the existing Cloudflare, Cloudinary, ImageKit, and Imgix providers.


## Angular CLI

### define support

The CLI now supports a new option named `define` in the `build` and `serve` targets. It is similar to what the [esbuild plugin of the same name](https://esbuild.github.io/api/#define) does: you can define constants that will be replaced with the specified value in TS and JS code, including in libraries.

You can for example define a BASE_URL that will be replaced with the value of `https://api.example.com`:

```json
"build": {
  "builder": "@angular-devkit/build-angular:browser",
  "options": {
    "define": {
      "BASE_URL": "'https://api.example.com'"
    },
```

You can then use it in your code:

```ts
return this.http.get(`${BASE_URL}/users`);
```

TypeScript needs to know that this constant exists (as you don't import it),
so you need to declare it in a `d.ts` file:

```ts
declare const BASE_URL: string;
```

This can be an alternative to the environment files, and it can be even more powerful as the constant is also replaced in libraries.


### Bun support

You can now use [Bun](https://bun.sh/) as a package manager for your Angular CLI projects, in addition to npm, yarn, pnpm and cnpm.
It will be automatically detected, or can be forced with `--package-manager=bun`
when generating a new project.

### clearScreen option

A new option is now supported in the application builder to clear the screen before rebuilding the application.

```json
"build": {
  "builder": "@angular-devkit/build-angular:application",
  "options": {
    "clearScreen": true
  },
```

You then only see the output of the current build,
and not from the previous one.

### Abbreviated build targets

The `angular.json` file now supports abbreviated build targets.
For example, you currently have something like this in your project:

```json
"serve": {
  "builder": "@angular-devkit/build-angular:dev-server",
  "configurations": {
    "development": {
      "buildTarget": "app:build:development"
    },
```

This means that `ng serve` uses the `app:build:development` target to build the application.

This can now be abbreviated to:

```json
"serve": {
  "builder": "@angular-devkit/build-angular:dev-server",
  "configurations": {
    "development": {
      "buildTarget": "::development"
    },
```

### PostCSS support

The application builder now supports PostCSS, a tool for transforming CSS with JavaScript plugins. You just have to add a `postcss.config.json` or `.postcssrc.json` file to your project and the CLI will pick it up.

### JSON build logs

The CLI now supports a new option to output the build logs in JSON format. This can be useful to integrate the build logs in other tools.

```
NG_BUILD_LOGS_JSON=1 ng build
```

## Summary

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
