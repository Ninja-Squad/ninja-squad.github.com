---
layout: post
title: Angular Language Service with Ivy
author: cexbrayat
tags: ["Angular 11", "Angular"]
description: "The Angular Language Service has been rewritten in Angular v11.1. Let's see what's new"
---

One of the new features of Angular 11.1 is the new Angular Language Service.

But, wait a second, what is a Language Service?

# What is a Language Service?

Most IDEs have support for Angular, giving you autocompletion, error checking, quick info and navigation between elements of your project.

But did you know that they pretty much all use the `@angular/language-service` package under the hood?

Language services are fairly common for programming languages in general.
The editor starts a process, the language service,
and communicates with it using the
[Language Service Protocol](https://microsoft.github.io/language-server-protocol/).
Every time a file is modified,
the editor asks the language service if everything is valid,
or what it should display if an autocompletion is asked by the developer.

Angular uses this to offer a great experience in the templates:
you have errors displayed if you misspelt a component or input,
or tried to bind a property that doesn't exist.
It also checks that the values that you use in bindings and interpolations are correct.

Behind the scenes,
the Angular Language Service compiles your templates,
and communicates with the TypeScript Language Service
to know what's available.
It does so even when your template is incomplete
(you're usually in the process of writing it!)
and recovers as much info as it can,
as fast as possible
(nobody wants to wait 10 seconds on an autocompletion).

# What's new in the Angular Language Service?

Why do I talk about this?
Because the Angular team recently dedicated part of its time on a new and improved version of this language service,
to offer us an even better developer experience!

This has been done for several reasons.
First, the existing language service was using the View Engine compiler and not the modern Ivy compiler.
In the long term,
the View Engine code is going to be removed from the Angular codebase,
so the language service had to migrate.
And we were in a weird place lately:
your IDE was showing View Engine error messages in the templates,
whereas `ng serve/build` was showing Ivy error messages.
They were of course very similar but it was a bit disconcerting.

The new language service now relies on the Ivy compiler,
so all messages will be consistent between your IDE and your build process!

It was also an opportunity to add a bunch of cool features 🚀

For example, "Find all references" on an input now shows where the input is used in the TypeScript code *and also in the templates*! It means you can now rename it,
and enjoy letting the IDE do the heavy work of changing it everywhere.

It's also smarter to detect components and directives.
If you use `<button mat-button>Hello</button>`, it will now tell you that this is a `MatButton` given by Angular Material.

As the team worked on the new Language Service,
they tried to make it faster.
Funnily enough, some optimizations introduced were actually on the compiler itself,
to make it smarter in its caching mechanisms for example.
This means the work on the Language Service also made the application compilation process faster!

# How to test it?

The easiest way to give it a try is using Visual Studio Code and the [Angular Language Service extension](https://github.com/angular/vscode-ng-language-service).

When you have it installed,
go to the extension settings and enable the option **Angular: Experimental-ivy.**
If you want to try the latest version, update you Angular project to Angular v11.1+ as well!

Check out our [ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular) if you want to learn more about Angular!