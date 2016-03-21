---
layout: post
title: Ninja Tips 3 - [hidden] vs Bootstrap's help-block
author: clacote
tags: ["Angular 2", "bootstrap", "html", "css"]
description: "Tip about form validation with Angular 2 and Bootstrap"
---

Like everybody, you code enterprise software for a living
(because everybody know you can't make a living by building videogames).
And as you're not very good at designing web pages, you enjoy using CSS frameworks
like [Bootstrap](http://getbootstrap.com/), providing best practices for free,
and a nice design without thinking about it.
Alright, your websites are not very original (some say *Bootstrap is the new ugly*),
but thanks to it you're productive.
Don't blame yourself, I do exactly the same (maybe we're too old for this internet shit).

So you get to build this login form with Angular&nbsp;2 and Bootstrap.
The HTML template, if using a model-driven form instead of a template-driven one,
may look like:

    <form (ngSubmit)="login()" [ngFormModel]="loginForm">

      <div class="form-group">
        <label for="username">Login</label>
        <input id="username" type="text"
               class="form-control" ngControl="username" required>
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input id="password" type="password"
               class="form-control" ngControl="password" required>
      </div>

      <button type="submit" class="btn btn-primary">
        Sign me in
      </button>
    </form>

Congratulations, you've even thought about adding the `required` on both `<input>` elements.
Modern browsers should prevent from submitting this form with empty inputs.
But some feedback wouldn't hurt the user experience.

So you're trying to add some help text, to explain that these fields are mandatory.
Bootstrap [even has an `.help-block` class](http://getbootstrap.com/css/#forms-help-text),
which purpose is exactly this:

    <div class="form-group">
      <label for="password">Password</label>
      <input id="password" type="password"
             class="form-control" ngControl="password" required>
      <span class="help-block">
        Password is required
      </span>
    </div>

But as soon as this form is displayed, this help text is displayed,
even if the user has not typed anything yet.
At Ninja Squad, we like to have those hints and error messages be displayed only
when the user has started to input something, to keep a clean form when entering the page.
You may then leverage the validation capabilities of a super-charged Angular&nbsp;2 form:

    <div class="form-group"
         [ngClass]="{
            'has-error': password.dirty
                         && !password.valid }">
      <label for="password">Password</label>
      <input id="password" type="password"
             class="form-control" ngControl="password">
      <span class="help-block"
            [hidden]="password.pristine
                      || !password.hasError('required')">
        Password is required
      </span>
    </div>

    <button type="submit" class="btn btn-primary" [disabled]="!loginForm.valid">
      Sign me in
    </button>

What are we doing here?

* We apply, thanks to the `ngClass` directive, the Bootstrap's `.has-error` class on `div.form-group` if the `password` field:
  1. is `dirty`, i.e. modified by the user;
  2. has a validation error.
* We enable the submit button only if the form is globally valid, thanks to the `disabled` DOM property.
* We hide the `span.help-block` element thanks to the HTML&nbsp;5 `hidden` global attribute, if:
   1. the input is `pristine`, i.e. without any modification from user (the initial state);
   2. or if the field has no `'required'` validation error.

Cool! Unless... that does not really work.
The `span.help-block` will always be displayed, even with a pristine input, even without any validation error.

That is not an error in the condition.
That is not your browser not implementing this HTML&nbsp;5 `hidden` attribute.
That is also not an Angular&nbsp;2 binding bug on this HTML&nbsp;5 attribute.
This issue gave me some cold sweat,
that's why I wanted to share this *ninja tip* with you, be it very anecdotic.

The issue is between the HTML&nbsp;5 `hidden` global attribute behavior,
and the styles brought by Bootstrap's `.help-block` class.
The [`hidden` documentation](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/hidden) explains&nbsp;:

> changing the value of the CSS `display` property on an element
> with the `hidden` attribute overrides the behavior.

And, indeed, the `help-block` class brings the
`display: block;` style ([source](https://github.com/twbs/bootstrap/blob/v3.3.6/less/forms.less#L456))...

That's why your help text is always displayed,
even if your usage of Angular&nbsp;2 validation is perfect.

OK, cool! So now what?
You can either get rid of the `help-block` class (but you'll lose the style),
or you can rewrite your template to not use `hidden` attribute anymore.
And that's when the `ngIf` directive comes to play:

    <span class="help-block"
          *ngIf="password.dirty
                 && password.hasError('required')">
      Password is required
    </span>

Et voilà&nbsp;!
Of course, we needed to negate the initial condition of `[hidden]="..."` (but that's Boole Algebra 101),
and we replaced the `pristine` test by a `dirty` test, which is the exact opposite.

Thanks for the time you spent listening to me. I feel better now.
You may get back to work, or get back to read [our Angular&nbsp;2 ebook](https://books.ninja-squad.com/angular2).
