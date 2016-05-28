---
layout: post
title: First week with Kotlin
author: jbnizet
tags: ["kotlin", "spring"]
description: "My first week on a real Kotlin project"
---

<div style="float: right;"><img src="/assets/images/2016-05-31/kotlin.png" alt="Kotlin logo" /></div>

I read about it, I saw several talks about it, I even played a little bit with it, but now
I made one step further, and started using Kotlin on a small, but real project.

It's only been one week, and it's a brand new project, where the most experimented Kotlin programmer is... myself.
So I've hit walls, learnt quite a few things, and will probably have more mature opinions about the language in the 
future. But I'd like to share my experience at this point anyway.

## The good stuff

First of all, you shouldn't be afraid. Learning a new language is always intimidating, but when you know Java already, 
Kotlin is easy to learn. 

The documentation is top-notch; the tooling (IntelliJ, Gradle/Maven plugins) is almost as mature as for Java; 
the compatibility with Java is real, and you should thus be able to code real stuff in a few hours, even when starting from scratch.

The first thing that you enjoy is all the syntax candy that the language brings. No primitive types anymore,
no semi-colons to separate statements (and it always works fine,
unlike in some other languages), `[]` to access an element in a map, multi-line
strings for your JSON or SQL, the elvis operator for null-safe access, `foo.bar.baz` instead of `foo.getBar().getBaz()`, etc.
That doesn't seem much, but it really makes the code more readable. Another cool stuff is the extensions methods, which allow to use
plenty of utility methods that you would dream to have in Java: `list.firstOrNull()`, `list.last()`, `string.toInt()`, etc.

Something that bothers you for a few minutes, but then proves to be the greatest feature of Kotlin, is its null-safety.
Every Kotlin type comes in two flavors: `Foo` and `Foo?`. A `Foo` cannot be null. If a method accepts a `Foo`, Kotlin
won't let you pass null to the method. If you receive a `Foo` as argument, you can be sure that it's not null.
With Java 8 came Optional, but Kotlin doesn't really need it, since a method can return a `Foo?` to signal that
it can return null. And Kotlin will force you to deal with the null case. That feature, alone, is a damn good reason
to use Kotlin.

Another thing that I appreciate is the promotion of immutability and encapsulation. There are two ways to declare variables: `var` and `val`. 
`val` means `final`. Immutability is helped by making it the default, easy thing. Just use `val`. 
A List is immutable. If you want to mutate it, you
need a MutableList. A MutableList is a List, so you don't need to wrap it with `Collections.unmodifiableList()` when returning it 
from a method: the caller won't be able to add anything to the returned list, because it's not mutable. The beauty of that mechanism
is that it doesn't work by reimplementing the whole Java collection framework. The actual implementations of those types are the standard
collections that you already know and master. 

Finally, the signal/noise ratio is much bigger in Kotlin than in Java. You can write a typical dumb DTO with 5 fields in a single line of code,
using a data class. No fields, no getters, no setters, mutability of properties depending on the use of `val` or `var`. 
That is intimidating in the beginning, because you can't help but think that so much information and details are condensed in such a small
piece of code: every character matters when you read it. 

Another great thing that helps make your code clean, readable and immutable 
is the named parameters. Kotlin won't force you to use them, but they are a good alternative to the builder pattern (or setters) that you 
typically use in Java when dealing with a large data structure. For example, instead of typing

    val person = Person(1L, "Jean", "Lambert", 1975, 2000)

which is quite confusing (is *Jean* the first name or the last name? what are the two numbers at the end?)

you can type

    val person = Person(id = 1L, firstName = "Jean", lastName = "Lambert", birthYear = 1975, score = 2000)

Now, suppose you want a copy of this person with an incremented score, you can do

    val newPerson = person.copy(score = person.score + 1)

## The pain points

Nothing is perfect in this world, and Kotlin is not either. The code that I have started writing is not a library. It's a typical
"enterprise" application using Spring. But the problem would be the same with a Java EE application.

Kotlin chose to apply one of Josh Bloch's principles: *Design and document for inheritance, or else prohibit it*.
What does that mean? It means that all classes and methods in Kotlin are `final` by default: inheritance is prohibited by default.
To enable it, you must add the keyword `open` to your class, property or method.
That is probably a good choice for libraries, but when it comes to "enterprise" applications, it becomes cumbersome. Spring and Java EE
are both based on dynamic proxies, i.e. on dynamically generated classes that extend your classes. And unit-testing those classes with 
Mockito, for example, also relies on dynamically generated subclasses. The result is that Kotlin's `open` is like Java's `public`:
it's a modifier that you start adding everywhere because it is your default.

Talking about Mockito, that's another pain point. Let's take an example:

    when(mockUserDao.findByEmail(any())).thenReturn(null)

That code won't work for two reasons:

1. `when` is a keyword in Kotlin. That's easy to circumvent though. You can use `` `when` `` instead. (that is cool by the way: my tests method all look like `` fun `should do this when that`() { ... }``)
2. more problematic: `Mockito.any()` (and many other matchers) returns null, and `findByEmail()` takes a `String` as argument, not a `String?`. So that fails, too. Niek Haarman did a good job providing a [mockito-kotlin](https://github.com/nhaarman/mockito-kotlin) project that helps avoiding these two problems, but unfortunately, it's based on the latest Mockito beta version, which is not the one required by Spring Boot. It was easy enough to adapt, but still, it's a pain point.

Finally, Kotlin chose to adopt the Pascal way of declaring variables and functions: instead of typing the type first and the name after (`Foo foo`, `Foo makeFoo()`) the name comes first and the type after, even if inferred most of the time (`var foo: Foo`, `fun makeFoo(): Foo`). Note for the young hipsters reading that blog: Pascal was a very popular language back in the days, that was used by many schools to teach programming. That is a minor thing, but when you are used to the Java/JavaScript/C way for 20 years, your brain has a hard time doing it the other way. And I haven't found a way to make the IDE help me with code completion. For example, when I have to declare a field `FooBarBaz fooBarBaz` in Java, I can just type `FBB TAB Space f TAB`, and the IDE autocompletes for me. But I haven't found the way to do the same in Kotlin where the property must be defined as `val fooBarBaz: FooBarBaz`.

## Mixed feelings

There are other stuff in Kotlin that I find a little bit disturbing, but maybe just because I'm not used to it yet, or because the language will improve them later. Those include 

 - companion objects instead of static fields and methods (I haven't seen the real gain yet)
 - hard to remember syntax for creating anonymous class instances;
 - the lack of method references on objects, but that will come in a future version;
 - top-level variables and functions (I haven't seen the real gain over static variables and methods);
 - the lack of package-level visibility. It seems to be circumvented by declaring multiple classes in the same file,
   but I find it ugly: it's hard to find your classes if you're not using an IDE.
 - higher-order functions instead of named functional interfaces (I find them hard to read)
 - the fact that SAM Java interfaces can be written lambda-style, but not SAM Kotlin interfaces
 - arrays that are invariant (unlike Java, which is good), but which still don't behave like lists when it comes to equality (you still can't use `==` to compare arrays just like you would do for lists)
 - the short syntax for function (`fun foo() = bar()`) which looks like undeeded additional syntax to me
 - some other stuff that I can't remember :-).

## Conclusion

After just one week, although the language is not perfect yet, I'm definitely liking it very much. I would use it over Java 8, and even more over Java 6 or 7. Kotlin runs on Java 6, so if you're doing Android development, you should really consider Kotlin as a much better alternative. 
If you're using Java 8, like I do, you should still really consider it, for all the good stuff this article started with.

Kotlin has also been announced as the future language of choice for gradle, and I can't wait to be able to use it for my gradle builds, and benefit for gradle **and** code completion in the IDE.

Are you already using Kotlin? I'd love to know what you think about it. Comments welcome!