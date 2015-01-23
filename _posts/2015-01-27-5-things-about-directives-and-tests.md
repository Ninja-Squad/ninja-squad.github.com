---
layout: post
title: 5 tricks about AngularJS directives and tests
author: ["cexbrayat"]
tags: ["javascript", "angularjs"]
description: 5 tricks on how to write AngularJS directives and have them tested
---

If AngularJS has tricky parts, that may be how to write directives.
Hopefully [our book](https://books.ninja-squad.com) helped you on the matter,
but it's hard to find good references on how to test directives.

Angular is well designed around tests, with a mock system, dependency injection, simulated HTTP requests, everything. But directive tests are often sidelined in this framework.

An advanced directive will have a template, its own scope with specific values, and a set of behavioral functions. Let's have a practical and not too complex example:

{% raw %}
    angular.module('myProject.directives').directive('gravatar', function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          user: '=',
          size: '@'
        },
        template: '<img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{ user.gravatar }}?s={{ sizePx }}&d=identicon"/>',
        link: function(scope) {
          if (scope.size === 'lg') {
            scope.sizePx = '40';
          } else {
            scope.sizePx = '20';
          }
        }
      };
    });
{% endraw %}

This directive displays the gravatar of a user (given an `user` parameter), with two possible sizes: 20px by default, or 40px if `size` parameter has `lg` value. This component paradigm is easy to use, as you just have to write in a template:

    <gravatar user="user" size="lg"></gravatar>

Testing a directive is like a traditional test, but with some specific instructions looking like black magic when you're a novice. You start by copy/pasting them religiously, hoping that nobody will ever ask you about their meaning.

    beforeEach(inject(function($rootScope, $compile) {
      scope = $rootScope;
      scope.user = {
          gravatar: '12345',
          name: 'Cédric'
      };

      gravatar = $compile('<gravatar user="user" size="lg"></gravatar>')(scope);

      scope.$digest();
    }));

# 1. WTF is this?

We start by creating a string containing the HTML we want to interpret. Obviously, it has to contain the directive we want to test:

    '<gravatar user="user" size="lg"></gravatar>'

Then, this element is compiled: that might be your first encounter with `$compile` service.
This is a native AngularJS service, used by the framework internally, but rarely in our code (besides test).
To make it compile, we have to provide a scope, holding all variables which the directive will access. In our example, we need an user: we then create a scope with an `user` variable, storing the suitable gravatar id.

`$digest` at the end is for running watchers, which will resolve all Angular expressions used in our template: `user.gravatar` and `sizePx`.

Once compiled we get an Angular element, like the one we get when using [angular.element](https://docs.angularjs.org/api/ng/function/angular.element) to wrap a DOM element or a HTML string as a jQuery element.

That's it, setup is done! Now it's time to really test!

What you probably don't know is that an Angular element provides some nice benefits: we can get access to the directive's scope, it being isolated or not.
In our case, the `gravatar` directive uses an isolated scope, so our test would look like :

    it('should have the correct size on scope', function() {
        expect(gravatar.isolateScope().sizePx).toBe('40');
    });

We can also make sure that generated HTML is what we expect from the directive.
There is an `html()` function which returns element's HTML as string, but that makes tests hard to maintain.
Something nicer is to test element's type, classes and attributes:

    it('should create a gravatar image with large size', function() {
        expect(gravatar[0].tagName).toBe('IMG');
        expect(gravatar.hasClass('gravatar')).toBe(true);
        expect(gravatar.attr('src')).toBe('http://www.gravatar.com/avatar/12345?s=40&d=identicon');
    });

Isn't our test great? But we can do better!

# 2. Logic in a controller

One directive's logic could be hard to test. The simplest is to externalize it in a dedicated controller, which could be easily tested:

{% raw %}
    angular.module('myProject.directives').directive('gravatar', function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          user: '=',
          size: '@'
        },
        template: '<img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{ user.gravatar }}?s={{ sizePx }}&d=identicon"/>',
        controller: 'GravatarDirectiveController'
      };
    });
{% endraw %}

That is more and more useful as your logic grows and becomes more complex.

# 3. Externalize your template

As for the logic, as soon as a template is more than one line long, let's put it in a dedicated file:

    angular.module('myProject.directives').directive('gravatar', function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          user: '=',
          size: '@'
        },
        templateUrl: 'gravatar.html',
        controller: 'GravatarDirectiveController'
      };
    });

But that introduces some side effect in your tests. If you run the one you had before externalizing the template, you would get the following error:

    Error: Unexpected request: GET gravatar.html
    No more request expected

Yes, if you have an external template, Angular would have to make an HTTP request to fetch it from server.
Thus an unexpected GET request...

But you can have the template loaded in the test to avoid this issue.
[karma-ng-html2js](https://github.com/karma-runner/karma-ng-html2js-preprocessor) (or the equivalent grunt/gulp module) can fetch templates in a dedicated module, then you just have to load it before your test.

    beforeEach(module('gravatar.html'));

Et voilà!

# 4. Recursion

If you start playing with advanced directives, someday you will need a directive using itself.
Oddly enough, that is not supported by default in AngularJS.
But you can add `RecursionHelper` module, providing a service for programatically compiling recursive directives:

    angular.module('myProject.directives')
    .directive('container', function(RecursionHelper) {
      return {
        restrict: 'E',
        templateUrl: 'partials/container.html',
        controller: 'ContainerDirectiveCtrl',
        compile: function(element) {
          return RecursionHelper.compile(element, function() {
          });
        }
      };
    });

# 5. Learn from the pros

The best way to improve your directive writing skills is to grab inspiration from open source project.
AngularUI projects hold a lot of directives, especially [UIBootstrap](http://angular-ui.github.io/bootstrap/) which is a good source.
[Pawel](https://github.com/pkozlowski-opensource), one of the main contributor, gave a talk with [some ideas](http://pkozlowski-opensource.github.io/ng-europe-2014/presentation/#/) going beyond this blog post.

And if you want to practice with some help, [our next training session](http://ninja-squad.fr/training/angularjs) will be held in Paris, France, on February 9-11, and the following one in Lyon, France, on March 9-11!
