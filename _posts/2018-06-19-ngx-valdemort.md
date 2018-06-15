---
layout: post
title: ngx-valdemort &ndash; super simple, consistent validation error messages for Angular
author: jbnizet
tags: ["Angular", "ngx-valdemort", "validation", "error"]
description: "ngx-valdemort: super simple, consistent validation error messages for Angular"
---

<div style="float: right;"><img src="/assets/images/ngx-valdemort.svg" alt="ngx-valdemort logo" style="width: 150px;"/></div>

We [recently introduced ngx-speculoos](/2018/06/05/announcing-ngx-speculoos/), which reduces boilerplate in Angular unit tests. Check it out if you missed it. 

Another place where a lot of boilerplate is needed is *forms*, and especially in validation error messages. Here's an example of such boilerplate:

```
<div class="invalid-feedback" *ngIf="form.get('email').invalid && (f.submitted || form.get('email').touched)">
  <div *ngIf="form.get('email').hasError('required')">
    The email is required
  </div>
  <div *ngIf="form.get('email').hasError('email')">
    The email must be a valid email address
  </div>
</div>
```

That is just for two error messages, on one field of one form. 

When you do that for all fields of all your forms, you end up with a lot of duplication of the same logic, and a high risk of misspelling control names. 

Developers also end up copying and pasting these snippets, and tend to forget to rename the field name or error types in one or two places, introducing bugs.

Adding a new validation rule on a field means that a new error message must also be added.

Wouldn't it be nice to be able to replace that mess with something like this?

```
<val-errors controlName="email" label="The email"></val-errors>
```

That's what ngx-valdemort allows. And much more. You can override a default message by a custom one when needed. You can choose if you want one or all error messages. You can configure when to display error messages, in a central place, to ensure consistency in all your forms.

Learn more and see it in action on [our project page](https://ngx-valdemort.ninja-squad.com).

It's free and open-source. Tell us if you like it. Also tell us if you don't: we could improve it.
[The project is on Github](https://github.com/Ninja-Squad/ngx-valdemort).
