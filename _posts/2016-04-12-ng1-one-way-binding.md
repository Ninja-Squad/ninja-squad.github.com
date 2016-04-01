---
layout: post
title: One-way binding in AngularJS
author: jbnizet
tags: ["angularjs", "directive"]
description: "One-way binding in AngularJS directives"
---

AngularJS 1.5.x is out for a few weeks now but, despite tracking the changelog, I missed
a change that this version introduces: one-way binding in directives.

When you need to pass an argument to a directive, there are 3 ways of doing it:

- Using `@`, to pass a string value. You can pass a dynamic string by using mustaches: 
   
      {% raw %}<my-directive name="{{ thePony.name }}"></my-directive>{% endraw %}

- Using `=`, to pass an expression of any type: 
  
      <my-directive pony="thePony"></my-directive>

- Using `&`, to pass some code that the directive is free to execute when it needs to: 

      <my-directive on-selection="setSelectedPony(thePony)"></my-directive>`

The second way does more than that, though: it establishes a two-way binding between the directive scope's `pony` and the controller 
scope's `thePony`:

 - Assigning a new value to `thePony` in the controller scope will assign a new value to `pony` in the directive scope;
 - Assigning a new value to `pony` in the directive scope will assign a new value to `thePony` in the controller scope;
 - Changing an attribute (the color, for example) of `thePony` in the controller scope, will change the attribute in `pony`, in the directive scope;
 - Changing an attribute (the color, for example) of `pony` in the directive scope, will change the attribute in `thePony`, in the controller scope.

Most of the time, the directive needs to get information from the controller, but doesn't need to change that information. 
The second bullet point above is something we don't really need. And this two-way binding has a certain cost. 

Since AngularJS 1.5, it's now possible to bind a value *one-way*, using `<`:

 - Assigning a new value to `thePony` in the controller scope will assign a new value to `pony` in the directive scope;
 - Assigning a new value to `pony` in the directive scope **will not** assign a new value to `thePony` in the controller scope. Don't do that, it's nasty;
 - Changing an attribute (the color, for example) of `thePony` in the controller scope, will change the attribute in `pony`, in the directive scope: they both reference the same object;
 - Changing an attribute (the color, for example) of `pony` in the directive scope, will change the attribute in `thePony`, in the controller scope: they both reference the same object.

More details are available in [the documentation](https://code.angularjs.org/1.5.3/docs/api/ng/service/$compile#-scope-). You can also 
experiment with [a little plunkr](http://plnkr.co/edit/0df9XJUjLR9TGmkimNE9?p=preview) I wrote to show the difference of behavior 
between the two.

Enjoy!