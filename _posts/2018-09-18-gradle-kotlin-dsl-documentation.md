---
layout: post
title: The Gradle Kotlin DSL is now documented
author: jbnizet
tags: ["Kotlin", "Gradle", "Open-Source"]
description: "The whole Gradle user guide now shows Kotlin samples"
---

More than 2 years ago, [I wrote](/2016/05/31/first-kotlin-project/#conclusion) 

> Kotlin has also been announced as the future language of choice for Gradle, and I can’t wait to be able to use it for my Gradle builds.

It turns out I had to wait quite a bit. 
Using the Gradle Kotlin DSL is possible for some time now, but it was a bit of a frustrating experience due to the lack of documentation, to the point that [I wrote a migration guide](https://blog.ninja-squad.com/2018/05/22/kotlin-migration/#migrating-the-gradle-build) a few months ago.

As promised by the Gradle team, a much better, more complete, [official migration guide](https://guides.gradle.org/migrating-build-logic-from-groovy-to-kotlin/) now exists. 

The huge, fantastic Gradle user guide, however, still only shows Groovy samples. 
But not for long. 
I've spent some time, along with other folks, [translating all the samples](https://github.com/gradle/gradle/pulls?utf8=%E2%9C%93&q=is%3Apr+%236442+) of the user guide from Groovy to Kotlin. 
The result is already available in the [Gradle nightly](https://docs.gradle.org/nightly/userguide/userguide.html).

So you have no excuse anymore. 
Try the Kotlin DSL. 
It works, it is quite close to the Groovy DSL, but with less black magic involved, and it does allow auto-completion and navigation to the sources in IntelliJ.

Translating the samples has been a great experience. 
And it helped finding and fixing a few issues, too.
Contributing to an open-source project you like and respect is always gratifying. 
You get the feeling that what you're doing matters. 
Gradle folks have been nothing but kind, understanding, helpful, grateful... and demanding. 

I didn't just decide to contribute though. 
That's always intimidating: where to start? 
How to get help? 
Will I help, or will I be a burden for the maintainers?

I contributed because the Gradle team asked me to. 
The first time was after I wrote my migration guide, and then by opening [this epic issue](https://github.com/gradle/gradle/issues/6442), asking for help from contributors, and providing detailed instructions and examples on how to accomplish the task.

I wish more big open-source projects do that. 
Tagging issues with "ideal-for-contribution" is also nice.
What might seem like grunt work for project maintainers or experienced contributors is an interesting challenge and learning experience for casual, less-experienced developers who are willing to help.

So, if you're an open-source project maintainer and you read this, please make it easy to start contributing on your project. 
Ask for help. 
And communicate on public channels (blogs, tweets, etc.) about it.
