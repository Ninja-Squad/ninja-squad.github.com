---
layout: post
title: What's coming in AngularJS 1.4
author: ["cexbrayat"]
tags: ["javascript", "angularjs"]
description: A new version of AngularJS (1.4) will be released in March next year. Let's have a look at its shiny new features!
---

*__Update__: If you want to see what actually made it in AngularJS 1.4, we've got you covered with this [article](/2015/07/21/what-is-new-angularjs-1.4/).*

The Angular Team is now hard at work designing the 2.0 version (you may have heard of it...) but that doesn't mean everything has stopped in the 1.x version. Quite the contrary: [Pete Bacon Darwin](https://twitter.com/petebd) has taken the lead of the whole team, and they are working on maintaining the 1.3 version and releasing a 1.4 version. The release will happen around ngConf, so that puts us around the end of February or early March. Then there will be a 1.5 release later in 2015, around the autumn.

But what is coming in 1.4? Let's have a look!

*__Disclaimer__: I have no special access to these informations. I'm only giving you guesses and insights, based on what's available in the [Public Design Documents](https://drive.google.com/drive/u/1/#folders/0BxgtL8yFJbacQmpCc1NMV3d5dnM/0BxgtL8yFJbacUnUxc3l5aTZrbVk/0B7Ovm8bUYiUDZkNjZ0NscWlaODg), on [Github](https://github.com/angular/angular.js/labels/1.4-candidate) and in the [AngularJS 1.4 Planning Meeting video](https://www.youtube.com/watch?v=Uae9_8aFo-o&feature). So, hey, don't be mad if part of this is not in 1.4 ;)*

# Router

One of the big things coming is the new router. As you may know, AngularJS comes with a default router in a separate module, which does the job but is quite limited. You might have needed to use something more powerful, and the beauty of the modularity is that we can swap the ngRoute module with another one coming from the community, the great [ui-router](https://github.com/angular-ui/ui-router) for example. For the 2.0 release, a [new router](https://github.com/angular/router) has been designed, inspired by the community feedback, other modules and frameworks like Durandal. The good news is that router will be compatible with the 1.x version. [Brian Ford](https://twitter.com/briantford) is currently working on it, and you can have an early preview in this sample app he wrote with the new (and still work in progress) router : [phone-kitten](https://github.com/btford/phone-kitten).

Here is a quick look at the interesting part:

    function AppController(router) {
      router.config([
        { path: 'phones'          , component: 'phoneList'   },
        { path: 'phones/:phoneId' , component: 'phoneDetail' }
      ]);
    }

As you can see, we're entering the area of components in web development. That's already the case with other JS frameworks and the standards are also going on this path. Angular 2.0 will be completely designed around components, but that's not the case for AngularJS 1.x. The new router will bring the 'component way' in the 1.x version, making us ready to code for the next major version and, maybe, easing the migration when that time will come. It's more or less a standalone thing, so it might not come exactly with the 1.4 version, but you can expect it to come soon.

# i18n

As you probably know, the internationalization support is pretty weak in AngularJS core. If you want to do some serious work, you have to rely on an external module, like the very good [angular-translate](http://angular-translate.github.io/). The team is going to do some thinking on this and we might see a new module helping us with this always tricky part of our apps.

# $http

The $http service will be refactored a little to offer some flexibility, and maybe offer a dedicated service for encoding the query parameters (for now, you can't easily override this encoding part, and that can be painful if your backend stack wants a specific format). Another service might appear to allow crafting an XMLHttpRequest if you want instead of relying on the default one that we can't access for now. On the testing side, there is also room for improvements in the mock DSL. Currently, using the $httpBackend mock, we have to manually set the expectations and flush requests, and that might become simpler in the 1.4 release, simply by testing the pending requests with a more powerful DSL.

Oh, and there is some talk about the real time communications part. For now, the only built-in service is $http, but that might change in the future. The 2.0 design docs show some work about websockets, so maybe will see some of this landing in 1.4 !

# Forms

In 1.3, there has been a lot of new stuff in forms, namely `ngModelOptions`, which allow us to tweak our forms field by field, and $asyncValidators, allowing us to now have asynchronous validation rules. The idea is to fix some corner cases, improve the performance and maybe refactor the API of `ngModelController` to make it cleaner. That will let us do some formatting and validation easily, which is not always the case for now (for example, comparing multiple fields to validate another one).

# Cookies

On the side, a more powerful `$cookies` service might appear, probably based on an existing library that will be wrapped in a new module, usable in 1.x and 2.x. The current module is useful but does not allow setting the expiration time, the path, supporting secure cookies, etc...

# Small directives as components

As I was saying earlier, we're entering the component area. You can already write components in AngularJS by using directives. John Lindquist, who you may know as Egghead for his awesome video series, has proposed a new constructor for creating simple directives (pretty much as 'service' is a shortcut for 'provider'). So we might have something like:

    app.component ('component', template, scope, controller);

as a shortcut for:

    app.directive ('component', function () {
      return {
        controllerAs: 'component',
        scope: scope,
        template: template,
        controller: controller
      };
    });

Could be nice !

# Tiny useful things

A small improvement, but a useful one, is that you'll now get a warning if you define a module twice. Currently, the second module definition is silently erasing the first one, and you can pull your hair off looking for this error.

The `limitTo` filter might finally be able to do pagination!

Some work might also take place to make a more modular core with smaller and more composable modules. That could be a great win for the mobile developers out there, who could careful craft 'their' AngularJS, only embedding what they need. This refactoring could also lead to the creation of some services, like `$time` which would be use to manage date and time, and could be easily mocked in tests.

The docs may also get a revamping, using Material Design.

Overall, we can hope for a bump in performance as work will been done on the parser and some legacy code for IE8 will be deleted.


So, it looks like the 1.x version is far from being dead and has some pretty interesting things coming. The features that did not make the cut are planned for the 1.5 version. But that, my friends, is a story I'll tell you later ;)

If you want to learn more about AngularJS, (and if you speak French), [our ebook](https://books.ninja-squad.com) is still at a free price and you can decide how much goes to a charity. We already sold 700 of these in 15 weeks!
