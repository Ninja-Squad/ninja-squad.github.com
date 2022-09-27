---
layout: post
title: Directive Composition API in Angular
author: cexbrayat
tags: ["Angular 15", "Angular"]
description: "Angular 15 introduces an API to compose directives!"
---

Angular&nbsp;15.0 introduces a new API to easily compose directives.
This feature has been pushed by
[Kristiyan Kostadinov](https://github.com/crisbeto) who shares its time between the Material and Framework teams. 
It solves a pain that is particularly felt by the Angular Material team.

## The problem

One of the most powerful mechanics of Angular is its directive system: you can apply a directive to an element to give it a special behavior.

For example, Material provides a `MatTooltip` directive that you can apply to an element to display a tooltip:

{% raw %}
    <button matTooltip="Info" [matTooltipHideDelay]="delay">Click me</button>
{% endraw %}

or a `CdkDrag` directive to make an element draggable:

{% raw %}
    <div cdkDrag [cdkDragDisabled]="isDisabled">Drag me!</div>
{% endraw %}

Let's say that you built a nice button directive `appButton` (or a component),
that probably does something amazing, and you always want to apply the `MatTooltip` and `CdkDrag` directives at the same time.

You also want to let the user of your directive decide if the button is draggable or not, and what the text and delay of the tooltip should be. But you don't want your users to have to write:

{% raw %}
    <button appButton
      matTooltip="Info"
      [matTooltipHideDelay]="delay"
      cdkDrag
      [cdkDragDisabled]="isDisabled">
        Click me
    </button>
{% endraw %}

Here it is a burden on the developers to remember to add `matTooltip` and `cdkDrag` every time and to configure them properly.

Ideally, you'd want:

{% raw %}
    <button appButton
      tooltip="Info"
      [tooltipHideDelay]="delay"
      [dragDisabled]="isDisabled">
        Click me
    </button>
{% endraw %}

When you want to compose behaviors like this,
you can currently use inheritance (but you can only inherit from one directive) or mixins (with a pattern I've only seen in [Angular Material](https://github.com/angular/components/blob/03408fdb83680cbb69f5d547437e520910a905a3/src/material/tree/node.ts#L29)).

In v15, the Angular team introduces a new API to compose directives, called the Directive Composition API.
A new property is available in the `@Directive` (or `@Component`) decorator: `hostDirectives`.
It accepts an array of _standalone_ directives, and will apply them on the host component.

Note: my following example is not working yet at the time of writing, as the Angular Material directives aren't available as standalone directives. But they will probably be soon.

    @Directive({
      selector: 'button[appButton]',
      hostDirectives: [
        { 
          directive: MatTooltip, 
          inputs: ['matTooltip', 'matTooltipHideDelay']
        },
        {
          directive: CdkDrag,
          inputs: ['cdkDragDisabled']
        }
      ]
    })
    export class ButtonComponent {
    }

You can specify which inputs should be exposed (by default, none are). They are exposed with the same name, but you can rename them:

    @Directive({
      selector: 'button[appButton]',
      hostDirectives: [
        { 
          directive: MatTooltip, 
          inputs: [
            'matTooltip: tooltip',
            'matTooltipHideDelay: tooltipHideDelay'
          ]
        },
        {
          directive: CdkDrag,
          inputs: ['cdkDragDisabled: dragDisabled']
        }
      ]
    })
    export class ButtonDirective {
    }

And then use your directive like this 🎉:

{% raw %}
    <button appButton
      tooltip="Info"
      [tooltipHideDelay]="delay"
      [dragDisabled]="isDisabled">
    </button>
{% endraw %}

You can of course do the same with the outputs.
The type-checking will properly work,
host bindings will be applied,
DI will work (you can even inject the host directives into your directive/component), etc.
You can override lifecycle hooks if you want to.

The host directives are picked by view/content queries as well,
so this works:

    // picks our ButtonDirective 🤯
    @ViewChild(CdkDrag) drag!: CdkDrag;

If you want to dive deeper into this topic,
check out this [talk from Kristiyan](https://www.youtube.com/watch?v=oC9Qd9yw3pE).

Currently, the biggest limitation is that you can only apply standalone directives.

All our materials ([ebook](https://books.ninja-squad.com/angular), [online training](https://angular-exercises.ninja-squad.com/) and [training](https://ninja-squad.com/training/angular)) are up-to-date with these changes if you want to learn more!
