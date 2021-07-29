---
layout: post
title: What's new in Angular 12.2?
author: cexbrayat
tags: ["Angular 12", "Angular"]
description: "Angular 12.2 is out!"
---

Angular&nbsp;12.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#1220-2021-08-04">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This new minor version contains only a few features.

## Forms

Forms are getting some love in this release,
with the addition of the `hasValidator`, `addValidators`, and `removeValidators` methods.
As you can expect, they allow to add and remove a validator or an array of validators to/from a form control, array or group.
Until now, you had to remove all validators and reset them when you wanted to add/remove one,
which was not great for fairly common use-cases like making a field required depending on a condition:

    // if auto-refresh is enabled, then the frequency is required
    this.activateAutoRefreshCtrl.valueChanges.subscribe((isAutoRefreshEnabled: boolean) => {
      if (isAutoRefreshEnabled) {
        this.autoRefreshFrequencyCtrl.setValidators([frequencyValidator, Validators.required]);
      } else {
        this.autoRefreshFrequencyCtrl.setValidators(frequencyValidator);
      }
      this.autoRefreshFrequencyCtrl.updateValueAndValidity();
    });

You can simplify such code:

    this.activateAutoRefreshCtrl.valueChanges.subscribe((isAutoRefreshEnabled: boolean) => {
      if (isAutoRefreshEnabled) {
        this.autoRefreshFrequencyCtrl.addValidators(Validators.required);
      } else {
        this.autoRefreshFrequencyCtrl.removeValidators(Validators.required);
      }
      this.autoRefreshFrequencyCtrl.updateValueAndValidity();
    });

These methods have a version for asynchronous validators with `hasAsyncValidator`, `addAsyncValidators` and `removeAsyncValidators`.
Note that the `hasValidator`/`hasAsyncValidator` methods works only with a reference to the exact validator function,
sot this does not work for example:

    this.autoRefreshFrequencyCtrl = new FormControl(10, Validators.min(5));
    this.autoRefreshFrequencyCtrl.hasValidator(Validators.min(5)) // returns false

whereas this works:

    const frequencyValidator = Validators.min(5);
    this.autoRefreshFrequencyCtrl = new FormControl(10, frequencyValidator);
    this.autoRefreshFrequencyCtrl.hasValidator(frequencyValidator) // returns true

The same goes for `removeValidators`/`removeAsyncValidators`
as they use `hasValidator`/`hasAsyncValidator` internally.

## Templates

The compiler now supports underscore as separator for numbers in template,
as ES2021 allows for JavaScript.
You can now write:

{% raw %}
<div>{{ 1_000_000 }}</div>
{% endraw %}

## Router

It's now possible to provide a `RouteReuseStrategy` via DI for the router testing module,
whereas you could only use imperative instantiation previously.
You can now write:

    TestBed.configureTestingModule({
      imports: [RouterTestingModule],
      providers: [{ provide: RouteReuseStrategy, useClass: CustomReuseStrategy }]
    });

That's all for this release!
You can check what's new in the CLI for this v12.2 release in [our other blog post](/2021/08/04/angular-cli-12.2/).

The next one will be v13 near the end of the year, and will hopefully include a few things we've been waiting for:
typed forms (yes, it's happening!), and Angular packages already pre-compiled for Ivy (so `ngcc` will have much less work to do).

Stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
