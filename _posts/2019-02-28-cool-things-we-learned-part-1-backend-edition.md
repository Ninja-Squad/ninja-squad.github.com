---
layout: post
title: Cool things we learned - part 1 - backend edition
author: cexbrayat
tags: ["Kotlin", "Spring", "Docker"]
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

Let's talk about the stack we used on the backend and a few cool things we tried and learned.

## Kotlin

The backend part is developed using Kotlin.
We really like Kotlin and have been using it on several internal applications, but this is the first time we were paid to build something with it 😄.
My colleague Jean-Baptiste is already quite versed in Kotlin (see [The Gradle Kotlin DSL is now documented](/2018/09/18/gradle-kotlin-dsl-documentation/)) but that was my first real project with it.

And I must admit I really like it.
Kotlin takes the pain away of a few things (like the null safety),
and is a very pragmatic language with some beautiful patterns.
I have been writing mostly TypeScript code these last years,
and you can feel some similarities between the two,
making them a good match in the same project,
one for the backend, one for the frontend.

We used Spring Boot as a framework for the backend,
and the Kotlin integration is great,
even if it is still a work in progress for some parts (see below).

## Mockk and SpringMockk

We started the project using [Mockito](https://github.com/mockito/mockito),
mostly as a reflex as we have been using it for a long time in our Java projects.

But we heard more and more about an alternative more suited for Kotlin: [MockK](https://mockk.io/).

And it's indeed nicer to use, with a Kotlin DSL that feels more natural.
One thing was lacking though: the Spring Boot integration tests support is based on Mockito
for the `@MockBean` and `@SpyBean` annotations.

Our JB Nizet thought it would be a good idea to have a support for MockK in Spring Boot,
and coded the [SpringMockK](https://github.com/Ninja-Squad/springmockk) library
that offers `@MockkBean` and `@SpykBean` annotations!

He offered the Spring team to integrate it directly into Spring Boot,
but, despite quite a few thumbs up on the [issue](https://github.com/spring-projects/spring-boot/issues/15749),
the team decided that the best way would be to make the existing annotations framework-agnostic,
but that it would not happen soon.

So we are now maintaining a new open-source library 😀.
We released `1.1.0` based on the latest MockK:

    testImplementation("com.ninja-squad:springmockk:1.1.0")

Feel free to give a try if you are writing tests in Kotlin.

## REST API documentation

When we develop a backend with a REST API, we try to document it as cleanly as possible.
[Spring REST Docs](https://spring.io/projects/spring-restdocs) is a great help to do so.
You can write a really nice documentation only using Asciidoc and tests.
For example, you can check out the documentation of the REST API we wrote for our Angular trainings:
[ponyracer.ninja-squad.com/apidoc](http://ponyracer.ninja-squad.com/apidoc).

The current DSL is not really designed for Kotlin though, so, you know what?
Yep, Jean-Baptiste wrote another open-source library:
[Spring REST Docs Kotlin](https://github.com/Ninja-Squad/spring-rest-docs-kotlin),
a Kotlin DSL to write Spring REST Docs tests.

It's not yet released because it might be integrated directly into Spring REST Docs in the future (at least we hope so).
Follow this [issue](https://github.com/spring-projects/spring-restdocs/issues/547) if you are interested.

## MailHog

We are not really Docker experts, but we often use it to ease the setup on our machines.
This time we had a fairly common thing to do in our application: send emails.
As you probably know, you need an SMTP server somewhere, so that's always a bit cumbersome to setup and test.
We stumbled upon a very cool Docker image for [MailHog](https://github.com/mailhog/MailHog),
that simplified our life quite a bit.

This is what part of our `docker-compose.yml` file looks like:

    smtp:
      image: mailhog/mailhog
      container_name: smtp
      ports:
        - 25:1025
        - 8025:8025

MailHog gives you a SMTP testing server (that doesn't really send emails) with a Web UI allowing to check the emails sent (looks like a classic email client inbox, but you see all the emails sent). Very handy!

Stay tuned for part 2 about the frontend!
