---
layout: post
title: Our Angular 2 book, under the cover
author: jbnizet
tags: ["Angular 2", "Angular", "ebook", "asciidoctor", "git"]
description: "How to write a technical book: tooling and process"
---

Writing a technical book is a long, painful and difficult experience. I only took a small part in the
writing of our [two Angular books](https://books.ninja-squad.com),
Cédric being the main author, but even then, I know how hard it is.

It would be even harder if we had not chosen the good tools and processes to write it. And even more importantly,
for you beloved readers (or future readers, hopefully), the book wouldn't have such a good quality.

This post will give you an overview of the tools and processes we use. You'll see that writing a book 
is very similar to writing software.

## Team work

First of all, even if Cédric is, by large, the main developer of this book (I told you: a book is a software project),
the book is actually the result of team work. The other ninjas, and even some friends external to Ninja Squad, 
helped translating and proof-reading the book. Or rather, the many iterations of the book. 

You might think the book is written from the beginning to the end, chapter by chapter. That's not how it works. 
The structure has changed several times. Some chapters have been rewritten almost completely, several times. 
Sometimes because we were not satisfied, sometimes because Angular itself made big changes to their architecture 
and APIs (the forms, router and testing modules come to mind).

It would have been a nightmare to achieve that with a giant shared Word document. So the main tools we used were a text editor,
Github, [Asciidoctor](http://asciidoctor.org/), and shell scripts.

Each chapter (in French and English), has its own asciidoc file in the project, which is hosted in a Github repo.

Each time someone makes a change, he/she creates a branch and a pull request, and the change is proof-read, commented and amended 
until we're satisfied.

Using Asciidoctor makes that very easy: the document is pure readable text, which makes it simple to diff, comment
and merge. Using the Asciidoctor toolchain, the asciidoc files are merged into a big document, and the HTML, PDF, epub and mobi
versions of the book are generated.

Even the diagrams are generated from ascii-art, using [asciidoctor-diagram](http://asciidoctor.org/docs/asciidoctor-diagram/). 
That makes it easy to produce and translate them.

We also use the comments from our Git commits, and a custom Java program, to generate a [changelog](https://books.ninja-squad.com/angular2/changelog).

## Embedded code

Proof-reading the text is a human task. To proof-read the code snippets, however, we need more than that:

 - errors in the code are more difficult to spot;
 - we started working on the book when Angular was still in alpha, so each and every release introduced breaking changes in the code;
 - readers are forgiving when it comes to typos (and several ones were kind enough to provide feedback about them), but they would be frustrated
   if the provided code snippets were incorrect.

So what's the solution here? Just as in any other software project: compilation, linting, and automated tests.

How can we compile and run automated tests for code snippets embedded in a document? Well, we can't. So that's not how we're doing it.

Asciidoctor allows including sections of external files into an asciidoc document. Here's how it looks like to extract a section of 
an external `typescript.spec.ts` in the asciidoc document:


    :specs: ../tests/specs/typescript/typescript.spec.ts

    [...]

    [source, javascript, indent=0]
    ----
    include::{specs}[tags=variable-with-types]
    ----
    
And here's how it looks like in the `typescript.spec.ts`:



    [...]
  
    it('should introduce types', () => {
      // tag::variable-with-types[]
      let poneyNumber: number = 0;
      let poneyName: string = 'Rainbow Dash';
      // end::variable-with-types[]

      // asserts
      expect(poneyNumber).toBe(0);
      expect(poneyName).toBe('Rainbow Dash');
    });

    [...]

Many tests are much more complex than this one, obviously, but Angular is very much testable, including the HTML templates, so it really 
allows testing each and every code snippet in the book. Our big test suite even allowed finding and reporting bugs in Angular itself
 sometimes.

## The pro pack

The [pro pack](https://angular2-exercises.ninja-squad.com/) is another similar story. We of course want to be able to evolve the 
exercises from one Angular version to the next, and to make sure our provided solution is correct. If you have tested our pro pack
already (the first 6 exercises are free, in case you want to), you know that each exercise comes with

 - the project as it should be to start the exercise;
 - unit and end-to-end tests to check that your solution is correct;
 - tooling to check that all the code is covered by tests, and passes lint checks;
 - the solution of the exercise.

Once again, automation and tests are key things to make that correct and maintainable. So Cédric has created a build process using custom 
scripts. The process automatically executes all the checks for each exercise of the pro pack one by one, using the files of the provided 
solution. A bit as if a robot passed through all the exercises and wrote the solution.

The [demo application](http://ponyracer.ninja-squad.com), is simply the result of the final exercise of the pro pack, amended with some 
branding and additional goodies by a final step of this whole build process.

Regarding the backend API of ponyracer, it's a Spring Boot application, written in [Kotlin](https://kotlinlang.org/), 
and [documented](http://ponyracer.ninja-squad.com/apidoc), once again using Asciidoctor
and a set of automated tests using [Spring REST Docs](http://docs.spring.io/spring-restdocs/docs/current/reference/html5/).

## The training material

Of course, our training slides follow the same philosophy. 
Nothing is more frustrating than having a wrong snippet 
of code in your slides when you give a training. 
So we use an asciidoc file per training module to write our slides, 
thanks to [asciidoctor-bespoke](https://github.com/asciidoctor/asciidoctor-bespoke). 
This awesome project lets you write your slides in plain asciidoc 
and generates an HTML presentation (with [Bespoke.js](http://markdalgleish.com/projects/bespoke.js/)).
A slide is really easy to write: 

    == Angular 2
    [%build]
    * announced in March 2014
    * RC in May 2016
    * stable in September 2016

As it is a pure HTML presentation, you can customize the CSS, and insert dynamic Angular demos right into it.
Of course, all code samples are in external files and are unit-tested just as for the ebook.

## So what?

This wasn't meant to convince you to write a book by yourself. But even if you don't, many of the tools and processes described in this
post can be used in other contexts. 

The next time your [pointy haired boss](https://en.wikipedia.org/wiki/Pointy-haired_Boss) asks you to write
a big Word document to describe your architecture or your library, you might want to convince him that much better collaborative tools are available
to software engineers.
