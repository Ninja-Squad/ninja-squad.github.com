---
layout: post
title: Ninja Tips 2 - Make your JSON typed
author: jbnizet
tags: ["Angular 2", "typescript", "json", "tips"]
description: "Make your code safer and more maintainable by typing your JSON"
---

# Ninja Tips #2 - Angular 2: Make your JSON typed

This tip is not specifically about Angular 2, but rather about TypeScript.
But since Angular 2, like many of you probably, is what lead us to using TypeScript,
we'll explain this tip in an Angular 2 context, and compare it with JavaScript code
used in an AngularJS context.

## A typical AngularJS service returning data from the backend

A typical AngularJS service returning data from the backend using `$http`
and [promises](/2015/05/28/angularjs-promises/) looks like this:

    myModule.service('raceService', function($http) {
        this.getRaceById = function(id) {
            return $http.get('/api/races/' + id)
                        .then(function(response) {
                return response.data;
            });
        };
    });

This is quite simple, and using it in your controller is straightforward... as long
as you know what the JSON payload looks like. What is a race? What fields does it have?
This is easy enough to remember in a small application, when you just developed the 
backend service. But in a large, complex application, returning more obscure business
objects, it's not easy to know what the payload is, and reading the JS code doesn't help
much.

## The same service in Angular 2 and TypeScript

In Angular 2, with TypeScript, the same service would look like (minus imports):

    @Injectable()
    export class RaceService {
        constructor(private _http:Http) {
        }

        getRaceById(id): Observable<any> {
            return this._http.get(`/api/races/${id}`)
                             .map(response => response.json());
        }
    }

Do we have something better, compared to the AngularJS version? 

Except for the syntax sugar (class, arrow function, string interpolation),
not much. We know that the service returns an Observable, but we still don't know what a
race looks like. 

## TypeScript to the rescue

The object returned by `response.json()` is not an instance of any class you might 
have defined. It's just a basic JavaScript object full of properties. 

To us Java developers, used to strong typing, there's not much you can do: if the object 
doesn't have any specific type, then you can't pretend it has one. 

But TypeScript, despite having similar concepts, is very different from Java. TypeScript
allows defining interfaces which, unlike in Java, can define instance fields. For example:

    export interface Race {
        id: number,
        name: string,
        ponies: Array<Pony>,
        startInstant: string,
        status: RaceStatus
    }

TypeScript interfaces, a bit like Java generic types, are a purely compile-time construct. The interface doesn't exist at runtime. But for the TypeScript compiler, it defines the *shape* of an object. And you can thus define your service as

    @Injectable()
    export class RaceService {
        constructor(private _http:Http) {
        }

        getRaceById(id): Observable<Race> {
            return this._http.get(`/api/races/${id}`)
                             .map(response => response.json());
        }
    }

## What if

OK, but what if the actual JSON doesn't have any `startInstant` field, and has a `startTime`
instead?

TypeScript can't catch such a problem. At runtime, `startInstant` will be undefined. 
But at least, once you've found the bug, you can use your favorite IDE to refactor 
`startInstant` to `startTime`, and have all your TypeScript code fixed. 

More importantly, when you (or a colleague) have to modify a component using a race, 
you can just look at the `Race` interface definition to instantly know what 
a race object looks like. And you can rely on your IDE to provide reliable 
auto-completion.

So here's my ninja tip: define interfaces for the objects returned from the backend. Bonus point:
document the fields!