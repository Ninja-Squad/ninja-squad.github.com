---
layout: post
title: One-way binding in AngularJS
author: jbnizet
tags: ["angularjs", "directive"]
description: "One-way binding in AngularJS directives"
---

AngularJS 1.5.x has been out for a few weeks now but, despite tracking the changelog, I missed
a change that this version introduces: one-way binding in directives.

When you need to pass an argument to a directive, there are 3 ways of doing it:

- using `@`, to pass a string value. You can pass a dynamic string by using mustaches: 
   
      {% raw %}<my-directive name="{{ thePony.name }}"></my-directive>{% endraw %}

- using `=`, to pass an expression of any type: 
  
      <my-directive pony="thePony"></my-directive>

- using `&`, to pass some code that the directive is free to execute when it needs to: 

      <my-directive on-selection="setSelectedPony(thePony)"></my-directive>`

The second way does more than that, though: it establishes a two-way binding between the directive scope's `pony` and the controller 
scope's `thePony`:

 - assigning a new value to `thePony` in the controller scope will assign a new value to `pony` in the directive scope;
 - assigning a new value to `pony` in the directive scope will assign a new value to `thePony` in the controller scope;
 - changing an attribute (the color, for example) of `thePony` in the controller scope, will change the attribute in `pony`, in the directive scope;
 - changing an attribute (the color, for example) of `pony` in the directive scope, will change the attribute in `thePony`, in the controller scope.

Most of the time, the directive needs to get information from the controller, but doesn't need to change that information. 
The second bullet point above is something we don't really need. And this two-way binding has a certain cost. 

Since AngularJS 1.5, it's now possible to bind a value *one-way*, using `<`:

 - assigning a new value to `thePony` in the controller scope will assign a new value to `pony` in the directive scope;
 - assigning a new value to `pony` in the directive scope **will not** assign a new value to `thePony` in the controller scope. Don't do that, it's nasty;
 - changing an attribute (the color, for example) of `thePony` in the controller scope, will change the attribute in `pony`, in the directive scope: they both reference the same object;
 - changing an attribute (the color, for example) of `pony` in the directive scope, will change the attribute in `thePony`, in the controller scope: they both reference the same object.

As far as I know, this has been done for several reasons:

 - it aligns more closely with Angular2, where one-way binding is the norm;
 - it allows to avoid making a copy of the object passed as argument to the directive;
 - it allows creating a single watcher in the controller scope, that watches by identity instead of equality, making it faster.

More details are available in [the documentation](https://code.angularjs.org/1.5.3/docs/api/ng/service/$compile#-scope-). You can also 
experiment with [a little plunkr](http://plnkr.co/edit/0df9XJUjLR9TGmkimNE9?p=preview) I wrote to show the difference of behavior 
between the two.

Enjoy!