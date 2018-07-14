---
layout: post
title: What's new in Angular 6.1?
author: cexbrayat
tags: ["Angular 6", "Angular 5", "Angular", "Angular 2", "Angular 4"]
description: "Angular 6.1 is out! Read about the new keyvalue pipe, the new features of the router and more!"
---

Angular&nbsp;6.1.0 is here!

<p style="text-align: center;">
  <a href="https://github.com/angular/angular/blob/master/CHANGELOG.md#TODO">
    <img class="img-rounded img-responsive" style="max-width: 100%" src="/assets/images/angular.png" alt="Angular logo" />
  </a>
</p>

## keyvalue pipe

Angular&nbsp;6.1 introduced a new pipe!
It allows to iterate over a Map or an object,
and to display the keys/values in our templates.

Note that it orders the keys:

- first lexicographically if they are both strings
- then by their values if they are both numbers
- then by their boolean values if they are both booleans (`false` before `true`).

And if the keys have different types,
they will be cast to strings and then compared.

    {% raw %}
    @Component({
      selector: 'ns-ponies',
      template: `
        <ul>
          <!-- entry contains { key: number, value: PonyModel } -->
          <li *ngFor="let entry of ponies | keyvalue">
            {{ entry.key }} - {{ entry.value.name }}
          </li>
        </ul>`
    })
    export class PoniesComponent {
      ponies = new Map<number, PonyModel>();

      constructor() {
        this.ponies.set(103, { name: 'Rainbow Dash' });
        this.ponies.set(56, { name: 'Pinkie Pie' });
      }
    }
    {% endraw %}

If you have `null` or `undefined` keys,
they will be displayed at the end.

It's also possible to define your own comparator function:

    {% raw %}
    @Component({
      selector: 'ns-ponies',
      template: `
        <ul>
          <!-- entry contains { key: PonyModel, value: number } -->
          <li *ngFor="let entry of poniesWithScore | keyvalue:ponyComparator">
            {{ entry.key.name }} - {{ entry.value }}
          </li>
        </ul>`
    })
    export class PoniesComponent {

      poniesWithScore = new Map<PonyModel, number>();

      constructor() {
        this.poniesWithScore.set({ name: 'Rainbow Dash' }, 430);
        this.poniesWithScore.set({ name: 'Pinkie Pie' }, 125);
      }

      /*
       * Defines a custom comparator to order the elements by the name of the PonyModel (the key)
       */
      ponyComparator(a: KeyValue<PonyModel, number>, b: KeyValue<PonyModel, number>) {
        if (a.key.name === b.key.name) {
          return 0;
        }
        return a.key.name < b.key.name ? -1 : 1;
      }
    }
    {% endraw %}

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
