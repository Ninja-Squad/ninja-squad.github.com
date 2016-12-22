---
layout: post
title: What's new in Angular 2.3 and 2.4?
author: cexbrayat
tags: ["Angular 2", "Angular"]
description: "Angular 2.3 and 2.4 are out. Which new features are included?"
---

New month, new minor release of Angular!
December is the month of the last 2.x releases,
because the next one will be... Angular 4!
If you missed the official announcement ([Igor Minar's keynote](https://www.youtube.com/watch?v=aJIMoLgqU_o)),
let me sum it up for you.

We'll have a major release every six months, according to the [plan](http://angularjs.blogspot.fr/2016/10/versioning-and-releasing-angular.html).
The next major release is planned for March 2017.
It should have been Angular 3, but the Angular router is already with a version number in 3.x (because it has been rewritten several times during Angular development). So to avoid trouble, everything will be bumped to 4.x!
Angular 3 will never exist, Angular 4 is the next one, with Angular 5 just around the corner.
And now the framework should be called just "Angular".

Don't worry, these releases are not a complete rewrite with no backward compatibility like Angular 2 was. They will _maybe_ contain deprecations and new APIs.
Technically Angular 4 is a new major release because it contains a breaking change: the minimum version of TypeScript, if you use it, will be 2.1, whereas the current minimum version is 1.8. Nothing too scary.

Back to our 2.3 and 2.4 releases: what's new in these small releases?

## Language service

One of the most exciting feature is not really in Angular itself,
but this release contains a new module that will be reaaaaally handy: a language service module. This is really similar to what TypeScript offers.
A language service allows the IDEs to provide great autocompletion.
It's basically an API that the IDE can call to ask "what smart thing can I suggest at this position in this file?".

That unlocks the possibility to have smart autocompletion in templates for example (something the IDEs are not currently great at).

There is already a VS Code plugin that [you can try here](https://github.com/angular/vscode-ng-language-service),
and JetBrains already announced they will include it in their next release (2017.1).

Here is how it works in VS Code:

<img src="/assets/images/2016-12-22/language-service.gif" />

## Inheritance

You can now use inheritance in your apps.

You already could but the decorators from the parent were ignored:
now, the "last" decorator (when you list them in the ancestor first order) of each kind will be applied.

    @Component({ selector: 'ns-pony'})
    export class ParentPony {}

    // will use the parent decorator
    export class ChildPony extends ParentPony {}

    // will use its own decorator
    @Component({ selector: 'ns-other'})
    export class OtherChildPony extends ParentPony {}

If you define the same decorator on the child,
this decorator will be used
(there is no fancy property merging from the parent and the child).

If a class inherits from a parent class and does not declare
a constructor, it inherits the parent class constructor,
meaning that the dependency injection will be properly done in the parent class.

The lifecycle hooks defined in the parent class will also be called properly, unless they are overridden in the child class:

    export class ParentPony implements OnInit {
      ngOnInit() {
        console.log('will be called');
      }
    }

    // the parent `ngOnInit` will be called
    @Component({ selector: 'ns-pony'})
    export class ChildPony extends ParentPony {}

## Route reuse strategy

The Angular router tries to optimize a few things for you,
especially when you navigate from a route to itself:
when you go from `races/12` to `races/13`,
the router will reuse the `RaceComponent` (instead of destroying it and recreating it). This is powerful, but you then need to subscribe to an observable from the router to know when the parameters change, to display the correct race for example.

This is still the default behavior, but you can now turn it off, and ask the router to destroy and recreate your component every time, by implementing [a `RouteReuseStrategy`](https://angular.io/docs/ts/latest/api/router/index/RouteReuseStrategy-class.html).

See you next year to dig in the new releases, and the upcoming Angular 4!

Check out our [ebook](https://books.ninja-squad.com) and [Pro Pack](https://angular2-exercises.ninja-squad.com/) if you want to learn more about Angular!
