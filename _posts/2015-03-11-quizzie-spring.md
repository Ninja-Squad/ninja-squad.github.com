---
layout: post
title: "What we learnt from Quizzie: Spring"
author: jbnizet
tags: ["Ninja Squad", "quizzie", "spring"]
description: "Last week, I proudly announced Quizzie, and explained that doing it was a great way to learn new things. In this post and future posts, I'll share some of the things we learnt by making Quizzie. And I'll start with Spring."
---

Last week, I [proudly announced](/2015/03/03/quizzie-announcement/) [Quizzie](https://quizzie.io), and
explained that doing it was a great way to learn new things. In this post and future posts, I'll share some of the things we learnt
by making Quizzie. And I'll start with Spring.

I had already used Spring before, on larger projects than Quizzie, so I knew it quite well already. But Spring MVC was not part of the picture,
so I didn't know this part of the framework so well. And in the place where I currently work, we're using Java EE, and so I wanted
to stay in touch with Spring, and learn more about Spring MVC.

First thing to know about Spring MVC: despite the name, it's also an excellent framework to build RESTful applications such as Quizzie,
where the server doesn't generate HTML, but accepts and produces JSON messages. In fact, you can mix traditional view-dispatching methods
with RESTful methods producing JSON in the same controller.

Here are the few things I particularly like about Spring and Spring MVC.

## Testing

![Test results in SonarQube](/assets/images/quizzie/test-results.png)

Spring provides top-notch support for tests. And we do care about tests, both in the backend and in the frontend.

Of course, dependency injection is all about testability, and Spring is, first and foremost,
a dependency injection framework. So it's not surprising for Spring-based code to be testable. But Spring goes further than that.

A lot of what happens in Spring MVC depends on annotations: the mapping of URLs to methods, the
JSON marshalling, the content negociation, etc. You might have perfectly correct code, but mess up your annotations, and traditional
unit tests won't detect those errors. Spring comes with a testing API that allows sending fake HTTP requests to a controller
and have them handled the same way as real requests would be handled in production. You can then test that the request has been handled
properly, and has produced the correct JSON structure, in a readable and relatively intuitive way.

Those kinds of tests are traditionally integration tests, which are much heavier than unit tests: you need the application
deployed, a database to be set up with test data, and running those tests is sloooow. That's not the case with Spring MVC tests, where
those fake requests can be sent to a controller which has been injected with mock dependencies, making the tests much easier to set up,
and much faster to run.

## WebSockets

Quizzie uses websockets. If you're using Quizzie and someone sends you a comment, or upvotes one of your quizzes,
you'll be instantly notified thanks to websockets.

The websocket support is new in the standard Java EE stack, and is quite low-level. Spring goes further than that
by integrating two useful bricks:

  - SockJS, to be able to fallback to other notifications methods in case WebSockets are not supported
  - Stomp, which provides a higher-level protocol over the TCP connection, allowing for easy publish/subscribe notifications.

## Events

OK. Spring has events, but they're not as easy and useful as the one provided by CDI. For example, you can't fire an event and be notified
only if the current transaction commits.

But Spring is both very well documented, open-source, and open to customizations. I was able to implement
such kinds of transactional events quite easily, and was even [prepared to release](https://github.com/Ninja-Squad/spring-events/pull/1) that feature as an open-source library.
But then I saw that there was already a RFE in Spring's bug tracker for this functionality. So I gave my opinion, discussed with
the Spring developers, and good news: [transactional events are coming in the next release of Spring](https://spring.io/blog/2015/02/11/better-application-events-in-spring-framework-4-2).

Where do we use such events in Quizzie?

For example, when you finish a game, you might gain the [*player*](https://quizzie.io/badges/player) badge, but also maybe the
[*champion*](https://quizzie.io/badges/champion) badge and also maybe the [*pioneer*](https://quizzie.io/badges/pioneer) badge.
So instead of putting all this badge handling code in the `finishGame()` method, we simply fire a `GamePlayed` event.

Badge handlers observing the `GamePlayed` event are then notified and asynchronously check if the badge they're responsible for should be assigned or not.
This is the good old oberver pattern, which really helps in keeping focused, decoupled code, having a single responsibility. And if the badge is assigned,
a notification is sent using Spring's WebSocket support.

## AOP

Spring also has great support for AOP. Basically, an aspect is some piece of code that you can plug in before, after or around some method calls,
without repeating the code everywhere. If you use Spring or Java EE, you're heavily relying on aspects: every time you call a transactional method,
an aspect intercepts the call and starts the transaction if necessary. And when the method returns, the aspect commits or rollbacks the transaction.

You can easily define and plug your own aspects on all Spring bean methods. We use that for example for security. For example, every time we want a
Spring controller method to only be callable if the current user is authenticated, we annotate it with `@Authenticated`.

## Spring-Data

We use JPA (with Hibernate as an implementation) to access our PostgreSQL database. I'm sure many of you will find JPA overkill, slow as molasses,
too complex, or even evil. That's not my opinion. I've taken the time to learn JPA, to understand how it works, when, why and how it queries the database.
If you make this effort, my opinion is that it makes most of your code easier to write and maintain.

Spring-Data JPA is another useful layer on top of it. It makes the easy trivial, the complex easier, and the even more complex possible.

It provides a good, customizable base class for repositories. It also allows writing simple methods easily, by just respecting a naming convention
or providing a JPQL query as an annotation: Spring-Data will execute the query for you.
Its pagination support is also useful. Overall, don't be fooled though. For more complex queries or scenarios, you will still have to write custom
JPA code. But that is well supported by Spring-Data, so no problem.
