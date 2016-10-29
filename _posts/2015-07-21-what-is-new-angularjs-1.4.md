---
layout: post
title: What's new in AngularJS 1.4
author: cexbrayat
tags: ["javascript","angularjs"]
---

The new release of AngularJS has been out for a few weeks, and comes with its usual
lot of bug fixing (around 150) and performance improvements (digest has been boosted up).
Some work has been done on animations, but it's not really something I'm mastering,
so I'll let you dig in this part by yourself.

The whole release has a clear feeling of getting us closer to what an app will
look in Angular 2, by enforcing some practices. The sad part is that the new
router module that was announced is not in 1.4 and is delayed to 1.5.
But some nice new features have also been added.

Let's dig in!

# CommonJS

For all the fans of NPM out there, AngularJS and its modules are now packaged as
CommonJS modules, with the proper exports, and published on NPM.
That allows a simpler setup if you are using [Browserify](http://browserify.org/).

# limitTo

The `limitTo` filter can now take a second argument to indicate the beginning index,
defaulting to 0 if not provided. If the index is negative, it will start from the end:

    angular.module('limitToApp', [])
      .controller('MainCtrl', function(){
        this.letters = ['a', 'b', 'c', 'd', 'e', 'f'];
      });

using the limit filter on `letters` will output the following:

{%raw%}
    {{vm.letters | limitTo:2}} // [a, b]
    {{vm.letters | limitTo:2:0}} // [a, b]
    {{vm.letters | limitTo:2:1}} // [b, c]
    {{vm.letters | limitTo:2:-1}} // [f]
    {{vm.letters | limitTo:-2:-1}} // [d, e]
{%endraw%}

If you want to play with it: head to this [plunkr](http://plnkr.co/edit/fjBNS27qwdZivMygQjbX?p=preview)

# ngOptionDisable

A very old request was the ability to disable an option in a select,
and there was no way to do it until this release.
Now, you can dynamically specify if an option should be disabled!

Let's say you have to pick your user to pick her two favorite ponies, with two select.
You don't want her to pick the same one twice, so, in the second select,
you want to disable the option picked in the first one.
The `ngOptions` micro-syntax has been enriched with `disable when` to achieve this.

    Most fav: <select ng-model="mostFav"
      ng-options="pony for pony in ponies">
    </select>
    Second fav: <select ng-model="secondFav"
      ng-options="pony disable when isMostFav(pony) for pony in ponies">
    </select>

You can see that the second select uses the new `disable` capabilities,
by calling a function that will check if the current option is the one chosen in the first select box.
You can of course also check a boolean attribute of your model instead of calling a function.

You can test this [plunkr](http://plnkr.co/edit/axtIvHNzSgvMT99CME7S?p=preview), and pick your two favorite ponies, of course :)

# bindToController

A new boolean property in the directive definition object has been introduced
(in 1.3 actually, but I missed it), called `bindToController`, and has been improved in 1.4.
It implies that the directive must have a controller and that this controller
should have an identifier (following the 'controller as' syntax).
The whole point of this new attribute is to make directive scopes work better with `controllerAs`.

Maybe you're starting to get that Angular 2 will be component oriented,
so every release of AngularJS 1.x will try to point us in that direction,
with the ultimate goal to ease the migration.
As Angular 2 will not use a `$scope` object anymore in the controllers, we are
now encouraged to write our apps using `controllerAs` (same logic applies to the new router,
  we'll talk about this in the following posts). With the `controllerAs` syntax in a controller,
  the controller itself is published on the scope, and you can thus access attributes of the controller from the view:

    angular.module('controllers')
      .controller('ComponentCtrl', function(){
        this.name = 'hello';
      });

Then you can use it in your view template, with an alias. A lot of people use 'vm', short for ViewModel, but you can use what you want, maybe 'ctrl', or 'component', or 'componentCtrl', whatever...:

{%raw%}
    <p ng-controller="ComponentCtrl as vm">
      {{vm.name}}
    </p>
{%endraw%}

Same thing is possible with a directive:

{%raw%}
    angular.module('directives')
      .directive('pony', function(){
          return {
            controllerAs: 'vm',
            controller: function(){
              this.name = 'hello';
            },
            template: '<p>{{vm.name}}</p>'
          }
        });
{%endraw%}

    <pony></pony>

That's pretty straightforward, but almost nobody was using this as there was a major problem when you were beginning to pass some data to your directive. Let's suppose the pony's name is a directive attribute:

    <pony name="hello"></pony>

{%raw%}
    angular.module('directives')
      .directive('pony', function(){
          return {
            scope: {
              name: '='
            },
            controllerAs: 'vm',
            controller: function(){
            },
            template: '<p>{{vm.name}}</p>'
          }
        });
{%endraw%}

That will not work, because now `name` is a `$scope` attribute, and not an attribute of the controller. So you have to copy it manually. Worse: you have to watch it if it's a dynamic value, so that every changes of the attribute will be reflected in the directive rendering!

So you had to do the pretty horrible:

{%raw%}
    angular.module('directives')
      .directive('pony', function(){
          return {
            scope: {
              name: '='
            },
            controllerAs: 'vm',
            controller: function($scope){
              var vm = this;
              vm.name = $scope.name;
              // we have to add a watcher on $scope.name to make this work
              $scope.$watch('name', function(newName){
                vm.name = newName;
              });
            },
            template: '<p>{{vm.name}}</p>'
          }
        });
{%endraw%}

Now it's working, but it's awful: with `$scope` back, a manual watcher and some trick with the value of `this`... No one liked it, no one was using it.

The introduction of `bindToController` in 1.3 was here to fix this. With this new attribute, as soon as the controller is instantiated, the values of the isolate scope bindings would be available, and you wouldn't need to watch it, or use the $scope:

{%raw%}
    angular.module('directives')
      .directive('pony', function(){
          return {
            scope: {
              name: '='
            },
            controllerAs: 'vm',
            bindToController: true,
            controller: function(){},
            template: '<p>{{vm.name}}</p>'
          }
        });
{%endraw%}

Looks better, no?

In 1.4 it has been enhanced, and you can even make it work without an isolated scope now:

{%raw%}
    angular.module('directives')
      .directive('pony', function(){
          return {
            bindToController: {
              name: '='
            },
            controllerAs: 'vm',
            scope: true,
            controller: function(){},
            template: '<p>{{vm.name}}</p>'
          }
        });
{%endraw%}

If you want to fiddle with this, here is a [plunkr](http://plnkr.co/edit/IdpIIXRCP81JlWEVLs47).

# Timezones in date filter

The date filter now allows to convert to another timezone (previously you could only convert to UTC...).
So you can now do:

{%raw%}
    <p>UTC -> {{date | date:'short':'UTC'}}</p>
    <p>Paris -> {{date | date:'short':'GMT+0200'}}</p>
    <p>Auckland -> {{date | date:'short':'GMT+1300'}}</p>
{%endraw%}

# ngMessages

This module, included in the [1.3 release](/2014/10/28/nouveautes-angularjs-1.3-part-4/),
has been slightly enhanced with a few directives to enable dynamic error messages.

Let's start with the breaking change induced: `ng-include-messages`,
which was previously a directive to add as an attribute on the same element containing `ng-messages`,
is now a directive that should be a child of `ng-messages`. So you may want to check this if you upgrade to 1.4.

As I was saying, it's now possible to have dynamic error key with a new directive `ngMessageExp`.
That's something that was not possible previously. We can now give an expression, and the result
of this expression will decide if the error message is displayed or not. We can give an array as the expression:

{%raw%}
    <form name="eventForm">
      name: <input name="name" ng-model="event.name">
    </form>
    <div ng-messages="eventForm.$error">
      <div ng-message-exp="['minlength', 'maxlength']">
        The event name should be between 50 and 100 characters
      </div>
    </div>
{%endraw%}

Previously we would have to repeat the template for each error type:

{%raw%}
    <form name="eventForm">
      name: <input name="name" ng-model="event.name">
    </form>
    <div ng-messages="eventForm.$error">
      <div ng-message="minlength">
        The event name should be between 50 and 100 characters
      </div>
      <div ng-message="maxlength">
        The event name should be between 50 and 100 characters
      </div>
    </div>
{%endraw%}

It can also be interesting to work with repeaters, if you want to display an error message
that comes from your server side validation for example. You can define the full list of your
possible server errors with their code and their corresponding message in your app:

    this.serverErrors = [{ code: 'alreadyExist', message: 'Event name already exist'},
      { code: 'inappropriate', message: 'Event name is inappropriate'}];

Then instead of adding one `ngMessage` per error, you can use a repeater:

{%raw%}
    <form name="eventForm">
      name: <input name="name" ng-model="event.name" custom-server-validation>
    </form>
    <div ng-messages="eventForm.$error" ng-messages-multiple>
      <!-- custom error coming from the server -->
      <!-- with a dynamic expression to display or not the message -->
      <div ng-repeat="error in vm.serverErrors">
        <div ng-message-exp="error.code">{{error.message}}</div>
      </div>
    </div>
{%endraw%}

The error message will be displayed if an error has a code matching the dynamic expression `error.code`.

# ngCookies

This module is not really new, but it has been redesigned and enhanced.
When we give our training, we often have the same question about cookies : can we pass some options,
like the expiration date? And it was a good question, as it was not possible with the `ngCookies` module
(but of course, you could use a community alternative, [angular-cookie](https://github.com/ivpusic/angular-cookie) for example).
And it was not completely without problem, as it relied on a polling fonction to synchronize with the browser cookies.

So, some work has been done to fix this. We used to have two services `$cookieStore`
and `$cookies`, but now `$cookieStore` is deprecated. It still exists for now,
but you should use the brand new `$cookies` service. This one no longer works with properties, but has now a few methods :

- `get(key)`: quite obviously returns the value of the cookie key.
- `getObject(key)`: same but also deserializes the object stored for this key.
- `getAll()`: returns an object with every cookie key and values.
- `put(key, value, options)`: sets the value of a cookie at the given key.
- `putObject(key, value, options)`: same thing, but serializes the value first.
- `remove(key)`: deletes the given cookie.

You may have noticed the `options` parameter in `put` and `putObject` methods,
and that's also new. You can now specify a few things, as properties of the `options` object :

- `expires`: will set the expiration date at the given value (can be a string or a date).
- `secure`: boolean to indicate if the cookie is only available over secured connections.
- `domain`: limits a cookie to this domain or sub-domains.
- `path`: limits a cookie to this path or sub-paths.

Be warned : as the service no longer polls the browser, if you relied on watching
a `$cookies` properties because another library was changing it at runtime, you need to find another way!

# $timeout and $interval

These two services can now receive additional arguments in their callbacks,
to reflect what you can do [natively in the browser](http://mdn.io/setInterval#Syntax).
So if you want to pass a parameter to the callback function of `$interval` or `$timeout`, you can now do :

    var sayHello = function(param){ console.log('Hello ' + param); };
    $timeout(sayHello, 1000, true, 'world!');
    // Hello world!

# ngMock

A nice addition to the test module are the new methods `they`
(allowing to repeat a test over a collection of values),
`tthey` (run only this test) and `xthey` (exclude this test).

You can replace a repetition of `it` tests, by a single `they` test:

Before:

    it("should test with admin", function(){
      var user = admin;
      // test with admin
    });
    it("should test with user", function(){
      var user = user;
      // test with user
    });
    it("should test with anon", function(){
      var user = anon;
      // test with anon
    });

After:

    they("should test with $prop", {admin: admin, user: user, anon: anon},
      function(user){
        // will test 3 times, with user being admin, then user, anon
      });

# ngJq

A new directive is born, `ngJq`, allowing us to force the library used by `angular.element`.
You may know that by default the jqLite library is used, or jQuery if it is found on the page,
and the same behavior will happen if you omit the directive.
If you add `ngJq`, and that would be aside your `ngApp` directive, you can specify the `jQuery` name,
available under window. That is especially useful if you are using jQuery with an alias variable.

You can see it in action in this [plunkr](http://plnkr.co/edit/5KvRqYUAgqrPivH8h1tM?p=preview).

# decorator

A new method has been added to use decorators. A decorator enables to modify an
existing service to add or modify a method, and it's something that Angular was
allowing, so it's not a big news. But now, there is a `decorator` method on the
`angular` object, and it will run before the `config` phase.
The decorator will be invoked when the decorated service is first instantiated, returning the tweaked service.

    angular.decorator('externalService', function($delegate){
        $delegate.newMethod = function(){
          //....
        }
        return $delegate;
      })

# ngMessageFormat

Until now, AngularJS was offering a very limited support for internationalization
(the long word i18n stands for). You can use some filters for date, numbers or currency,
and you can manage plurals with ngPluralize, but, let's be honest,
that was not nearly enough to make a real app. As usual, the community filled in, and two open-sources emerged above the others:

- [angular-translate](https://github.com/angular-translate/angular-translate), which is probably the most popular
- [angular-gettext](https://angular-gettext.rocketeer.be/), which support the [gettext](http://en.wikipedia.org/wiki/Gettext) format.

Recently, the Angular team gathered the project leaders and [drafted a plan](https://docs.google.com/document/d/1pbtW2yvtmFBikfRrJd8VAsabiFkKezmYZ_PbgdjQOVU/edit)
to add a better support to AngularJS, and also for the brand new Angular 2.
The long term goal is to have all the necessary features to translate and localize an app,
with a better integration with professional tools to do this translation.

The new `ngMessageFormat` module is the first step towards this goal.
We, as developers, are writing HTML templates with messages that should be translated.
The goal is to be able to extract these messages, bundle them to give them to a translator,
and then reintegrate the translated messages. The last step can be done with two main options :

- loading a JSON file with the translation for each key (most popular)
- generating a template for each language (popular for very big apps, Google-style)

In the long term, maybe the 1.5 release at the end of the year, we'll have a whole toolchain to help us with this.
The new module is just here to start the effort, and is focused on handling, as you can guess, the message format, especially gender and plurals.

To use this new module, you have to include it :

    angular.module('myApp', ['ngMessageFormat']);

And then write your messages like:

{%raw%}
    {{ inbox.messages, plural,
      =0 { No message}
      =1 { 1 message}
      other { # messages}
    }}
{%endraw%}

`# messages` is the same thing as writing {%raw%}`{{inbox.messages}} messages`{%endraw%}.

Another example for a message depending on gender:

{%raw%}
    {{ receiver.gender, select,
      female { Send her a message? }
      male { Send him a message? }
      other { Send a message? }
    }}
{%endraw%}

And it can be nested as much as you want.

This not yet a full blown solution, but we'll keep an eye on it and see what it will become, and if it's interesting to use.

Well that was a long post, and I hope you'll have learnt something! If you migrate your app, be especially careful with ngAnimate, ngCookies and ngMessages, and follow the [official migration guide](https://docs.angularjs.org/guide/migration#migrating-from-1-3-to-1-4).

[Our ebook](https://books.ninja-squad.com) is now updated to the 1.4 version : all of you who already bought it should receive an email to download the updated release soon.
