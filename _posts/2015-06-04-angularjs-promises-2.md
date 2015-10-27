---
layout: post
title: "More traps, anti-patterns and tips about AngularJS promises"
author: ["jbnizet"]
tags: ["angularjs"]
description: "AngularJS promises are not easy to understand, and are often misused. This shows how to compose and chain them, and how they
can be unit-tested."
---

In my [previous post](/2015/05/28/angularjs-promises/), I showed
some common traps and anti-patterns that many newbies, including myself,
fall into when using basic functionalities of promises.

Let's continue this journey and see how we can use them in more complex situations.

## Chain chain chain

Imagine the following scenario: you're displaying a form allowing to edit a question of a quiz. The user should be able to click *Next* to save the current question and have the page display the next question in the edit form.

The *Next* button thus has several responsibilities:

1. check if the form is dirty. If not, continue without saving (i.e. skip step 2).
2. save the form. If the save fails due to a server-side error, stop and stay on the current question (i.e. skip step 3).
3. show the next question.

That is a mix of synchronous operations and asynchronous ones. Promises are for asynchronous operations. So let's write the code:

    $scope.next = function() {
        if (formIsDirty()) {
            saveQuestion();
        }
        getNextQuestion().then(function(question) {
            $scope.question = question;
        });
    };

Oops. Once again, that would be right if `saveQuestion()` was a synchronous, blocking operation, throwing an exception if the save failed. But that's not the case. The above code gets the next question before knowing if the save has been successful.

So change the code:

    $scope.next = function() {
        if (formIsDirty()) {
            saveQuestion().then(function() {
                getNextQuestion().then(function(question) {
                    $scope.question = question;
                });
            });
        }
        else {
            getNextQuestion().then(function(question) {
                $scope.question = question;
            });
        }
    };

That's ugly. We're repeating the same block of code twice. We now know that trying to transform an asynchronous call into a synchronous, blocking call is a dead-end. But we could do the reverse thing: transform a synchronous call into an asynchronous one:

    $scope.next = function() {
        saveQuestionIfDirty().then(function() {
            getNextQuestion().then(function(question) {
                $scope.question = question;
            });
        });
    };

    var saveQuestionIfDirty = function() {
        if (formIsDirty()) {
            var defer = $q.defer();
            defer.resolve('no need to save the question');
            return defer.promise;
        }
        else {
            return saveQuestion();
        }
    };

Well, this code is still not great. First of all, 3 lines of code just to create a resolved promise. Surely Angular allows doing that in an easier way. Let's look at [the documentation](https://docs.angularjs.org/api/ng/service/$q#when).

> `when(value);`
>
> [...]
>
> Returns a promise of the passed value or promise

So we can simplify `saveQuestionIfDirty()`:

    var saveQuestionIfDirty = function() {
        if (formIsDirty()) {
            return $q.when('no need to save the question');
        }
        else {
            return saveQuestion();
        }
    };

Let's look at `next()` now. Weren't promises supposed to avoid this pyramid of callbacks?

Here's how I would like to write the code:

    $scope.next = function() {
        saveQuestionIfDirty().then(function() {
            getNextQuestion();
        }).then(function(question) {
            $scope.question = question;
        });
    };

But that won't work. First of all, we've seen before that the promise returned by `then()`is resolved via the value returned by the callback. And our callback doesn't return anything. It should thus return the next question.

    $scope.next = function() {
        saveQuestionIfDirty().then(function() {
            return getNextQuestion();
        }).then(function(question) {
            $scope.question = question;
        });
    };

Wait a minute. Due to asynchronism, once again, there's no way for `getNextQuestion()` to return a question. All it can return is a *promise* of question. So the above code won't work, right?

Not right. Let's have a look at the documentation again:

> `then(successCallback, errorCallback, notifyCallback)`
>
> [...]
>
> This method returns a new promise which is resolved or rejected via the return value of the successCallback, errorCallback **(unless that value is a promise, in which case it is resolved with the value which is resolved in that promise using promise chaining)**.

*(emphasis mine)*

Isn't that crystal clear? No, quite frankly, it's not. Let's try to explain this with our example.

If you return a question from the `then()` callback, as we learnt in the previous post, `then()` will return a promise of this question.

But if you return a *promise* of question from the then callback, `then()` won't return a *promise of promise* of question as you could imagine. It will "flatten" the result and also return a promise of question. Which thus makes our last implementation of `$scope.next()` correct.

## Rejecting

Now let's say we would like to display an error message when saving the question fails. You remember that we can use `catch()` to register an error callback. `catch(fn)` is just an alias for `then(null, fn)`.

    var saveQuestion = function() {
        return $http.post(...).catch(function(response) {
            $scope.saveErrorDisplayed = true;
        });
    };

That's wrong again. The callback doesn't return anything. Which actually means it returns `undefined`. So you might think that it's not too bad: `saveQuestion()` will return a rejected promise, and the rejection value will be undefined. Since the rest of the code doesn't care about the rejection value, that's fine. Well, nope. Returning a value from the callback **resolves** the promise returned by `saveQuestion()` even if you return this value from an error callback. The original rejected promise of HTTP response is thus "transformed" into a resolved promise of undefined.

That's something that can be useful (we'll see an example soon), but which is undesired in that case. So how can we transform the rejected promise into another rejected promise? By chaining, again. Instead of returning a value, we can simply return a rejected promise. Just as `$q.when()` allows creating a resolved promise, `$q.reject()` allows creating a rejected promise:

    var saveQuestion = function() {
        return $http.post(...).catch(function(response) {
            $scope.saveErrorDisplayed = true;
            return $q.reject(response);
        });
    };

There is another way to do that, but it has a [nasty side-effect on unit tests](https://github.com/angular/angular.js/issues/7187), which is why I wouldn'd recommend it: throwing the rejection:

    var saveQuestion = function() {
        return $http.post(...).catch(function(response) {
            $scope.saveErrorDisplayed = true;
            throw response;
        });
    };

## Recap on chaining

* original promise is resolved
  * success callback returns value or resolved promise of value

    ⇒ then() returns a resolved promise of value

  * success callback returns rejected promise of value or throws a value

    ⇒ then() returns a rejected promise of value

  * success callback is absent

    ⇒ then() returns a promise resolved as the original
* original promise is rejected
  * error callback returns value or resolved promise of value

    ⇒ then() returns a resolved promise of value

  * error callback returns rejected promise of value or throws a value

    ⇒ then() returns a rejected promise of value

  * error callback is absent

    ⇒ then() returns a promise rejected as the original

Here's a [plunkr showing a suite of unit tests](http://plnkr.co/edit/KlrvP6GhrpThdwEW1iki?p=preview) demonstrating all these cases.

## Testing is doubting

OK. Now let's say we have a service returning a promise of poneys, and we want to test a controller $scope function that stores the poneys in the scope, or an error flag if the promise is rejected. Simplest thing you can imagine.

    it('should set poneys in $scope if poneys can be loaded', function() {
        var poneys = ['Aloe', 'Pinkie Pie'];
        spyOn(poneyService, 'getPoneys')
            .andReturn($q.when(poneys));

        $scope.showPoneys();

        expect($scope.poneys).toBe(poneys);
    });

    it('should store an error flag in the scope', function() {
        spyOn(poneyService, 'getPoneys')
            .andReturn($q.reject('error'));

        $scope.showPoneys();

        expect($scope.errorLoadingPoneys).toBeTruthy();
    });

These tests should pass, right?

Nope. Callbacks are not invoked as soon as the promise is resolved or rejected. Even if the promise is already resolved or rejected and a new callback is passed to `then()`, this callback won't be invoked immediately. AngularJS only invokes the `then()` callbacks at the next digest loop. This doesn't make much difference in classical application code, but it does make a huge one in unit tests. You need to explicitely call `$digest()` or `$apply()`on a $scope to force AngularJS to invoke the callbacks:

    it('should set poneys in $scope if poneys can be loaded', function() {
        var poneys = ['Aloe', 'Pinkie Pie'];
        spyOn(poneyService, 'getPoneys')
            .andReturn($q.when(poneys));

        $scope.showPoneys();

        $scope.$apply();

        expect($scope.poneys).toBe(poneys);
    });

    it('should store an error flag in the scope', function() {
        spyOn(poneyService, 'getPoneys')
            .andReturn($q.reject('error'));

        $scope.showPoneys();

        $scope.$apply();

        expect($scope.errorLoadingPoneys).toBeTruthy();
    });

If you're testing a service (which doesn't use a $scope), call `$apply()` on the `$rootScope` service.

## Conclusion

Promises are a powerful concept, but a quite hard one to grasp. And I've not even talked about [composition](https://docs.angularjs.org/api/ng/service/$q#all), which allows executing several asynchronous calls in parallel, and getting the result once all the promises are resolved.

But mastering them tremendously helps in writing elegant, robust code in AngularJS applications. Promises are also coming in ECMAScript 6, and even if the syntax used to create them is different, their behavior is identical. So even VanillaJS code will soon use promises.

I would have liked to have such an article when I started learning promises. That would have allowed me to avoid many mistakes. Hopefully, these two posts will constitute a resolved promise of successful and happy coding for you:

    readPosts().then(happyCoding);
