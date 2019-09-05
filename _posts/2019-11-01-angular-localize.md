---
layout: post
title: Internationalization with @angular/localize
author: cexbrayat
tags: ["Angular 9", "Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular 9.0 introduced a new i18n package called `@angular/localize`. Let's see what we can do with it!"
---

Some great progress has been made on the i18n front!
A new package called `@angular/localize` has been introduced in Angular&nbsp;9.0.

It offers a function called `$localize`
that you can use to tag a template string for localization.
This library is independent from Angular,
and can be used in any JS/TS project.

But maybe we should start by explaining what a tagged template string is?

## Template strings and tag functions

When using template strings, you can define a tag function,
and apply it to a template string.
Here `askQuestion` adds an interrogation point at the end of the string:

    const askQuestion = strings => strings + '?';
    const template = askQuestion`Is anyone here`;

So what's the difference with a simple function?
The tag function in fact receives several arguments:

- an array of the static parts of the string
- the values resulting of the evaluation of the expressions

For example if we have a template string
containing expressions:

    const person1 = 'Cedric';
    const person2 = 'Agnes';
    const template = `Hello ${person1}! Where is ${person2}?`;

then the tag function will receive the various static and dynamic parts.
Here we have a tag function to uppercase the names of the protagonists:

    const uppercaseNames = (strings, ...values) => {
      // `strings` is an array with the static parts ['Hello ', '! How are you', '?']
      // `values` is an array with the evaluated expressions ['Cedric', 'Agnes']
      const names = values.map(name => name.toUpperCase());
      // `names` now has ['CEDRIC', 'AGNES']
      // let's merge the `strings` and `names` arrays
      return strings.map((string, i) => `${string}${names[i] ? names[i] : ''}`).join('');
    };
    const result = uppercaseNames`Hello ${person1}! Where is ${person2}?`;
    // returns 'Hello CEDRIC! Where is AGNES?'

## i18n with $localize in TypeScript code

`$localize` uses this mechanic to let us write:

{% raw %}
    @Component({
      template: '{{ title }}'
    })
    export class HomeCompoment {
      title = $localize`You have 10 users`;
    }
{% endraw %}

Note that you don't have to import the function.
As long as you add `import '@angular/localize/init'` once in your application,
`$localize` will be added to the global object.

You can then load your translations:

    import { loadTranslations } from '@angular/localize';
    loadTranslations({
      'You have 10 users': 'Vous avez 10 utilisateurs'
    });

The template of my `HomeComponent` then displays `Vous avez 10 utilisateurs`!

As you can see there is no locale consideration:
you just load your translation as an object,
whose keys are the strings to translate,
and the values, their translations.
If you want to load another set of translations,
you can call `clearTranslations()` and then load the other translations.

Note that if no translation is found, `$localize` simply displays the original string.

What happens if you have some dynamic expression in your template string?

    title = $localize`Hi ${name}! You have ${users.length} users.`;

The expressions will automatically be named `PH` and `PH_1` (`PH` is for placeholder).
Then you can use these placeholders wherever you want in the translations
(note that the syntax is `{$placeholder}` and not `${placeholder}` as ):

    loadTranslations({
      'Hi {$PH}! You have {$PH_1} users.': 'Bonjour {$PH}\xa0! Vous avez {$PH_1} utilisateurs.'
    });


But the best practice is to give a meaningful placeholder name to the expression yourself,
by using the `${expression}:placeholder:` syntax.

    title = $localize`Hi ${name}:name:! You have ${users.length}:userCount: users.`;

Then you can use this placeholder wherever you want in the translations:

    loadTranslations({
      'Hi {$name}! You have {$userCount} users.': 'Bonjour {$name}\xa0!Vous avez {$userCount} utilisateurs.'
    });

## i18n in templates

Note that the existing i18n support in Angular now also uses `$localize`,
meaning that templates like:

{% raw %}
    <h1 i18n>Hello {{ user.name }} - {{ today | date }}</h1>
{% endraw %}

will be compiled to `$localize` calls.
Interpolations are automatically named `INTERPOLATION`, `INTERPOLATION_1`, etc.
So I can translate my title with:

    loadTranslations({
      'Hello {$INTERPOLATION} - {$INTERPOLATION_1}': 'Bonjour {$INTERPOLATION} - {$INTERPOLATION_1}'
    });


That's why if your application, or one of its dependencies, uses `i18n` attributes
in its templates, then you'll have to add `import '@angular/localize/init'` to your polyfills!

// TODO the CLI may add it via a schematic on migration, and may include it in new apps.

// TODO compile-time inlining

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
