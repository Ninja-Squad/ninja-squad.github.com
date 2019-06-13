---
layout: post
title: Proxies in JavaScript
author: cexbrayat
tags: ["JavaScript"]
description: "Did you know that ES2015 introduced Proxies in JavaScript? Let's see what they bring!"
---

ES2015 introduced a new feature called Proxy,
allowing us to do some cool meta-programming code in our applications 🤓.

## Basics

JavaScript always had some meta-programming capabilities.
The use of `get` and `set` are a good example.
If you have a basic object:

    const pony = { name: 'Rainbow Dash' };

You can use:

    console.log(pony.name);
    // logs 'Rainbow Dash'

But you can also define a getter in your object,
and do something every time the property is accessed.
Even if, from the outside, it still looks like a simple property access:

    const pony = {
      get name() {
        console.log('get name');
        return 'Rainbow Dash';
      }
    };
    console.log(pony.name);
    // logs 'get name'
    // logs 'Rainbow Dash'

But what if you want to do so on an existing object that you did not write yourself?
Well, JavaScript offers `Object.defineProperty` since circa 2011:

    const pony = { name: 'Rainbow Dash' };
    Object.defineProperty(pony, 'name', {
      get() {
        console.log('get name');
        return 'Rainbow Dash';
      }
    });

## Usage in popular frameworks and limits

This is pretty cool, and lots of libraries and frameworks rely on this.
[Vue.js](https://vuejs.org/), for example, relies on this mechanism to trigger a re-rendering of the components displayed on a page,
every time the state of one of the components is updated
(this is a bit of a simplification but this is roughly the gist of it,
see the source code of
[`defineReactive`](https://github.com/vuejs/vue/blob/master/src/core/observer/index.js#L132) if you want to learn more).
To do so, the framework rewrites every property with a setter,
that just sets the initial property,
but also "warns" the framework that the property changed.

    Object.defineProperty(component, 'user', {
      set() {
        this.user = user;
        heyVueAPropertyChanged(); // 🔥
      }
    });

And it does this for every property declared when the component is initialized.
This is cool, but doesn't cover some very simple use cases.
For example, adding a property to an existing object after initialization:

    component.newProperty = 'hello';
    // won't call heyVueAPropertyChanged() 😢

To support that case,
Vue 2.x requires the usage of `Vue.set(component.newProperty, 'hello')`,
which is not really intuitive, but does the job.

`Object.defineProperty` only works with objects,
as the name says, and not with other types, like arrays.
So again, in Vue 2.x, you can't use `myArray[3] = 'hello'`,
because Vue won't pick it up 😭
(see the [official documentation](https://vuejs.org/v2/guide/list.html#Caveats)).

## Proxies to the rescue

This is where proxies, a new JavaScript feature adopted in the ES2015 specification, can be handy. 🌈

Proxies are a general computer-science concept that describes an intermediary between a caller and a callee.
In ES2015, a proxy can target objects, but also arrays, functions, or... other proxies
(but not other built-in types like `Date`).

    const target = {};
    const handler = {};
    const uselessProxy = new Proxy(target, handler);

A nice thing here is that the type of `uselessProxy`
is not `Proxy` but `object` (the type of the target).
But there is no strict equality: `uselessProxy === target; // false`.
The handler can do some smarter things, like 'trapping' properties:

    const handler = {
      get(obj, prop) {
        console.log(`${prop} was accessed`);
        return obj[prop];
      }
    };
    const target = { foo: 'bar' };
    const proxy = new Proxy(target, handler);
    proxy.foo;
    // logs 'foo was accessed'
    // logs 'bar'

There are a lot of different traps available:
`get` and `set` of course, but also `has`, `apply`, `construct`, `defineProperty`,
`deleteProperty`, etc...

For Vue.js, this is very interesting,
as proxies solve the issue of dynamic property added:

    const handler = {
      set(obj, prop, value) {
        obj[prop] = value;
        console.log(`${prop} was updated with ${value}`);
      }
    };
    const target = { };
    const proxy = new Proxy(target, handler);
    proxy.foo = 'bar';
    // logs 'foo was updated with bar'

That's why Vue.js 3.0 will
use Proxies instead of `Object.defineProperty` and will not need `Vue.set`
([most probably](https://medium.com/the-vue-point/plans-for-the-next-iteration-of-vue-js-777ffea6fabf), as Vue 3.0 is still a closed source prototype at the time of writing).
And as mentioned, it also works for arrays, so `myArray[3] = 'hello'`
will also be picked up by a proxy (and Vue 3).

Note that you can build revocable proxies with

    const { proxy, revoke } = Proxy.revocable(target, handler);
    revoke();
    proxy.foo;
    // TypeError: illegal operation attempted on a revoked proxy

Also note that proxies come with a performance cost.
It's always a bit hard to measure and compare,
but it is still several times slower than `defineProperty` for setting a property for example.
Nevertheless it would be possible to imagine proxies getting popular,
especially in UI frameworks.
Someone can imagine building a library for React that would avoid calling `setState`
(and of course [someone has](https://dev.to/solkimicreb/the-ideas-behind-react-easy-state-utilizing-es6-proxies-1dc7))
or not using ZoneJS in Angular,
and use a proxy-based reactivity system.
This was even considered by the core team,
but [declined](https://github.com/angular/angular/issues/28958#issuecomment-480088571).

We'll see if Vue 3.0 bets on this,
and how it comes of!
