---
layout: post
title: What's new in Angular 5?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4", "Angular 5"]
description: "Angular 5 is out! Which new features are included?"
---

Angular 5.0.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

## Forms

Forms got the most of this update, with a tiny but really useful addition to the API:
the ability to decide when the validity and value of a field or form is updated.
This is something we already had in AngularJS 1.x, but not yet in Angular.

To do so, the `FormControl` allows to use an `options` object as the second parameter,
to define the synchronous and asynchronous validators,
and also the `updateOn` option.
Its value can be:

- `change`, it's the default: the value and validity are updated on every change;
- `blur`, the value and validity are then updated only when the field lose the focus.
- `submit`, the value and validity are then updated only when the parent form is submitted.

    this.passwordCtrl = new FormControl('', {
      validators: Validators.required,
      updateOn: 'blur'
    });

It's also possible to define this option on the `FormGroup` level,
to have all the fields of the group behaving the same:

    this.userForm = new FormGroup({
      username: '',
      password: ''
    }, { updateOn: 'blur' });

This is of course also possible in template-driven form,
with the `ngModelOptions` input of the `NgModel` directive:

    <input [(ngModel)]="user.login" [ngModelOptions]="{ updateOn: 'blur' }">

or on a group of fields with the `ngModelGroupOptions` input of the `NgModelGroup` directive:

    <div ngModelGroup="address" [ngModelGroupOptions]="{ updateOn: 'blur' }" required>
      <input name="street" [ngModel]="address.street">
      <input name="city" [ngModel]="address.city">
    </div>

or the new `ngFormOptions` input of the `NgForm` directive to apply on all fields:

    <form [ngFormOptions]="{ updateOn: 'submit' }">

You can learn more about the plans for forms in this [design docs](https://docs.google.com/document/d/1dlJjRXYeuHRygryK0XoFrZNqW86jH4wobftCFyYa1PA/edit#).

## Http

The new `HttpClient` [introduced in 4.3](http://blog.ninja-squad.com/2017/07/17/http-client-module/)
has been slightly improved with Angular 5.0, as we are now able to directly use object literals
as headers or parameters, whereas we had to use the classes `HttpHeaders` and `HttpParams`.

So this kind of code:

    const headers = new HttpHeaders().set('Authorization', 'secret');
    const params = new HttpParams().set('page', '1');
    return this.http.get('/api/users', { headers, params });

can now be simplified into:

    const headers = { 'Authorization': 'secret' };
    const params = { 'page': '1' };
    return this.http.get('/api/users', { headers, params });

## Animations

Two new transition aliases are introduced: `:increment` and `:decrement`.
Let's say you wanted to animate a carousel with 5 elements,
with a nice animation based on the index of the element displayed.
You had to declare a transition like: `transition('0 => 1, 1 => 2, 2 => 3, 3 => 4', ...)`.
With Angular 5, you can now use `transition(':increment')`!

## Router

The router gains two new events to track the activation of individual routes:

- `ChildActivationStart`
- `ChildActivationEnd`

## i18n

The messages extracted from your application now include the interpolations used in the template.

Before:

    <source>Welcome to Ponyracer <x id="INTERPOLATION"/> <x id="INTERPOLATION_1"/>!</source>

Now:

    {% raw %}
    <source>Welcome to Ponyracer <x id="INTERPOLATION" equiv-text="{{ user.firstName }}"/> <x id="INTERPOLATION_1" equiv-text="{{ user.lastName }}"/>!</source>
    {% endraw %}

This can be really helpful for the translators,
as they now have a hint about the interpolations.

## Performance

A few things changed internally to boost performance,
and a new compiler flag appeared that allows to remove extra whitespaces.
This can look minor, but it can improve the generated code size,
and also speed the components creation.
But it can also break your layout if you rely on several consecutive spaces in your templates :)
That's why the default for the `preserveWhitespaces` flag is `true` for now,
and might become `false` one day. But right now, you have to activate it manually.

You can configure it globally:

    platformBrowserDynamic().bootstrapModule(AppModule, {
      preserveWhitespaces: false
    });

or per component:


    @Component({
      selector: 'pr-home',
      templateUrl: './home.component.html',
      preserveWhitespaces: false
    })
    export class HomeComponent implements OnInit, OnDestroy {

If you really want a whitespace to be kept,
you can use a special entity called `&ngsp`.
It looks like `&nbsp` with a typo, but it is not:
it is a special character that the Angular compiler will transform in a whitespace.

## Pipes, i18n and breaking changes

More importantly, the pipes that were helping with the internationalization (`number`, `percent`, `currency`, `date`)
have been completely overhauled.
They don't rely on the Intl API anymore. This internationalization API was supposed to be provided by the browser,
but that was not always the case and led to numerous bugs.

If you don't do anything when you upgrade, you'll use the new pipes by default.
The good news is that there should be less bugs and you can remove the Intl polyfill you likely included.
The bad news is that they don't all have the same parameters and behavior as previously,
and that can break your application.

Using a different locale than the default one (`en-US`) now requires to load additional locale data:

    import { registerLocaleData } from '@angular/common';
    import localeFr from '@angular/common/i18n_data/locale_fr';

    registerLocaleData(localeFr);

All the i18n pipes now take a locale as their last parameter, allowing to dynamically override it:

    {% raw %}
    @Component({
      selector: 'ns-locale',
      template: `
        <p>The locale is {{ locale }}</p>
        <!-- will display 'en-US' -->

        <p>{{ 1234.56 | number:'1.0-3':'fr-FR' }}</p>
        <!-- will display '1 234,56' -->        
      `
    })
    class DefaultLocaleComponentOverridden {
      constructor(@Inject(LOCALE_ID) public locale: string) { }
    }
    {% endraw %}

The currency pipe now takes a string as it second parameter,
allowing to chose between `'symbol'` (default), `'symbol-narrow'` or `'code'`.
For example, with canadian dollars:

    {% raw %}
    <p>{{ 10.6 | currency:'CAD' }}</p>
    <!-- will display 'CA$10.60' -->

    <p>{{ 10.6 | currency:'CAD':'symbol-narrow' }}</p>
    <!-- will display '$10.60' -->

    <p>{{ 10.6 | currency:'CAD':'code':'.3' }}</p>
    <!-- will display 'CAD10.600' -->
    {% endraw %}

The date pipe has several breaking changes.
I won't list them, it's easier to check out the release note.

All things are not lost if you want to keep the "old" pipes for now,
as they have been kept in a new module `DeprecatedI18NPipesModule`,
that you can import if you want to still use them:

    @NgModule({
      imports: [CommonModule, DeprecatedI18NPipesModule],
      // ...
    })
    export class AppModule {


## Other breaking changes

A few things that were deprecated in Angular 4.0 has been definitely removed.

There is a last breaking change that should not really impact you.
I feel morally obligated to show it to you,
but it's totally not interesting.

If you are declaring extra providers in the `platformXXXX()` or `bootstrapModule()` methods,
you now need to use the (new) `StaticProvider`, which is really similar to a `Provider`,
but forces you to explicitly declare the dependencies.
It does _not_ impact the providers you declare in your modules and components,
don't worry.

So if you have something like this:

    platformBrowserDynamic([
      MyCustomProviderA,
      MyCustomProviderB // depends on MyCustomProviderA
    ]).bootstrapModule(AppModule);

It must now be in 5.0:

    platformBrowserDynamic([
      { provide: MyCustomProviderA, deps: [] },
      { provide: MyCustomProviderB, deps: [MyCustomProviderA] }
    ]).bootstrapModule(AppModule);

I honestly couldn't come up with a decent real case,
as it is quite rare to give extra providers to these methods,
and this only impact the two cases in the example
and not `useValue`, `useFactory`, `useExisting`...
So I don't think many apps will be impacted :)

On the other hand, this change allows Angular to not depend on the `Reflect` API,
and that gives us (slightly) smaller bundles \o/

Another change is the removal of the ES5 API to write Angular applications
without decorators.
This API was depending on `Reflect` and is now gone.

In the meantime, all our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](http://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
