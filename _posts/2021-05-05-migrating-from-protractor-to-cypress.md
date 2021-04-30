---
layout: post
title: Migrating from Protractor to Cypress
author: cexbrayat
tags: ["Angular 12", "Angular"]
description: "A few tips on how to handle the migration from Protractor to Cypress"
---

The Angular team [has announced](https://github.com/angular/protractor/issues/5502)
that the support of Protractor in the Angular CLI will be discontinued
and that the Protractor project itself will be abandoned.

With the upcoming Angular CLI v12 release, this means that
the CLI [now generates](https://github.com/cexbrayat/angular-cli-diff/compare/12.0.0-next.9...12.0.0-rc.0) projects without the `e2e` configuration.

You could add Protractor back to a v12 project using:

    ng generate @schematics/angular:e2e --related-app-name my-app

But all this points to an obvious task for us Angular developers:
we have to migrate to an alternative.

The Angular CLI will not support another e2e solution out-of-the-box in the near future,
but the amazing Angular community does offer a few options.

The biggest question left is: which e2e solution can we pick?

## Cypress

Because there are a _lot_ of options nowadays!
Protractor was written for AngularJS v1, and back in the days, there were very few possible solutions.
Apart from [Selenium](https://www.selenium.dev/documentation/en/),
which was a precursor, and that Protractor uses under the hood.
Protractor is getting old though,
not really fit to test Angular applications,
and is not maintained actively (even if it is still massively used inside Google).

A few popular alternatives are possible:
- [Cypress](https://www.cypress.io/)
- [Playwright](https://playwright.dev/)
- [Puppeteer](https://pptr.dev/)

I revealed our choice in the title: at Ninja Squad, we use Cypress for most (all?) of our projects.
We do use Playwright sometimes for automation and the API is very nice
(and is available in [multiple languages](https://playwright.dev/docs/languages)).

But Cypress offers a fairly unbeatable developer experience
with its UI allowing to see a snapshot of the application for each step of a test.
It also comes with a wide ecosystem and a very active community.

## Migrating an Angular project

We're going to use a schematic to ease the migration:

    ng add @briebug/cypress-schematic --remove-protractor

This command:
- adds `cypress` to the dependencies of your application,
- removes `protractor` as a dependency
- removes the `e2e` directory
- adds a `cypress` directory with a dummy test
- adds a `cypress.json` config file
- updates the `angular.json` file.

Note that you can also manually remove `ts-node` and `jasmine-spec-reporter`
as they are only used by Protractor in the CLI.

I also add the cypress files to the lint task.

You can then run the tests with the usual:

    ng e2e

Note that the tests run by default with a UI and in watch mode.
You can tweak the `angular.json` file if that's not to your taste,
or add the options manually (for example on CI):

    ng e2e --headless --no-watch

## A few cool tricks

On some of our projects, we use [Percy](https://percy.io)
to add visual diff testing.
Percy offers an integration with Cypress.
You just need to add some dependencies:

    npm install --save-dev --save-exact @percy/cypress @percy/cli

Then add `import '@percy/cypress';` to your `command.ts` file.

You can now use:

    cy.percySnapshot('name-of-the-snapshot')

in your tests.
This will take a snapshot with the specified name,
upload it to the Percy platform,
and compare it, pixel by pixel, with a reference (the first build you approve).

This is super easy to set up,
and can run on CI once in a while to make sure you don't have regressions.

Another cool extension is [`cypress-axe`](https://github.com/component-driven/cypress-axe).
[Axe](https://github.com/dequelabs/axe-core) is an accessibility test tool
and catches accessibility issues in your applications.
You can also use Axe with a browser extension,
but using it in automated tests is a better way to prevent regressions.

`cypress-axe` allows you to add accessibility checks in your e2e test suite.

    npm i --save-exact --save-dev cypress-axe

Then in your tests you need to inject `axe` at the beginning of the test:

    beforeEach(() => cy.injectAxe());

and check if there is no accessibility issue whenever needed:

    cy.checkA11y();

This helped us catch quite a few issues on the projects we used it.

I hope all this will help you migrate to Cypress!
