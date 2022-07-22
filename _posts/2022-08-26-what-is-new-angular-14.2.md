---
layout: post
title: What's new in Angular 14.2?
author: cexbrayat
tags: ["Angular 14", "Angular"]
description: "Angular 14.2 is out!"
---

Angular&nbsp;14.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/14.2.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a minor release, but it is packed with interesting features: let's dive in!

## Typescript 4.8

TypeScript v4.8 has just been released, and Angular is already compatible \o/.
Check out the [Typescript v4.8 blog post](https://devblogs.microsoft.com/typescript/announcing-typescript-4-8/) to learn more about the new features.

## NgOptimizedImage

The biggest new feature in Angular 14.2 is the new `NgOptimizedImage` directive.
It is a standalone directive available as an experiment in the `@angular/common` package.

This directive helps you to optimize your images in your application.
To enable it, add it to the imports of one of your modules or standalone components:

  imports: [NgOptimizedImage]

Then to use it, you can simply replace the `src` of an image with `rawSrc`:

{% raw %}
    <img [rawSrc]="imageUrl" />
{% endraw %}

The directive then does its best to enforce best practices for this image.
For example, did you know that it is recommended to set the `width` and `height` attributes on the `img` tag to prevent layout shifts? See [this web.dev article](https://web.dev/patterns/web-vitals-patterns/images/img-tag/) for more information. 

If you use the `NgOptimizedImage` directive, then you get an error if `width` and `height`
are not properly set:

    NG02954: The NgOptimizedImage directive (activated on an <img> element with the `rawSrc="/avatar.png"`) has detected that these required attributes are missing: "width", "height". Including "width" and "height" attributes will prevent image-related layout shifts. To fix this, include "width" and "height" attributes on the image tag.

This forces us to properly set the `width` and `height` attributes on the `img` tag.
But note that you need to set a width/height ratio coherent with your image's intrinsic size.
For example, if the image is 800x600 pixels, then you need to set the `width` and `height` attributes to `800` and `600` respectively, or to values that respect the same ratio, like `400` and `300`.


{% raw %}
    <img [rawSrc]="imageUrl" width="400" height="300" />
{% endraw %}

Otherwise, you get a warning letting you know that the image is distorted:

    NG02952: The NgOptimizedImage directive (activated on an <img> element with the `rawSrc="/avatar.png"`) has detected that the aspect ratio of the image does not match the aspect ratio indicated by the width and height attributes. Intrinsic image size: 800w x 600h (aspect-ratio: 1.3333333333333333). Supplied width and height attributes: 300w x 300h (aspect-ratio: 1). To fix this, update the width and height attributes.
    
But the directive does more than just screaming at you 😉.

It automatically sets the `fetchpriority` attribute on the `img` tag.
This attribute is used by modern browsers to determine how it should prioritize the fetching of the image (see [the MDN docs](https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/fetchpriority)). The directive will set the `fetchpriority` attribute to `high` if the image has the `priority` attribute (so the browser will fetch it right away), or to `auto` otherwise.

It also sets the `loading` attribute (see [the MDN docs](https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement/loading)) to `eager` if the image has the `priority` attribute, or to `lazy` otherwise.

This means that by default, the browser will only load images when they're about to be visible in the viewport.

It checks a few more things when running in dev mode (`ng serve`).
If the image is treated by the browser as a Largest Contentful Paint (LCP) element (typically the case for above-the-fold images),
then it checks that the image has the `priority` attribute. If that's not the case you get a warning in the console (`NG02955`).

Last but not least, the directive comes with the concept of "loaders".
By default, the image is loaded from the `src` directory of your application, as usual.
But you can specify another loader if you are using a service like [Cloudflare Image Resizing](https://developers.cloudflare.com/images/image-resizing/),
[Cloudinary](https://cloudinary.com/), [ImageKit](https://imagekit.io/) or [Imgix](https://imgix.com/).
To do so, you can define one of the provided loaders in your providers:

    providers: [
      provideCloudflareLoader("https://ninja-squad.com/"),
      // or `provideCloudinaryLoader`, `provideImageKitLoader`, `provideImgixLoader`
    ]

It is of course possible to create your own loader:

    providers: [
      {
        provide: IMAGE_LOADER,
        useValue: (config: ImageLoaderConfig) => {
          return `https://example.com/${config.src}-${config.width}.jpg}`;
        }
      }
    ]

The directive also supports width or density descriptors, like `400w` or `2x`,
with `rawSrcset`.

{% raw %}
    <img rawSrcset="avatar.png" rawSrcset="100w, 200w" />
{% endraw %}

This directive is probably only useful in some specific cases, but it enforces best practices that we don't always know as web developers.
It has been pushed by the [Aurora team](https://developer.chrome.com/blog/introducing-aurora/) which is a collaboration between Chrome and open-source web frameworks.
Give it a try (and keep in mind this is experimental). 
That's why you can see similar work in other frameworks, like [Nuxt Image](https://image.nuxtjs.org/) for example.

The Aurora team wrote [an in-depth article](https://developer.chrome.com/blog/angular-image-directive/) if you want to learn more.

## Core

A new function `createComponent()` has been added to the framework to help create components dynamically.
This is a replacement for the `ComponentFactory` that was usually used until it was deprecated in Angular v13.

    const app = await bootstrapApplication(AppComponent);
    const homeComponent = createComponent(HomeComponent, app.injector);
    app.attachView(homeComponent.hostView);

Another new function called `createApplication` has been introduced to let developers start an application
without bootstrapping a component (unlike `bootstrapApplication`).
This can be useful if you want to render multiple root components in your application,
or if you are using Angular Elements like in the following example:

    const app = await createApplication();
    const HomeNgElementCtor = createCustomElement(HomeComponent, { injector: app.injector });
    customElements.define('app-home', HomeNgElementCtor);

A low-level utility function called `reflectComponentType()` has also been added to the framework to help get the component metadata from a component type.

    const mirror = reflectComponentType(UserComponent)!;

`mirror` is a `ComponentMirror` object, which contains the metadata of the component: 

- `selector`, for example `app-user`
- `type`, for example `UserComponent`
- `inputs`, for example `[{ propName: 'userModel', templateName: 'userModel' }]`
- `outputs`, for example `[{ propName: 'userSaved', templateName: 'userSaved' }]`
- `ngContentSelectors`, for example `['*']`
- `isStandalone`, for example `false`

Similarly, there is now a `provideRouterForTesting()` function that can be used in tests
instead of `RouterTestingModule`.

## Forms

Angular v14 introduced a new form element called `FormRecord`.
You can read more about it in our blog post about
[Strictly typed forms](/2022/04/21/strictly-typed-forms-angular).

But there was no method to create a `FormRecord` with the `FormBuilder`.
This is now fixed in Angular v14.2 (a small contribution from me 👉👈),
and you can use `fb.record({})`:

    this.form = this.fb.group({
      languages: this.fb.record({
        english: true,
        french: false
      })
    });

## Standalone components

Angular v14.1 introduced the common directives and pipes as standalone entities,
v14.2 now introduces the router directives as standalone entities!

You can now import `RouterLinkWithHref` (for a `routerLink`), `RouterLinkActive` and `RouterOutlet` directly instead of importing the whole `RouterModule`:

    @Component({
      standalone: true,
      templateUrl: './user.component.html',
      imports: [RouterLinkWithHref] // -> you can now use `routerLink` in the template
    })
    export class UserComponent {

Related to standalone components, the router is now usable without using `RouterModule`,
thanks to the new `provideRouter` function.

So instead of using:

    bootstrapApplication(AppComponent, {
      providers: [
        importProvidersFrom(HttpClientModule),
        importProvidersFrom(RouterModule.forRoot(ROUTES, { preloadingStrategy: PreloadAllModules }))
      ]
    });

you can now write:

    bootstrapApplication(AppComponent, {
      providers: [
        importProvidersFrom(HttpClientModule),
        provideRouter(ROUTES,
          withPreloading(PreloadAllModules)
        )
      ]
    });

Other `with...` functions are available to enable router features:

- `withDebugTracing`
- `withDisabledInitialNavigation`
- `withEnabledBlockingInitialNavigation`
- `withInMemoryScrolling`
- `withRouterConfig`

These changes allow tree-shaking parts of the router module that aren't actually used,
thus reducing the main bundle size.

## Router

The router introduced the possibility of defining a page title on the route in Angular v14
(see [our blog post](/2022/06/02/what-is-new-angular-14.0)).
With this v14.2 release, it is now possible to retrieve the resolved title on the `ActivatedRoute` and `ActivatedRouteSnapshot`:

    constructor(private route: ActivatedRoute) {
      this.title = route.snapshot.title;
    }

It is now also possible to define guards and resolvers as simple functions.
You can now write something like:

    {
      path: '/user/:id/edit', 
      component: EditUserComponent,
      canDeactivate: [(component: EditUserComponent) => !component.hasUnsavedChanges]
    }

The `RouterLink` directive received a tiny improvement that is noticeable:
all its boolean inputs (`preserveFragment`, `skipLocationChange` and `replaceUrl`)
now accept a string and coerce it to a boolean.
This means you can now write:

    <a [routerLink]="['/user', user.id, 'edit']" skipLocationChange='true'>Edit</a>
    <!-- or even -->
    <a [routerLink]="['/user', user.id, 'edit']" skipLocationChange>Edit</a>

instead of:

    <a [routerLink]="['/user', user.id, 'edit']" [skipLocationChange]="true">Edit</a>

## Angular CLI

The new CLI version does not have many features this time.

One notable addition is the ability for `ng serve` to serve service workers.
It is enabled automatically if you have the option `"serviceWorker": true` in your builder configuration (which is the case by default when you add `@angular/pwa` to your application).
This is handy as it allows us to use the usual `ng serve` to test the PWA behavior,
whereas we previously had to build the application and serve it with another HTTP server to check it.

The work on the `esbuild` builder continues, and it is now faster to downlevel the JS code.
In the `esbuild` builder as well,
the Sass compilation now uses the ["modern API" of Sass](https://sass-lang.com/documentation/js-api/),
which is faster than the legacy one.
The classic `webpack` builder still uses the legacy Sass API,
but should switch to the modern one soon as well.

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
