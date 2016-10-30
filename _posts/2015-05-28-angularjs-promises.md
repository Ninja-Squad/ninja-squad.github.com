---
layout: post
title: "Traps, anti-patterns and tips about AngularJS promises"
author: ["jbnizet"]
tags: ["AngularJS"]
description: "AngularJS promises are not easy to understand, and are often misused. This
posts lists a few traps I've fallen into or seen people fallen into."
---

AngularJS promises are not an easy concept to understand, and the documentation, although
improving, could contain more examples on how to properly use them.

I've fallen in a few traps when using them, and have seen many trainees and StackOverflow
users fall into them as well. This post gives examples of those traps and misuses, and how to
better use promises.

## You can't escape from asynchronism

Most beginners, including myself, aren't used to asynchronous programming. The first trap
is to think you can escape from it, and transform an asynchronous call into a synchronous one.
The reality quickly hits you in the face: that's not possible.

Here's some example of code I've seen numerous times:

    app.controller('PoniesCtrl', function($scope, ponyService) {
      $scope.ponies = ponyService.getPonies();
    });

It absolutely makes sense: you want an array of ponies in the scope, so you get them from the
service allowing to get ponies from the backend:

    app.factory('ponyService', function($http) {
      var getPonies = function() {
        return $http.get('/api/ponies');
      };

      return {
        getPonies: getPonies
      };
    });

Well, that won't work. `$http.get()` is an asynchronous call. It doesn't return ponies. It returns
a promise. And this promise will be resolved when the HTTP response is available. Displaying a promise
in the view used to work in the early versions of AngularJS, but it doesn't anymore. The array itself
must be in the scope.

So let's fix the code:

      var getPonies = function() {
        $http.get('/api/ponies').success(function(data) {
          return data;
        });
      };

Once again, that won't work. Now `getPonies()` doesn't return anything anymore. The `return data` statement is not returning from `getPonies()`. It's returning from the anonymous callback function
passed to `success()`.

So let's fix the code again:

      var getPonies = function() {
        var ponies;
        $http.get('/api/ponies').success(function(data) {
          ponies = data;
        });
        return ponies;
      };

Nope. Still incorrect. The anonymous callback is not called immediately. It's called when the response
is available. And that happens long after `getPonies()` has returned. So the function still returns undefined.

All these errors come from the fact that we're trying to transform an asynchronous call into a synchronous one. That is simply not possible. If it was, the AngularJS $http service wouldn't bother
us with promises and callbacks in the first place. So let's accept this fact, and use a callback:

    app.controller('PoniesCtrl', function($scope, ponyService) {
      ponyService.getPonies(function(ponies) {
        $scope.ponies = ponies;
      });
    });

    app.factory('ponyService', function($http) {
      var getPonies = function(callbackFn) {
        $http.get('/api/ponies').success(function(data) {
          callbackFn(data);
        });
      };

      return {
        getPonies: getPonies
      };
    });

Congrats! This finally works. Except when it doesn't. What if the HTTP call fails? How can the controller know about it? We would need a second callback.

      var getPonies = function(successCallbackFn, errorCallbackFn) {
        $http.get('/api/ponies').success(function(data) {
          successCallbackFn(data);
        }).error(function(data) {
          errorCallbackFn(data);
        });
      };

But wait: that's exactly what promises allow. Passing two callbacks: one to handle a successful response, and one to handle an error response. And BTW, why wrap the callback functions into anonymous
functions? We're making our life more complex than it should be. We should simply return the HTTP promise, and let the controller deal with it.

    app.controller('PoniesCtrl', function($scope, ponyService) {
      ponyService.getPonies().success(function(data) {
        $scope.ponies = data;
      });
    });

    app.factory('ponyService', function($http) {
      var getPonies = function() {
        return $http.get('/api/ponies');
      };

      return {
        getPonies: getPonies
      };
    });

See, our first implementation of the service was right, after all. We simply had to acknowledge the fact that an asynchronous service should return a promise.

## The Real Thing - You To Me Are Everything

The previous version works fine, but it still has a design issue. The controller assumes that the
service returns an `HttpPromise`. For some bizarre reason, AngularJS thought it would be a good idea if promises returned by the $http service were different than all the other `$q` promises: they would have
additional `success()` and `error()` methods, that would basically do the same thing as `then()`, but
in a different way:

 - the callback function would take 4 arguments (data, status, headers and config) instead of just one
   (the http response object)
 - `success()` and `error()` wouldn't return a new promise as `then()` does (more on that later), but the original HttpPromise

I personally think that was a bad idea. Most asynchronous calls we do when learning AngularJS are
$http calls, and we thus start learning special HTTP promises instead of learning the real thing, with
the standard API that would also work for all the other promises.

Let's rewrite our code without assuming the service returns an HTTP promise. The service could
after all return a hard-coded list of ponies, or use websockets, for example. So let's use the
"classical" promise API.

    app.controller('PoniesCtrl', function($scope, ponyService) {
      ponyService.getPonies().then(function(data) {
        $scope.ponies = data;
      });
    });

Oops. That won't work. The actual value wrapped by the promise is not the array of ponies. It's the
HTTP response object, whose data contains the ponies. So let's fix the code again:

    app.controller('PoniesCtrl', function($scope, ponyService) {
      ponyService.getPonies().then(function(response) {
        $scope.ponies = response.data;
      });
    });

That will work fine. But once again, we're assuming, in the controller, that the service returns
an HttpPromise. Or at least a promise of something that looks like an HTTP response. Let's change
our service and make it return a promise of ponies, rather than a promise of HTTP response.

We'll thus have to create our own promise, right? So we'll have to use the `$q` service:

      var getPonies = function() {
        var defer = $q.defer();

        $http.get('/api/ponies').then(function(response) {
          defer.resolve(response.data);
        });

        return defer.promise;
      };

Great. Now we return a promise of ponies. Except when the HTTP request fails. In that case,
the returned promise will never be resolved nor rejected, and the caller won't be aware of the
error. So let's fix it:

      var getPonies = function() {
        var defer = $q.defer();

        $http.get('/api/ponies').then(function(response) {
          defer.resolve(response.data);
        }, function(response) {
          defer.reject(response);
        });

        return defer.promise;
      };

That is fine. But it's way more complex than it should be. Let's look at the documentation
of $q, and especially at the documentation of the function `then()`:

> This method returns a new promise which is resolved or rejected via the return value of the successCallback, errorCallback.

Don't know about you, but I need an example to understand this:

      var getPonies = function() {
        // then() returns a new promise. We return that new promise.
        // that new promise is resolved via response.data, i.e. the ponies

        return $http.get('/api/ponies').then(function(response) {    
          return response.data;
        });
      };

Now that's cool. We can "transform" a promise of response into a promise of ponies by transforming
the response into ponies in the `then()` callback. Note that if the HTTP response fails, the returned
promise of ponies will be rejected as well, and the controller will thus be aware of the error if it wants to:

    app.controller('PoniesCtrl', function($scope, ponyService) {
      ponyService.getPonies().then(function(data) {
        $scope.ponies = data;
      }).catch(function() {
        $scope.error = 'unable to get the ponies';
      });
    });

Have you noticed? You can simply pass it a success callback, and then chain with a call to `catch()` which only takes an error callback. I find that style more readable than the standard style of passing two callbacks to `then()`:

    app.controller('PoniesCtrl', function($scope, ponyService) {
      ponyService.getPonies().then(function(data) {
        $scope.ponies = data;
      }, function() {
        $scope.error = 'unable to get the ponies';
      });
    });

Beware that it's not strictly equivalent, though, as `catch()` is called on the promise returned by `then()`, and not on the original promise.

This post is getting long. [The next one](/2015/06/04/angularjs-promises-2/) will talk about promise chaining, resolving and rejecting, and unit tests. Stay tuned!
