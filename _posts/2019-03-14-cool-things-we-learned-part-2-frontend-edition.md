---
layout: post
title: Cool things we learned - part 2 - frontend edition
author: cexbrayat
tags: ["Angular", "PWA", "Cypress", "Leaflet"]
description: "We completed a project for a customer using Kotlin/Spring Boot and Angular/TypeScript,
and we tried and learned a few new things we wanted to share"
---

In the nearly 7 years of our company, we mostly worked on existing applications for our customers.
But recently, we completed two projects from scratch for two French customers.
We just completed the second one, a small Progressive Web Application for helping citizens to report issues in their city/street (think "Broken lamp" for example).
We also built the backend part of the application, and a backoffice to allow the local governments (cities, groups of cities, regions...) to see the reported issues and handle them.
This is not a new concept, but our customer is an organization that promotes open-source in French administrations.
So this application is open-source and will hopefully be used by French citizen,
as soon as the local administrations deploy it.

If you missed it, check out [part 1 about the backend](/2019/02/28/cool-things-we-learned-part-1-backend-edition/).

Let's talk about the stack we used on the frontend and a few cool things we tried and learned.

## Angular PWA

As you may have guessed, we used Angular on the frontend.
The application is mainly targeted to mobile users,
so the plan was to build a Progressive Web Application.
It was the first "real" one we built,
but it was super straight-forward, thanks to Angular and its `@angular/pwa` package.
Basically, in a CLI project, you run `ng add @angular/pwa`, and... You're done!
You'll need to customize the icons and colors to replace the default ones,
and the CLI will then generate all the required files for a proper PWA.
With this default setup, and the application served over HTTPS,
our user are offered the possibility to add the application to their home screen.
This is not the only perk:
the application will also start very fast
as the assets are cached for offline use.

We tried to push things a little further and used the [`SwUpdate`](https://angular.io/api/service-worker/SwUpdate) service offered by the `@angular/pwa` package to display a notification to our users when a new version of the application is available.
This is because the application is displayed right away from cache when a user loads it, and then the Service Worker checks if a new version is available.
If that's the case, [`SwUpdate.available`](https://angular.io/api/service-worker/SwUpdate#properties) emits a new event,
and you can ask your user if he/she wants to refresh the page to use the new version.
We had a weird issue, but we figured it out, and, as good open source citizens, [we documented it](https://github.com/angular/angular/commit/353362f5a4ce14e91cc96359a990013f10747b47) 😉.

## Leaflet and ngx-leaflet

We needed to display a map in several places in the application,
with pins marking the locations of the reported issues.
Our customer really wanted to use Open Street Map,
so Google Maps was not an option.
We went with [Leaflet](https://leafletjs.com/) and found [ngx-leaflet](https://github.com/Asymmetrik/ngx-leaflet),
a nice little library offering an Angular directive.
It proved super easy and straight-forward to use,
and we did not regret to use it!

    <!-- This displays a nice little map -->
    <!-- with options, bounds and markers defined in your component -->
    <div leaflet
        [leafletOptions]="mapOptions"
        [leafletFitBounds]="mapFitBounds"
        [leafletLayers]="mapMarkers">
    </div>

Kudos to [Asymmetrik](https://github.com/Asymmetrik) and [Ryan Blace](https://github.com/reblace) for maintaining it!

## Bootstrap and ng-bootstrap

Bootstrap is still our go-to CSS framework when we need to build a responsive application. The flex support is very good and allows to build applications that work well on mobile with little effort.

Boostrap recently introduced [spinners](https://getbootstrap.com/docs/4.3/components/spinners/) and [toasts](https://getbootstrap.com/docs/4.3/components/toasts/), which are very handy to notify your users.

We also used [ng-bootstrap](https://ng-bootstrap.github.io) to which we contribute now and then, and is always a pleasure to use
(especially that [typeahead component](https://ng-bootstrap.github.io/#/components/typeahead/examples) which always has a 😍 effect).

## ngx-speculoos and ngx-valdemort

This is a shameless plug because we wrote these tiny librairies but we really like using them 😊.

[ngx-speculoos](https://github.com/Ninja-Squad/ngx-speculoos) helps you to write more concise and readable tests and [ngx-valdemort](https://github.com/Ninja-Squad/ngx-valdemort) is a life saver when it comes to validation messages in forms.

## Cypress

You may know that the default end-to-end test tool in Angular CLI is Protractor. Which works well, but is sadly still missing features for Angular (it was built for AngularJS), for example to mock backend requests easily.

Lately, a new challenger rose: [Cypress](https://www.cypress.io/).
I was a bit suspicious at first (Selenium and Protractor marked me for life),
but after using it on several Vue projects (as it is one of the available possibilities when you setup a project with the Vue CLI), I really fell in love with it!

So this time, even if our project was a classic Angular CLI setup,
we replaced the Protractor tests with Cypress ones.
And it was a pleasure to use.

A few killing features:
- easy to setup
- easy to mock HTTP requests
- easy to test different viewports (❤️ for responsive applications)
- nice enough DSL

And my favorite: Cypress takes snapshot at each step of your tests, so you can debug very easily.
Just by hovering the step of the failing test,
you see exactly the state of the application and can play with it 🔥.

We ended up with 98.7% code coverage with unit tests,
and some important pages of the application also covered by e2e tests with Cypress
for the most common use-cases.

We had great fun building this little application:
if your company wants help to build a product, let us know!