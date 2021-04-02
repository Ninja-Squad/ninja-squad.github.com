---
layout: post
title: Migrating from TSLint to ESLint
author: cexbrayat
tags: ["Angular 12", "Angular"]
description: "A few tips on how to handle the migration from the deprecated TSLint to ESLint"
---

As you probably know, [TSLint](https://palantir.github.io/tslint/) has been deprecated since 2019.
But, until now, the Angular CLI was still generating projects with built-in support for TSLint,
so most Angular developers out there have TSLint in their project.

With the upcoming Angular CLI v12 release, this is no longer the case:
the CLI [now generates](https://github.com/cexbrayat/angular-cli-diff/compare/12.0.0-next.4...12.0.0-next.5) projects without the `lint` configuration.

Angular v12 will also require TypeScript v4.2, and TSLint is misbehaving with this new version
(and that's probably not going to be fixed of course).

All this points to an obvious task for us Angular developers (and all TypeScript developers really):
we have to migrate to an alternative.

## Prettier

Or do we?

TSLint was super useful in the early days, as the TypeScript compiler was not as smart and as strict as it is now.
It was also fulfilling the task of a code formatter,
making sure that the lines had the proper length, semicolons weren't missing, etc.

Nowadays, this code formatter part has a very popular alternative: [Prettier](https://prettier.io/).

We have been using it in all our projects for quite some time,
and we honestly love it.
Even if it sometimes does weird formatting, at least it formats code _consistently_.

Most IDEs out there have a good support for Prettier,
making it quite easy to format your code when you develop.

Prettier can be quite long to run on large code bases though.
You can run it as a pre-commit hook just on staged files,
or you can take a look at [pretty-quick](https://github.com/azz/pretty-quick) to speed things up.

As a first step in your TSLint migration,
I would then recommend to set up Prettier,
and remove all formatting rules for your `tslint.json` configuration
(like `indent`, `max-line-length`, `quotemark`, `semicolon`, etc.).

I use the following Prettier configuration:

    singleQuote: true
    printWidth: 140
    trailingComma: none
    arrowParens: avoid
    overrides:
      - files: "*.component.html"
        options:
          parser: angular
      - files: "*.html"
        options:
          parser: html

Then let's go to the second step,
and add ESLint.

## ESLint

[ESLint](https://eslint.org/) has been around for quite some time.
With [@typescript-eslint](https://github.com/typescript-eslint/typescript-eslint),
we can run ESLint in a TypeScript project.
Most TSLint rules have an ESLint or a @typescript-eslint version.

TSLint also offers the possibility to load additional rules.
For example, most Angular projects have been using [codelyzer](https://github.com/mgechev/codelyzer),
a set of rules dedicated to check Angular best practices.

The good news is that an ESLint alternative exists with
[@angular-eslint](https://github.com/angular-eslint/angular-eslint).

@angular-eslint even comes with an automatic migration,
so that's what we're going to use to ease the transition.

## Migrating an Angular project

First you need to add @angular-eslint.

    ng add @angular-eslint/schematics

This adds a bunch of dependencies to your application.
Then you can run the automatic migration:

    ng g @angular-eslint/schematics:convert-tslint-to-eslint your_project_name

This will:

- add an `.eslint.json` configuration file to your project with a set of rules that matches your `tslint.json` configuration.
- migrate all the exceptions (`tslint-disable`) you have in your code to their ESlint version
- update the `angular.json` configuration to use ESLint instead of TSLint

`ng lint` now runs ESLint!
You may have a bunch of files to fix.
If you want to keep this exact configuration,
try running `ng lint --fix` to do the bulk of the work.
And then fix the remaining ones by hand.

But as you'll quickly see, the generated configuration is quite big!
Maybe it's time to simplify a few things.

## Simplify the ESLint config

The migration tries to mimic exactly your TSLint config.
This resulted in an overwhelming configuration in most of our projects.

In the end, I dropped most of the generated configuration,
to only include:

    {
      "root": true,
      "ignorePatterns": ["dist", "coverage"],
      "parserOptions": {
        "ecmaVersion": 2020
      },
      "overrides": [
        {
          "files": ["*.ts"],
          "parserOptions": {
            "project": ["tsconfig.json"],
            "createDefaultProgram": true
          },
          "extends": [
            "plugin:@angular-eslint/recommended",
            "eslint:recommended",
            "plugin:@typescript-eslint/recommended",
            "plugin:prettier/recommended"
          ],
          "rules": {
            "@typescript-eslint/no-non-null-assertion": "off"
          }
        },
        {
          "files": ["*.html"],
          "extends": ["plugin:@angular-eslint/template/recommended", "plugin:prettier/recommended"],
          "rules": {}
        }
      ]
    }

This uses the recommended set of rules from ESlint, @typescript-eslint and @angular-eslint.
I also added Prettier!
For this to work, you'll have to add `eslint-config-prettier` and `eslint-plugin-prettier`
as dev dependencies in your `package.json` file.

Now when running `ng lint --fix`, ESLint will check all the recommended rules and delegate the formatting to Prettier.

If you opt for this simplified configuration,
you'll be able to remove a bunch of now useless eslint dependencies from your `package.json` file: `eslint-plugin-import`, `eslint-plugin-jsdoc`, `eslint-plugin-prefer-arrow` and `@angular-eslint/schematics`.
You'll get a missing peer dependency warning when running `npm install`,
but it's a low price to pay compared to dragging these dependencies.

You can now add or remove rules, and fix the issues that the linter found.

Final trick: if you want to check which rule is consuming the most time,
you can run:

    TIMING=1 ng lint

For example, after the automatic migration, I had:

    Rule                                       | Time (ms) | Relative
    :------------------------------------------|----------:|--------:
    import/no-deprecated                       |  1730.585 |    71.2%
    jsdoc/check-alignment                      |   113.121 |     4.7%
    @typescript-eslint/naming-convention       |   102.069 |     4.2%
    jsdoc/newline-after-description            |    74.178 |     3.1%
    max-len                                    |    60.109 |     2.5%
    object-shorthand                           |    36.812 |     1.5%
    @typescript-eslint/type-annotation-spacing |    19.201 |     0.8%
    prefer-arrow/prefer-arrow-functions        |    18.982 |     0.8%
    one-var                                    |    18.938 |     0.8%
    id-match                                   |    17.681 |     0.7%

It's clear that `import/no-deprecated` is really slowing things down for little gain.

If you use my simplified configuration, the bulk of the work will be prettier.

## A practical example

I recently migrated our open source projects as well,
so you can check out this [Pull Request](https://github.com/Ninja-Squad/ngx-valdemort/pull/267/files)
for a practical example.
I hope you'll find this useful: this blog post would have saved me a lot of time this week 😅.

RIP TSLint, you served us well.
