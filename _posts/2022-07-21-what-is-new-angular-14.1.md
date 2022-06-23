---
layout: post
title: What's new in Angular 14.1?
author: cexbrayat
tags: ["Angular 14", "Angular"]
description: "Angular 14.1 is out!"
---

Angular&nbsp;14.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/releases/tag/14.1.0">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This is a minor release, but it is packed with interesting features: let's dive in!

## Router new guard type: CanMatch

The router gained a new guard type in this release: `CanMatch`.

The existing `CanActivate` guard decides whether or not a navigation can go through.
`CanLoad` guards decide if a module/component can be loaded.
But there is no guard that allows matching a route depending on business logic:
that's what the `CanMatch` guard fixes.

It is now possible to define the same route several times, with different `CanMatch` guards,
and to navigate to a specific one:

    [
      { path: '', component: LoggedInHomeComponent, canMatch: [IsLoggedIn] },
      { path: '', component: HomeComponent }
    ]

Note that a `CanMatch` guard that returns `false` does not cancel the navigation:
the route is skipped and the router simply continues matching other potential routes.

Here, navigating to `/` will render `LoggedInHomeComponent` if the user is logged in
and will render `HomeComponent` otherwise. Note that the URL will remain `/` in both cases.

    @Injectable({
      providedIn: 'root'
    })
    export class IsLoggedIn implements CanMatch {
      constructor(private userService: UserService) {}

      canMatch(route: Route, segments: Array<UrlSegment>): boolean | UrlTree | Observable<boolean | UrlTree> | Promise<boolean | UrlTree> {
        return this.userService.isLoggedIn();
      }
    }

A `CanMatch` guard can also redirect to another route like other guards do.
To do so, you can return an `UrlTree`.

    @Injectable({
      providedIn: 'root'
    })
    export class IsLoggedIn implements CanMatch {
      constructor(private userService: UserService, private router: Router) {}

      canMatch(route: Route, segments: Array<UrlSegment>): boolean | UrlTree | Observable<boolean | UrlTree> | Promise<boolean | UrlTree> {
        return this.userService.isLoggedIn() || this.router.parseUrl('/');
      }
    }

As the route is not even considered when the `CanMatch` guard returns false,
it can be used to replace the `CanLoad` guard (and may even replace it in the future).

## Router navigation events

The router now indicates why a navigation was canceled in a dedicated `code` field of the `NavigationCancel` event.
Previously, you could use the `reason` field of the event to get the same information,
but this was more a workaround than an intended feature.
The `code` can now be used, and the `reason` field should only be used for debugging purposes.
The `code` property can have the following values: 
`NavigationCancellationCode.Redirect`, `NavigationCancellationCode.SupersededByNewNavigation`,
`NavigationCancellationCode.NoDataFromResolver`, or `NavigationCancellationCode.GuardRejected`.

The `NavigationError` also received a small improvement: the `target` of the navigation is now available in the event.

## Standalone components

The built-in Angular directives and pipes offered by `CommonModule` (`NgIf`, `NgFor`, `DatePipe`, `DecimalPipe`, `AsyncPipe`, etc.)
are now available as standalone!

You can now import them directly, without having to import `CommonModule`:

    @Component({
      standalone: true,
      templateUrl: './user.component.html',
      imports: [NgIf, DecimalPipe] // -> you can now use `*ngIf` and `| number` in the template
    })
    export class UserComponent {

A new function called `provideAnimations()` is also available to add the animation providers to your application,
instead of importing `BrowserAnimationModule`.
Similarly, you can use `provideNoopAnimations` instead of importing the `BrowserNoopAnimationsModule`:

    bootstrapApplication(AppComponent, {
      providers: [provideAnimations()]
    });

## inject function

The new `inject` function introduced in Angular v14.0 allows injecting dependencies
(see [our last blog post for more info](/2022/06/02/what-is-new-angular-14.0)),
and a second parameter can be used to define the injection flag.
In v14, the second parameter was a bit field: `InjectFlags.Host`, `InjectFlags.Optional`, `InjectFlags.Self`, or `InjectFlags.SkipSelf`.
In v14.1, this signature has been deprecated in favor of a more ergonomic one with an object as the second parameter:

    value = inject(TOKEN, { optional: false });

The cool thing is that it improved the type safety of the function.
Previously, TypeScript had no idea of the flag signification, and the return type was always `T | null`,
even if the injection was not optional.
This is now working properly, and the above example has a return type `T`.

## runInContext function

The `inject` function mentioned above only works in the constructor,
or to initialize a field, or in a factory function. 

So, how can you use it in a method/function that is not a constructor?
You can use the `EnvironmentInjector.runInContext` function that has been introduced for this purpose in v14.1!

For example, this doesn't work:

    export class AppComponent implements OnInit {
      ngOnInit() {
        console.log('AppComponent initialized', inject(UserService));
      }
    }

But this does, thanks to `runInContext`:

    export class AppComponent {
      constructor(private injector: EnvironmentInjector) {}

      ngOnInit() {
        this.injector.runInContext(() => {
          console.log('AppComponent initialized', inject(UserService));
        });
      }
    }

## setInput

`ComponentRef` has a new method called `setInput` that can be called to set an input.
Why is that interesting?

Currently when you are testing an `OnPush` component,
it is not easy to test if the change of an input properly triggers what you want,
because manually setting the input does not trigger the change detection.

This is now no longer a problem if you call `setInput()`!
If your `UserComponent` component has an input called `userModel`, you can now write the following code in a test:

      const fixture = TestBed.createComponent(UserComponent);
      fixture.componentRef.setInput('userModel', newUser);

`setInput()` properly sets the input (even if it is aliased), calls the `NgOnChanges` lifecycle hook and triggers the change detection!

This feature is useful in tests, but also with any kind of dynamic component.
It even opens the door for the router to set the inputs of a component dynamically based on route params
(a feature that the Vue router has for example). Maybe we'll see that in a future release!

## ContentChild descendants

The `ContentChild` decorator now supports the `descendants` option,
as `ContentChildren` does.
The default behavior does not change, and if you don't specify the option,
then `ContentChild` looks for the query in the descendants.
This behavior is the same as specifying `@ContentChild({ descendants: true })`.
But you can now change it by specifying `@ContentChild({ descendants: false })`,
in which case Angular will only do a "shallow" search and look for the direct descendants.

## Extended template diagnostics

The team added a few more "extended diagnostics".

The first one is `missingControlFlowDirective`, and it's linked to the Standalone Components story.

With this check enabled, the compiler warns us when a `ngIf`, `ngFor`, or `ngSwitch` is used in the template of a standalone component, but the corresponding directive or the `CommonModule` is not imported:

    Error: src/app/register/register.component.html:11:59 - error NG8103: 
    The `*ngFor` directive was used in the template, 
    but neither the `NgForOf` directive nor the `CommonModule` was imported.
    Please make sure that either the `NgForOf` directive or the `CommonModule`
    is included in the `@Component.imports` array of this component.

This is a nice addition, as it can be fairly easy to forget to import `CommonModule` or the directive itself 
as I pointed out in [our guide to standalone components](/2022/05/12/a-guide-to-standalone-components-in-angular).
The message even mentions the directive you need to import, which can be tricky to figure out for `*ngFor`.

The second extended diagnostics is `textAttributeNotBinding`.
When enabled, the compiler warns us when a `class`, `style`, or `attr` binding does not have the `[]`,
or if the value is not interpolated.
For example, a template with `class.blue="true"` yields the following:

    Error: src/app/register/register.component.html:2:8 - error NG8104: 
    Attribute, style, and class bindings should be  
    enclosed with square braces. For example, '[class.blue]="true"'.

Slightly related, the third one is `suffixNotSupported`.
When enabled, the compiler warns us when a suffix like `px`, `%` or `em` is used on attribute binding where it doesn't work, unlike when used in a style binding:

    Error: src/app/register/register.component.html:2:9 - error NG8106: 
    The '.px', '.%', '.em' suffixes are only supported on style bindings.

The fourth one is `missingNgForOfLet`.
when enabled, the compiler warns us when a `*ngFor` is used with the `let` keyword.
For example, `*ngFor="user of users"` throws with:

    Error: src/app/users/users.component.html:1:7 - error NG8105: 
    Your ngFor is missing a value. Did you forget to add the `let` keyword?

The fifth and last one is `optionalChainNotNullable`, and it is slightly similar to the already existing `nullishCoalescingNotNullable` check. When enabled, the compiler warns us when an unnecessary optional check is used.
For example, if `user` is not nullable, then using `{{ user?.name }}` in a template yields:

    Error: src/app/user/user.component.html:2:21 - error NG8107: 
    The left side of this optional chain operation does not include 'null' or 'undefined' in its type, 
    therefore the '?.' operator can be replaced with the '.' operator.

## Zone.js

`zone.js` has also been released in version v0.11.7, and contains a new feature that improves the debugging of asynchronous tasks, by using an experimental feature of Chrome.
You can leverage this new support by importing `import 'zone.js/plugins/async-stack-tagging';`.
When this is enabled, you'll have nicer stack traces in case of an error in an async task.


## Angular CLI

As usual, you can check out our dedicated article about the new CLI version:

👉 [Angular CLI v14](/2022/07/21/angular-cli-14.1)

That's all for this release, stay tuned!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
