---
layout: post
title: Announcing ngx-speculoos &ndash; simpler, cleaner Angular unit tests
author: jbnizet
tags: ["Angular", "ngx-speculoos", "test", "jasmine"]
description: "Announcing ngx-speculoos: a free, small library to write simpler, cleaner Angular unit tests"
---

<div style="float: right;"><img src="/assets/images/ngx-speculoos.svg" alt="ngx-speculoos logo" style="width: 250px;"/></div>

Writing Angular unit tests for components quickly leads to quite a lot of boilerplate, and if you're not careful, code duplication and not type-safe code, too. 
Especially when dealing with forms. 

Out of the frustration from this non-ideal code, we decided to write a small library to help with these issues, and to rely on the page object pattern when it makes sense.

Let me thus introduce [ngx-speculoos](https://ngx-speculoos.ninja-squad.com). 

It's free, as in beer, and as in speach. 

It uses the standard Angular TestBed and ComponentFixture abstractions, so you should get up to speed in a few minutes. 

So, if you're like us, and would like your tests to be cleaner, more readable, and easier to maintain, please give it a try and tell us what you think about it.

Since a code snippet is worth a thousand words, here's how you would test that selecting a country in a select box makes an error message disappear, and another cities select box appear, containing expected option values, labels and selection. Note the absence of calls to `detectChanges` or `dispatchEvent`. Note the non-duplication of CSS selectors thanks to the page object pattern.

```
    expect(tester.countryErrors).toContainText('The country is mandatory');
    expect(tester.city).toBeNull();

    tester.country.selectValue('FR');

    expect(tester.countryErrors).toBeNull();
    expect(tester.city.optionValues).toEqual(['PARIS', 'LYON']);
    expect(tester.city.optionLabels).toEqual(['Paris', 'Lyon']);
    expect(tester.city).toHaveSelectedLabel('Paris');
```

For more information, see our [README and API documentation](https://ngx-speculoos.ninja-squad.com/documentation/index.html).

[The project is on Github](https://github.com/Ninja-Squad/ngx-speculoos), so don't hesitate to star the project if you like it, and to request features, improvements or bug fixes, or even to contribute.

## What's that name?

<div style="float: left;"><img src="/assets/images/speculoos.jpg" alt="speculoos cookies" /></div>

Well, `ngx` stands for *Angular extension*.

Oh, you meant the *other* part of the name?

A *speculoos* is a delicious cookie from Belgium, where one quarter of the Ninja Squad staff (i.e. me) comes from. 

And *speculoos* starts with `spec`, which is how test files are usually named in an Angular project. 
That sounded like a cool name for this library.
