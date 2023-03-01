---
layout: post
title: How to migrate an Angular application to standalone components?
author: cexbrayat
tags: ["Angular"]
description: "You have an Angular application that you want to migrate to standalone components? Follow the guide!"
---

Angular&nbsp;14 introduced standalone components and optional modules.
But it can be quite a daunting task to migrate an existing application to this new model!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular">
    <img class="rounded img-fluid" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

This guide supposes that you are familiar with the new standalone components and optional modules introduced in Angular&nbsp;14.
If not, you can read our [dedicated article](/2022/05/12/a-guide-to-standalone-components-in-angular/).

The Angular team has been working on a collection of schematics
to help you migrate your application to standalone components.
These schematics are available in Angular v15.2.0 and above.
So the first step is to update your application to the latest version of Angular.
Then we're good to go!

Let's dive in.

## Schematics to the rescue

The schematics are available in the `@angular/core` package.

To run them, enter:

    ng generate @angular/core:standalone

The schematics expects two arguments:
- the path to the application you want to migrate (by default './')
- the mode of the schematic (by default 'convert-to-standalone')

There are three modes available:
- `convert-to-standalone`: this is the default mode, and it will convert all your components to standalone components, except the ones declared in your main module.
- `prune-ng-modules`: this mode will remove all the modules that aren't necessary anymore.
- `standalone-bootstrap`: this mode will bootstrap your application with the `bootstrapApplication` function,
and migrate the components referenced in your main module.

To fully run a migration, you need to run the schematics in the three modes consecutively.

## Convert to standalone

The first mode will convert all your components to standalone components,
except the ones referenced in the `bootstrap` field of your main module.
It also updates the related unit tests.

As this is the default mode, you can run:

    ng generate @angular/core:standalone --defaults

The schematic is quite smart, as it compiles the template of each component to detect what the standalone version of the component needs to import.

For example, if you have a component that uses the `NgIf`, `RouterLink` and `FormControl` directives, the schematic will add `NgIf`, `RouterLink` (as they are standalone directives) and `ReactiveFormModule` (as `FormControl` is available via this module) to the list of imports of the standalone component (and add the necessary TypeScript imports).
It also works with your own components, pipes and directives,
and the ones from third-party libraries of course.

Be warned though: the schematic can't target a specific component or module,
so it generates a ton of changes in your application.
It also generates some "noise": some files are modified but not really changed,
because the schematic sometimes reformats the code.

To avoid this, I strongly advise you to add a formatter to your project,
for example [Prettier](https://prettier.io/).
If you want to learn how, we have a dedicated article about [how to add ESLint and Prettier to your Angular project](/2021/03/31/migrating-from-tslint-to-eslint/).

This allows you to run `ng lint --fix` after the schematic,
to only focus on the real changes.

All your entities are now standalone components, pipes and directives.
The schematic also updates the modules of your application,
by moving the migrated entities from the `declarations` array,
to the `imports` array.

At the end of this step, you'll have most of your components migrated to standalone components,
but you'll still have your existing modules.
The application should still work if you run `ng serve`, `ng test`, etc.

## Prune the modules

The second mode will remove all the modules that aren't necessary anymore.

To run it, enter:

    ng generate @angular/core:standalone --defaults --mode=prune-ng-modules

The schematic can remove a module only if:
- it doesn't have any `declarations`, `providers` or `bootstrap`
- it doesn't have any code in its constructor, or other methods
- it doesn't have any `imports` that reference a `ModuleWithProviders`

If your module has providers, you can usually move them.

This last one means that modules that import a module with providers
(like `RouterModule.forChild`) can't be removed without a bit of work first.

Typically, if you lazy-loaded modules, you have a module that looks like this:

    @NgModule({
      imports: [RouterModule.forChild(adminRoutes)]
    })
    export class AdminModule { }

With the routes of the module declared like this:

    export const adminRoutes: Routes = [
      { path: '', component: AdminComponent }
    ];

And a main route file that lazy-load the module:

    const routes: Routes = [
      { path: 'admin', loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule) }
    ];

You then need to manually migrate this to lad the routes directly:

    const routes: Routes = [
      { path: 'admin', loadChildren: () => import('./admin/admin.routes').then(m => m.adminRoutes)
    ];

When this is done, you can remove `RouterModule.forChild`from the imports of the admin module,
and manually delete the `AdminModule` if it isn't referenced elsewhere.

Sometimes, your module is referenced somewhere else in your application.
In that case, the call won't be removed by the schematic.
The schematic adds a comment with a TODO

    console.log(/* TODO(standalone-migration): clean up removed NgModule reference manually */ AdminModule);

You can look into your codebase to see where `AdminModule` is referenced and remove it manually.

## Bootstrap the application

The last mode will update your application to use the `bootstrapApplication` function.
It will convert the main module of your application and all its components/pipes/directives to standalone components.
It also converts the imports of other modules to `importProvidersFrom` calls.
When it can, it uses the appropriate `provide...()` function to import the providers:
for example `provideRouter()` for the `RouterModule`, or `provideHttpClient()` for the `HttpClientModule` 😍.

To run it, enter:

    ng generate @angular/core:standalone --defaults --mode=standalone-bootstrap

After this step, your application is fully migrated to standalone components.
You can then do a bit of cleanup in your codebase with `ng lint --fix`
and check that everything is still working.

Your tests will need to be updated though:
the schematics can't analyze them (as tests are not compiled in AoT mode).
The schematics tries to do its best to update them,
and moves the declarations to the imports of the testing module,
but you usually have to do some manual work to make them work again.

## A strategy for large applications

As this can be a daunting task in a large project,
where thousands of tests are affected,
you can try to approach this migration in small steps.

Even if the migration runs on the whole project,
you can then use your version control system to revert the changes on all modules except one.
I usually start with the "shared" module (that almost all projects have),
which usually contains components/pipes/directives that are used in many places
and fairly easy to migrate as they are "leaves" of the application.

Then, I lint the code, commit the changes, run the tests and fix them.

Once this is done, I can move on to the next module, starting with the small ones
and progressively moving to the bigger ones.
One a module is migrated, I migrate its routes configuration,
in order to delete the module.

Rinse and repeat until you're done!
Your application now uses standalone components 🎉.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
