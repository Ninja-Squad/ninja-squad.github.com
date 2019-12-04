---
layout: post
title: Internationalization with @angular/localize
author: cexbrayat
tags: ["Angular 9", "Angular 8", "Angular 7", "Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4", "Angular CLI"]
description: "Angular 9.0 introduced a new i18n package called `@angular/localize`. Let's see what we can do with it!"
---

Some great progress has been made on the i18n front!
A new package called `@angular/localize` has been introduced in Angular&nbsp;9.0.

It is used under the hood to give us the same features we had previously:
translations in templates at compile time.

But it lets us hope for more in the future,
with undocumented features already available,
like translations in code,
or runtime translations instead of compilation translations only 😎.

Let's start by seeing what we can do with the help of `@angular/localize`
and the CLI in v9.

## i18n in templates

The new `@angular/localize` package offers a function called `$localize`.

The existing i18n support in Angular now uses `$localize`,
meaning that templates like:

{% raw %}
    <h1 i18n>Hello</h1>
{% endraw %}

will be compiled to `$localize` calls.

If you run `ng serve` with such a template,
you'll run into a runtime error:

    Error: It looks like your application or one of its dependencies is using i18n.
    Angular 9 introduced a global `$localize()` function that needs to be loaded.
    Please run `ng add @angular/localize` from the Angular CLI.
    (For non-CLI projects, add `import '@angular/localize/init';` to your `polyfills.ts` file.
    For server-side rendering applications add the import to your `main.server.ts` file.)

The error is self-explanatory:
as the `i18n` attributes are now converted to `$localize` calls
in the generated code,
we need to load the `$localize` function.
It could be done by default,
but as it is only required if you are using internationalization,
it would not really make sense.

That's why if your application, or one of its dependencies, uses `i18n` attributes
in its templates, then you'll have to add `import '@angular/localize/init'` to your polyfills!

The CLI offers a schematic to do this for you.
Simply run:

    ng add @angular/localize

and the CLI adds the package to your dependencies and the necessary import to your polyfills.

Then when you run your application with a simple `ng serve`,
`$localize` simply displays the original message.

Now how do you translate these messages?

The process is very similar to what we had previously.
First you run `ng xi18n` to extract the messages in a `messages.xlf` file.
Then you translate the file for your locales, for example `messages.fr.xlf`
and `messages.es.xlf`.

Then you need to configure the CLI, in `angular.json`

    {
      "projects": {
        "ponyracer": {
          "projectType": "application",
          // ...
          "i18n": {
            "locales": {
              "fr": "src/locale/messages.fr.xlf",
              "es": "src/locale/messages.es.xlf",
            }
          },
          "architect": {
            "build": {
              "builder": "@angular-devkit/build-angular:browser",
              // ...
              "configurations": {
                "production": {
                  // ...
                },
                "fr": {
                  "localize": ["fr"]
                },
                "es": {
                  "localize": ["es"]
                }
              }
            },
            "serve": {
              // ...
              "configurations": {
                "production": {
                  // ...
                },
                "fr": {
                  "browserTarget": "ponyracer:build:fr"
                },
                "es": {
                  "browserTarget": "ponyracer:build:es"
                }
              }
            }
            // ...
    }

Now, the `es` or `fr` configurations allow to run:

    ng serve --configuration=fr

And the app served is now in French!

You can also build the app with a specific locale:

    ng build --configuration=production,es

or with all the locales at once:

    ng build --prod --localize

This is a big progress compared to previous Angular versions.
We used to have to build the same application for every locale,
as the translation was part of the compilation.
Now, when Angular compiles the application, it generates `$localize` calls.
Then, when this is done, a tool takes the compiled application
and replaces all the `$localize` calls with the proper translations.
This is super fast.
You then have a bundle containing no calls to `$localize`
and all i18n strings have been translated.

Until now, you had to build your application once per locale,
and this was a full build. So let's say it's a 30s build,
and you wanted 4 locales, then you were in for 2 minutes.

With the new approach, the compilation is done once,
and then the various i18n versions are generated in a few seconds.
So you go from 2 minutes to ~40 seconds! 🌈

You then have several bundles, one per locale,
and you can serve the appropriate one to your users depending on their preference
as you used to.

This strategy is called _compile-time inlining_
as you inline the translations directly,
and then there is nothing left to do at runtime.

Now let's talk about something still undocumented,
that may change in the future,
but still interesting to know:
we can now also translate messages in our TypeScript code!

The `$localize` function I've been talking about
can be used directly. It is a peculiar function
that you can use to tag a template string for localization.

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
    export class HomeComponent {
      title = $localize`You have 10 users`;
    }
{% endraw %}

Note that you don't have to import the function.
As long as you add `import '@angular/localize/init'` once in your application,
`$localize` will be added to the global object.

You can then translate the message the same way you would for a template.
But, right now (v9.0.0), the CLI does not extract these messages
with the `xi18n` command as it does for templates.

If you serve the application and no translation is found,
`$localize` simply displays the original string,
and logs a warning in the console:

    No translation found for "6480943972743237078" ("You have 10 users").

So you have to manually add it to your `messages.fr.xlf`
with the given ID
if you want to try:

    <trans-unit id="6480943972743237078">
      <source>You have 10 users</source>
      <target>Vous avez 10 utilisateurs</target>
    </trans-unit>

The template of my `HomeComponent` then displays `Vous avez 10 utilisateurs`!

What happens if you have some dynamic expression in your template string?

    title = $localize`Hi ${this.name}! You have ${this.users.length} users.`;

The expressions will automatically be named `PH` and `PH_1` (`PH` is for placeholder).
Then you can use these placeholders wherever you want in the translations:

    <trans-unit id="4469665017544794242">
      <source>Hi <x id="PH"/>! You have <x id="PH_1"/> users.</source>
      <target>Bonjour <x id="PH"/>&nbsp;! Vous avez <x id="PH_1"/> utilisateurs.</target>
    </trans-unit>

But the best practice is to give a meaningful placeholder
name to the expression yourself,
and you can do so by using the `${expression}:placeholder:` syntax.

    title = $localize`Hi ${this.name}:name:! You have ${this.users.length}:userCount: users.`;

Then you can use this placeholder wherever you want in the translations:

    <trans-unit id="1815172606781074132">
      <source>Hi <x id="name"/>! You have <x id="userCount"/> users.</source>
      <target>Bonjour <x id="name"/>&nbsp;! Vous avez  <x id="userCount"/> utilisateurs.</target>
    </trans-unit>

## Custom IDs

Note that if you have translations with custom IDs,
they are used by `$localize` (as it was the case previously):

{% raw %}
    <h1 i18n="@@home.greetings">Hello</h1>
{% endraw %}

Then your translation looks like:

    <trans-unit id="home.greetings">
      <source>Hello</source>
      <target>Bonjour</target>
    </trans-unit>

which is obviously nicer to use.

How about for translations in code?
`$localize` also understands a syntax allowing to specify an ID:

    title = $localize`:@@home.users:You have 10 users`;

The syntax for the custom ID is the same as in the templates,
and the ID is surrounded by colons to separate it from the content of the translation.

As for the template syntax, you can also specify a description and a meaning,
to help translators with a bit of context: `:meaning|description@@id:message`.

For example:

    title = $localize`:greeting message with the number of users currently logged in@@home.users:You have 10 users`;

Keep in mind that this is a low level, undocumented API.
The Angular team or community will probably offer higher level functions
with a better developer experience (well, I hope so!).
[Locl](https://www.locl.app/) from Olivier Combe,
the author of [ngx-translate](http://www.ngx-translate.com/)
is probably worth keeping an eye on 🧐.

## Runtime translations

As I was mentioning,
if you use the CLI commands above (`ng serve --configuration=fr` or `ng build --localize`) then the application is compiled and then translated
before hitting the browser, so there are no `$localize` calls at runtime.

But `$localize` has been designed to offer another possibility:
runtime translations.
What does it mean? Well, we would be able to ship only one application,
containing `$localize` calls,
and before the application starts, we could load the translations we want.
No more N builds and N bundles for N locales \o/

Without diving too much into the details,
this is already possible with v9,
by using the `loadTranslations` function
offered by `@angular/localize`.
But this has to be done _before_ the application starts.

You can load your translations in `polyfills.ts` with:

    import '@angular/localize/init';
    import { loadTranslations } from '@angular/localize';

    loadTranslations({
      '1815172606781074132': 'Bonjour {$name}\xa0! Vous avez {$userCount} utilisateurs.'
    });

As you can see there is no locale consideration:
you just load your translation as an object,
whose keys are the strings to translate,
and the values, their translations.

Now if you run a simple `ng serve`,
the title is displayed in French!
And no more need for `ng xi18n`, or `messages.fr.xlf`
or specific configuration for each locale in `angular.json`.
In the long term, when this will be properly supported and documented,
we should be able to load JSON files at runtime,
like most i18n libraries do.
You could even achieve it in v9, it's just a bit of manual work,
but it's doable.

What about changing the locale on the fly then?
Can we load another set of translations when the application is started?
Well, no. The current way `$localize` calls are generated make them impossible to change after: you have to restart the application.
But if you don't mind refreshing your browser, it's possible.
I tested a simple strategy that works:
- a user selects a new language (for example Spanish).
- we store the language in the browser (for example in the localStorage)
- we reload the page, which restarts the application
- in `polyfills.ts`, we start by reading the language stored
- we load the proper set of translations for Spanish with `loadTranslations`.

Of course, this will be smoother in the future, either in a future version of Angular,
or via a library from the eco-system.
Anyway, we're getting closer to only ship one version of our application,
and just load the translations at runtime \o/

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
