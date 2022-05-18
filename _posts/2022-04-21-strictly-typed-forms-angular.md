---
layout: post
title: Strictly typed forms in Angular
author: cexbrayat
tags: ["Angular 14", "Angular"]
description: "Angular 14 finally has strictly typed forms!"
---

We finally have them! 
6 years after the first release, and after months of 
[discussion and feedback](https://github.com/angular/angular/discussions/44513),
the [most up-voted issue](https://github.com/angular/angular/issues/13721)
in the Angular repository is now solved in Angular v14.

We now have forms correctly typed in Angular 🚀.

`FormControl` now takes a generic type
indicating the type of the value it holds.
To make sure that nothing breaks in existing applications,
the Angular team released an automatic migration
in Angular v14.

_Disclaimer:_ this blog post is based on early releases of Angular v14,
and some details may change based on the feedback the Angular team gets.
That's why, for once, we write a blog post on a feature before its final release:
this is a great opportunity to give it a try and gather feedback!

## Migration to the untyped version

When updating to Angular v14, a migration will automatically replace
all the form entities in your application by their untyped versions:

- `FormControl` → `UntypedFormControl` (which is an alias for `FormControl<any>`)
- `FormGroup` → `UntypedFormGroup` (which is an alias for `FormGroup<any>`)
- `FormArray` → `UntypedFormArray` (which is an alias for `FormArray<any>`)
- `FormBuilder` → `UntypedFormBuilder` (which is an alias for `FormBuilder<any>`)

This migration will run when launching:

    ng update @angular/core

Or on demand, if you already manually updated your application:

    ng update @angular/core --migrate-only=migration-v14-typed-forms

At the end of the migration, all imports and instances are replaced
by their untyped versions.
And that can be a lot of files in large applications
(we had a few hundreds of files updated in some of our applications).

The cool thing is that now the application should work exactly as before.

## Migration to the typed forms API, step by step

The next step is to use the typed version of the API.
How do you do that?

Let's take an example, a simple register form, and go through it step by step.

    export class RegisterComponent {
      registerForm: FormGroup;

      constructor() {
        this.registerForm = new FormGroup({
          login: new FormControl(null, Validators.required),
          passwordGroup: new FormGroup({
            password: new FormControl('', Validators.required),
            confirm: new FormControl('', Validators.required)
          }),
          rememberMe: new FormControl(false, Validators.required)
        });
      }
    }

We have a login field, a subgroup, with a password field and a password confirmation field,
and a "remember me" field.

When using the automated migration, you end up with:


    export class RegisterComponent {
      registerForm: UntypedFormGroup;

      constructor() {
        this.registerForm = new UntypedFormGroup({
          login: new UntypedFormControl(null, Validators.required),
          passwordGroup: new UntypedFormGroup({
            password: new UntypedFormControl('', Validators.required),
            confirm: new UntypedFormControl('', Validators.required)
          }),
          rememberMe: new UntypedFormControl(false, Validators.required)
        });
      }
    }

Our work is to remove all the `Untyped*` usage,
and properly type the form.
Let's start with the code in the constructor as this is the most straightforward.

Each `UntypedFormControl` must be converted to `FormControl<T>`,
with `T` the type of the value of the form control.
Most of the time, TypeScript can infer this information based on the initial value
given to the `FormControl`.

For example, `passwordGroup` can be converted easily:

    passwordGroup: new FormGroup({
      password: new FormControl('', Validators.required), // inferred as `FormControl<string | null>`
      confirm: new FormControl('', Validators.required) // inferred as `FormControl<string | null>`
    }),

Note that the inferred type is `string | null` and not `string`.
This is because calling `.reset()` on a control without specifying a reset value,
resets the value to `null`.
This behavior is here since the beginning of Angular, so the inferred type reflects it.
We'll come back to this possibly `null` value, in a dedicated section,
as it can be annoying (but can be worked around).

Sometimes though, TypeScript can't infer the type of the control based on the initial value.
For example, our `login` field is initialized with `null`,
so TypeScript can't know what type is intended here.
You can of course explicitly add it:

    login: new FormControl<string | null>(null, Validators.required),

Due to a [subtle TypeScript bug](https://github.com/microsoft/TypeScript/issues/48033),
you also have to help TS figure out that `false` is a boolean:

    rememberMe: new FormControl<boolean | null>(false, Validators.required)

This will probably be fixed in the future, and the type inference will hopefully be enough.

Now let's take the field `registerForm`. 
Unlike `FormControl`, the generic type expected by `FormGroup`
is not the type of its value, but a description of its structure, in terms of form controls:

    registerForm: FormGroup<{
      login: FormControl<string | null>;
      passwordGroup: FormGroup<{
        password: FormControl<string | null>;
        confirm: FormControl<string | null>;
      }>;
      rememberMe: FormControl<boolean | null>;
    }>;

    constructor() {
      this.registerForm = new FormGroup({
        login: new FormControl<string | null>(null, Validators.required),
        passwordGroup: new FormGroup({
          password: new FormControl('', Validators.required),
          confirm: new FormControl('', Validators.required)
        }),
        rememberMe: new FormControl<boolean | null>(false, Validators.required)
      });
    }

This is a bit verbose, but it works \o/.
It is possible to let TypeScript infer the type of `registerForm` if,
instead of initializing the field in the constructor like we usually do,
we initialize it directly when we declare it:

    registerForm = new FormGroup({
      login: new FormControl<string | null>(null, Validators.required),
      passwordGroup: new FormGroup({
        password: new FormControl('', Validators.required),
        confirm: new FormControl('', Validators.required)
      }),
      rememberMe: new FormControl<boolean | null>(false, Validators.required)
    });

In this example, TypeScript properly infers the type of the form group,
without a lot of work on our part.

This is also possible if you use the `FormBuilder`.

    registerForm = this.fb.group({
      login: [null as string | null, Validators.required],
      passwordGroup: {
        password: ['', Validators.required],
        confirm: ['', Validators.required]
      },
      rememberMe: [false, Validators.required]
    });

    constructor(private fb: FormBuilder) {}

## Nullability

As explained above, the types of the controls are `string | null` and `boolean | null`,
and not `string` and `boolean` like we could expect,
because calling `.reset()` on a field resets its value to null.
Except if you give a value to reset, for example `.reset('')`,
but as TypeScript doesn't know _if_  and _how_ you are going to call `.reset()`,
the inferred type is nullable.

You can tweak this behavior if you use the new option introduced in Angular v13.2: `initialValueIsDefault` (see [our blog post](/2022/01/27/what-is-new-angular-13.2) for more details).
With this option, you get rid of the null value if you want to!
On one hand, this is very handy if your application uses `strictNullChecks`.
But on the other hand, this is quite verbose, as you currently have to set this option
_on every field_ (this might change in the future):

    registerForm = new FormGroup({
      login: new FormControl<string>('', { validators: Validators.required, initialValueIsDefault: true }),
      passwordGroup: new FormGroup({
        password: new FormControl('', { validators: Validators.required, initialValueIsDefault: true }),
        confirm: new FormControl('', { validators: Validators.required, initialValueIsDefault: true })
      }),
      rememberMe: new FormControl<boolean>(false, { validators: Validators.required, initialValueIsDefault: true })
    }); // incredibly verbose version, that yields non-nullable types

Or you can use `NonNullableFormBuilder`.

## NonNullableFormBuilder

Angular v14 introduces a new property on `FormBuilder`, called `nonNullable`,
that returns a `NonNullableFormBuilder`.
This new builder offers the usual `control`, `group` and `array` methods
to build non-nullable controls:

    registerForm = this.fb.nonNullable.group({
      login: ['', Validators.required]
    });
    // `registerForm.value` type is `{ login?: string }`

    constructor(private fb: FormBuilder) {}

As using `fb.nonNullable` every time is a bit verbose,
you can directly inject `NonNullableFormBuilder` instead of `FormBuilder`:

    registerForm = this.fb.group({
      login: ['', Validators.required]
    });
    
    constructor(private fb: NonNullableFormBuilder) {}


## What do we gain?

### value and valueChanges

Is this migration trouble worth it?
In my opinion, definitely.
The original forms API is not playing very well with TypeScript.
For example, the `value` of a control or group is typed as `any`.
So we could write `this.registerForm.value.whatever`
and the application would happily compile.
This can be a very painful issue when refactoring an application:
TypeScript would warn you about every mistake in TS and HTML files...
except in forms!

This is no longer the case:
the new forms API properly types `value` according to the types of the form controls.
In my example above (with `initialValueIsDefault`), the type of `this.registerForm.value` is:

    {
      login?: string;
      passwordGroup?: {
        password?: string;
        confirm?: string;
      };
      rememberMe?: boolean;
    } // this.registerForm.value

You can spot some `?` in the type of the form value.
What does it mean?

In Angular, you can disable any part of a form.
When you disable a field, its value is removed from the form value:

    this.registerForm.get('passwordGroup').disable();
    console.log(this.registerForm.value); // logs '{ login: null, rememberMe: false }'

This is a bit strange, but it explains why the fields are all marked as optional:
if they have been disabled, they are not present in the object returned by `this.registerForm.value`.
This is what TypeScript calls a `Partial` value.

If you want the complete object, with all its keys, even the disabled ones,
you can use `this.registerForm.getRawValue()`:

    {
      login: string;
      passwordGroup: {
        password: string;
        confirm: string;
      };
      rememberMe: boolean;
    } // this.registerForm.getRawValue()

`this.registerForm.value` is probably more accurate, but it forces developers to add potentially `undefined`
when you _know_ the value is present because the field is never disabled.
For example, imagine that this value is used as parameters for calling the method of a service:

    export class UserService {
      register(login: string, password: string): Observable<void> {
        // ...
      }
    }

then when calling this method in our component above, we have an error:

    const value = this.registerForm.value;
    this.userService.register(value.login, value.passwordGroup.password).subscribe();    
    // does not compile as the `login` and `password` parameters must be strings
    // and `value.login`, `value.passwordGroup`, `value.passwordGroup.password`
    // can all theoretically be undefined  

As the values can be undefined, and the `register` method expects strings,
and not potentially undefined values, TypeScript is not happy.

We can handle this case by checking if the values exist
(which also lets TypeScript know that they are not undefined):

    const value = this.registerForm.value;
    if (value.login && value.passwordGroup && value.passwordGroup.password) {
      // TypeScript narrows the types to `string` inside the `if` block
      this.userService.register(value.login, value.passwordGroup.password).subscribe();
    }

But this is sometimes a bit annoying, as we know these values are present:
we never disabled these fields!

In that case, you can use the lazy, but always efficient, "non-null assertion" operator `!`:

    const value = this.registerForm.value;
    this.userService.register(value.login!, value.passwordGroup!.password!).subscribe();
    // not pretty, but gets the job done

`valueChanges` is of course properly typed as well:
instead of getting an `Observable<any>` as we used to,
you now get `Observable<string | null>` for `this.registerForm.get('login')`.

`setValue` and `patchValue` are also type-safe:
you can't set a number on a `FormControl<string>` for example. 

### get()

The `get(key)` method is also more strictly typed.
This is great news, as you could previously call it with a key that did not exist,
and the compiler would not see the issue.

Thanks to some hardcore TypeScript magic, the key is now checked and the returned control
is properly typed!

    this.registerForm.get('login') // AbstractControl<string> | null
    this.registerForm.get('passwordGroup.password') // AbstractControl<string> | null 😲


It also works with the array syntax for the key, if you add `as const`:
    
    this.registerForm.get(['passwordGroup', '.password'] as const) // AbstractControl<string> | null
    
And it even works with nested form arrays and groups! 
For example, if our form has a `hobbies` FormArray, containing a FormGroup:

    this.registerForm.get('hobbies.0.name') // AbstractControl<string> | null 🤯

If you use a key that does not exist in your form, you get an error:

    this.registerForm.get('logon' /* typo */)!.setValue('cedric'); // does not compile 🚀

As you can see, `get()` returns a potentially `null` value:
this is because you have no guarantee that the control exists at runtime,
so you have to check its existence or use `!` like above.

Note that the keys you use in your templates for `formControlName`, `formGroupName`, and `formArrayName` aren't checked, so you can still have undetected issues in your templates.

## A newcomer: FormRecord

`FormRecord` is a new form entity that has been added to the API.
A `FormRecord` is similar to a `FormGroup` but the controls must all be of the same type.
This can help if you use a `FormGroup` as a map,
to which you add and remove controls dynamically.
In that case, properly typing the `FormGroup` is not really easy,
and that's where `FormRecord` can help.

It can be handy when you want to represent a list of checkboxes for example,
where your user can add or remove options.
For example, our users can add and remove the language they understand (or don't understand) when they register:

    languages: new FormRecord({
      english: new FormControl(true, { initialValueIsDefault: true }),
      french: new FormControl(false, { initialValueIsDefault: true })
    });

    // later 
    this.registerForm.get('languages').addControl('spanish', new FormControl(false, { initialValueIsDefault: true }));

If you try to add a control of a different type, TS throws a compilation error:

    this.registerForm.get('languages').addControl('spanish', new FormControl(0, { initialValueIsDefault: true })); // does not compile

But as the keys can be any string, there is no type-checking on the key in `removeControl(key)` or `setControl(key)`.
Whereas if you use a `FormGroup`, with well-defined keys, you _do_ have type checking
on these methods: `setControl` only allows a known key, 
and `removeControl` only allows a key marked as optional (with a `?` in its type definition).

TL;DR: If you have a `FormGroup` on which you want to add and remove control dynamically,
you're probably looking for the new `FormRecord` type.

## Conclusion

We're very excited to see this new forms API landing in Angular!
This is, by far, one of the biggest changes in recent years for developers.
Ivy was big but didn't need us to make a lot of changes in our applications.
Typed forms are another story: the migration is likely to impact dozens,
hundreds, or thousands of files in your applications!
In our applications, for the forms we migrated to the typed version,
most of the work was very straightforward and repetitive.
And we even caught some hidden bugs in our code!
The TypeScript support in Angular has always been outstanding, 
but had a major blind spot with forms: this is no longer the case!

Big thanks to [Dylan Hunn](https://twitter.com/dylhunn) who has been in charge of this work,
and who very patiently listened to our very early feedback!

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
