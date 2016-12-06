---
layout: post
title: Why do we have to use @Injectable() in Angular?
author: cexbrayat
tags: ["Angular 2", "Angular", "tips"]
description: "Injectable must be added on services. But do we really need it?"
---

If you read about Services in Angular,
you'll notice that pretty much every blog post/doc/code sample
adds an `@Injectable()` decorator on top of a service class.

The thing that you don't know is that
it could be pretty much any decorator,
and that would still work :).

Let's take an example:

    @Component({
      selector: 'ponyracer-app',
      template: '<h1>PonyRacer</h1>'
    })
    export class PonyRacerAppComponent {
      constructor(private appService: AppService) {
        console.log(appService);
      }
    }

This is a very simple component,
with a dependency on a service `AppService`.
The service looks like:

    export class AppService {
      constructor() {
        console.log('new app service');
      }
    }

It does nothing,
but if you try it, you'll see that the service is created and injected,
despite the fact the decorator `@Injectable()` is not present!

Why does that work? Let's check the JavaScript generated from these TypeScript classes:

    var AppService = (function () {
        function AppService() {
          console.log('new app service');
        }
        return AppService;
    }());
    exports.AppService = AppService;

I skipped a bit of generated code to focus on the interesting part.
The class `AppService` generates a pretty simple JavaScript.
Let's compare that to the `PonyRacerAppComponent` class:

    var PonyRacerAppComponent = (function () {
        function PonyRacerAppComponent(appService) {
            this.appService = appService;
            console.log(appService);
        }
        PonyRacerAppComponent = __decorate([
            core_1.Component({
                selector: 'ponyracer-app',
                template: '<h1>PonyRacer</h1>'
            }),
            __metadata('design:paramtypes', [app_service_1.AppService])
        ], PonyRacerAppComponent);
        return PonyRacerAppComponent;
    }());

Wow! That's much more code!
Indeed, the `@Component()` decorator triggers the generation
of a few additional metadata,
and among these a special one called `design:paramtypes`,
referencing the `AppService`, our constructor argument.
That's how Angular knows what to inject in our Component, cool!

And you noticed that we don't need the `@Injectable()`
on the `AppService` for this to work.

But let's say that now, our `AppService` has a dependency itself:

    export class AppService {
      constructor(http: HttpService) {
        console.log(http);
      }
    }

If we launch our app again, we'll now have an error:

    Error: Can't resolve all parameters for AppService: (?).

Hmm... Let's check the generated JS:

    var AppService = (function () {
        function AppService(http) {
            console.log(http);
        }
        return AppService;
    }());
    exports.AppService = AppService;

Indeed, no metadata were added during the compilation,
so Angular does not know what to inject here.

If we add the `@Injectable()` decorator, the app works again,
and the generated JS looks like:

    var AppService = (function () {
        function AppService(http) {
            console.log(http);
        }
        AppService = __decorate([
            core_1.Injectable(),
            __metadata('design:paramtypes', [http_service_1.HttpService])
        ], AppService);
        return AppService;
    }());
    exports.AppService = AppService;

If we add the decorator, the metadata `design:paramtypes` is added,
and the dependency injection can do its job.
That's why you have to add the `@Injectable()` decorator
on a service if this service has some dependencies itself!

But the funny thing is that you could add any decorator.
Let's build our own (useless) decorator:

    function Foo() {
      return (constructor: Function) => console.log(constructor);
    }

    @Foo()
    export class AppService {
      constructor(http: HttpService) {
        console.log(http);
      }
    }

The `@Foo()` decorator does not do much,
but if we check the generated JS code:

    var AppService = (function () {
        function AppService(http) {
            console.log(http);
        }
        AppService = __decorate([
            Foo(),
            __metadata('design:paramtypes', [http_service_1.HttpService])
        ], AppService);
        return AppService;
    }());
    exports.AppService = AppService;

Wow, the metadata were generated!
And indeed, the app still work perfectly!

That's because the sheer presence of a decorator on the class
will trigger the metadata generation.
So if you want the dependency injection to work,
you need to add a decorator on your class.
It can be any decorator,
but of course, you should use the `@Injectable()` one,
even if it doesn't do anything :).
The [best practice](https://angular.io/docs/ts/latest/tutorial/toh-pt4.html#!/%23injectable-services) is to add it on every service,
even if it doesn't have any dependencies on its own.

Check out our [ebook](https://books.ninja-squad.com) and [Pro Pack](https://angular2-exercises.ninja-squad.com/) if you want to learn more about Angular!
