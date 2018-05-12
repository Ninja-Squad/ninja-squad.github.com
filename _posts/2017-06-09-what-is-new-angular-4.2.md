---
layout: post
title: What's new in Angular 4.2?
author: cexbrayat
tags: ["Angular 2", "Angular", "Angular 4"]
description: "Angular 4.2 is out! Which new features are included?"
---

Angular 4.2.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#420-salubrious-stratagem-2017-06-08">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

# Templates

As we explained in [our blog post about Angular 4.1](/2017/04/28/what-is-new-angular-4.1/),
it is now possible to use `strictNullChecks` in your applications.

The `!` post-fix operator is now also available in templates:

    {% raw %}
    <h2>{{ possiblyNullRace!.name }}</h2>
    {% endraw %}

The code generated from the AoT compiler
will then include the [non-null assertion operator](https://github.com/Microsoft/TypeScript/wiki/What%27s-new-in-TypeScript#non-null-assertion-operator) too,
allowing to do strict null checking in your templates also!

# Forms

Two new validators joins the existing `required`, `minLength`, `maxLength`, `email` and `pattern`:
`min` and `max` help you validate that the input is at least or at most the value specified.

    <input type="number" [(ngModel)]="user.age" min="0" max="130">

**Update (2017-06-17):** The `min` and `max` validators have been temporarily
removed from Angular in version 4.2.3, as they are a breaking change.
They'll return in a major version, maybe 5.0.0.

# Animations

Animations received a lot of love in this release!

A new `query` function has been introduced in the animation DSL,
allowing to query elements in the template.
It uses `querySelectorAll` behind the scene,
so you can use an element or a class as parameter for example.
It also supports pseudo-selectors,
and that opens a few interesting possibilities!

For example,
we can now easily animate elements in a `NgFor`:

    {% raw %}
    <div [@races]="races?.length">
      <button class="btn btn-primary mb-2" (click)="toggle()">Toggle</button>
      <div *ngFor="let race of races | slice:0:4">
        <h2>{{race.name}}</h2>
        <p>{{race.startInstant}}</p>
      </div>
    </div>
    {% endraw %}

with the following animation:

    trigger('races', [
      transition('* => *', [
        query(':leave', [
          animate(1000, style({ opacity: 0 }))
        ], { optional: true }),
        query(':enter', [
          style({ opacity: 0 }),
          animate(1000, style({ opacity: 1 }))
        ], { optional: true })
      ])
    ])

Now, every time an element will leave (removed from the `races` array),
it will slowly fade out.
And when an element enters, it will slowly fade in.

<p style="text-align: center;">
  <img class="img-responsive" style="max-width: 100%" src="/assets/images/2017-05-25/query.gif" alt="Query animation" />
</p>

Another function introduced is `stagger`.
it allows to build a staggering animation,
where the elements will animate one after the other.

    trigger('races', [
      transition('* => *', [
        query(':leave', [
          stagger(500, [
            animate(1000, style({ opacity: 0 }))
          ])
        ], { optional: true }),
        query(':enter', [
          style({ opacity: 0 }),
          animate(1000, style({ opacity: 1 }))
        ], { optional: true })
      ])
    ])

<p style="text-align: center;">
  <img class="img-responsive" style="max-width: 100%" src="/assets/images/2017-05-25/stagger.gif" alt="Stagger animation" />
</p>

`animation` has also been added to build reusable animations.
The syntax allows to have dynamic parameters with default values.
When you then need to use a reusable animation,
you can call `useAnimation`,
and override the default parameters if you want to.

In our small example, we can for example define
a `changeOpacity` animation:

    {% raw %}
    const changeOpacity = animation(
      [animate(1000, style({ opacity: '{{opacity}}' }))],
      { params: { opacity: 0 } }
    );
    {% endraw %}

This animation will slowly transition to the defined opacity (by default 0).
Then we can use this animation:

    trigger('races', [
      transition('* => *', [
        query(':leave', [
          stagger(500, [
            useAnimation(changeOpacity)
          ])
        ], { optional: true }),
        query(':enter', [
          style({ opacity: 0 }),
          useAnimation(changeOpacity, { params: { opacity: 1 } })
        ], { optional: true })
      ])
    ])

You can give various options to the `useAnimation`,
like the `delay` you want to apply or the `duration`.

Note that when an element is animating,
Angular will add a `ng-animating` class on the element.
You can customize your CSS to use it,
or you can use the pseudo-selector `:animating` in a query
to style these elements.

It's now also possible to trigger "child" animations,
with the `animateChild` function.
It can be handy to animate the [router transitions for example](https://github.com/matsko/ng4-animations-preview).

Last but not least, we can now inject `AnimationBuilder` in our components,
to programmatically build animations,
and trigger them on demand from the code.

# Tests

## TestBed.overrideProvider()

The team is also working on the internals to bring interesting features,
like the possibility to test in AoT mode.
This materializes in this release with a new method on `TestBed` called
`overrideProvider`, that allows to override a provider, no matter
where it was defined
(whereas you currently have to know the module/component
that declared the provider you want to override).

This is a small step to have the same features between tests in JiT mode and in AoT mode.
And this is really interesting for developers,
as currently you can only test in JiT mode,
which can lead to discrepancies.
Indeed you can have an app that runs perfectly, and no error in your unit tests,
and then try to build the app with the AoT compiler,
and see a bunch of errors.
In a near future, we will be able to test in AoT mode too,
so you'll be sure that your app runs fine in both modes.

If you want to learn more on this topic,
take a look at the
[official design doc](https://docs.google.com/document/d/1VmTkz0EbEVSWfEEWEvQ5sXyQXSCvtMOw4t7pKU-jOwc/edit).

The AoT compiler will also become incremental soon,
allowing to use it during development.
Even if it is possible to use it right now when you're coding,
it's too slow for most applications,
as every change triggers a full rebuild of the application.

## flush()

Another utility function called `flush` has been added.
You may know that Angular comes with a built-in support for asynchronous tests.

For example, let's say you have a component which displays a welcome message
after a few seconds:

    {% raw %}
    @Component({
      selector: 'pr-welcome',
      template: '<p>{{ greetings }}</p>'
    })
    export class WelcomeComponent implements OnInit {

      greetings: string;

      ngOnInit() {
        setTimeout(() => this.greetings = 'Hello there!', 3000);
      }

    }
    {% endraw %}

After 3 seconds, the `greetings` field will be initialized
and the template will be updated.

Now how do you test this?

The first time you encounter something like this,
you may be tempted to write a naive test,
like waiting for 3 seconds before testing the content of the template:

    it('should have a greeting message', () => {
      const fixture = TestBed.createComponent(WelcomeComponent);
      const element = fixture.nativeElement;
      fixture.detectChanges();

      setTimeout(() => {
        fixture.detectChanges();
        const message = element.querySelector('p').textContent;
        expect(message).toBe('Hello there!');
      }, 3000);
    });

This will succeed... for the wrong reasons!
It will indeed always succeed,
as Jasmine will simply exit the test without running the assertions inside the `setTimeout`.

Angular offers the `async` function to wrap your test
and force Jasmine to wait for the asynchronous functions in your test to finish:

    it('should have a greeting message', async(() => {
      const fixture = TestBed.createComponent(WelcomeComponent);
      const element = fixture.nativeElement;
      fixture.detectChanges();

      setTimeout(() => {
        fixture.detectChanges();
        const message = element.querySelector('p').textContent;
        expect(message).toBe('Hello there!');
      }, 3000);
    }));

This time the test succeeds for the right reasons.
But we now have a test that needs 3 seconds to execute...

Angular allows you to do much better by using `fakeAsync` and `tick`.
`fakeAsync` is used to wrap your test into a zone where you master the time!
And `tick` can be used to fast-forward the time for as many milliseconds as you want.
We can write the same test with these two like this:

    it('should have a greeting message', fakeAsync(() => {
      const fixture = TestBed.createComponent(WelcomeComponent);
      const element = fixture.nativeElement;
      fixture.detectChanges();

      tick(3000);
      fixture.detectChanges();
      const message = element.querySelector('p').textContent;
      expect(message).toBe('Hello there!');
    }));

The test is now instantaneous and can be read as if everything is synchronous!

You still need to know how long to wait in your test,
and that's where the new `flush` function can help.
You can use `flush` instead of `tick`
and the test will automatically wait until all macrotask events (like timeout)
have been cleared from the event queue:

    it('should have a greeting message', fakeAsync(() => {
      const fixture = TestBed.createComponent(WelcomeComponent);
      const element = fixture.nativeElement;
      fixture.detectChanges();

      flush();
      fixture.detectChanges();
      const message = element.querySelector('p').textContent;
      expect(message).toBe('Hello there!');
    }));

## fixture.whenRenderingDone()

A method called `whenRenderingDone`
has also been added to the `ComponentFixture` class.
It returns a promise and is slightly similar than `whenStable`
but focuses on waiting the animations to be done.
As you can imagine,
it will be really useful if you need to test components with animations.

# Summary

That's all for this release! The focus was mainly on animations and tests,
and the team is also working on reducing the bundle size of our applications,
with the help of the Google Closure Compiler.
I think we'll learn more about that very soon!

In the meantime, all our materials ([ebook](https://books.ninja-squad.com/angular), [online training (Pro Pack)](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
