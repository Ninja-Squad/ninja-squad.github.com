---
layout: post
title: Ninja Tips 3 - [hidden] et Bootstrap's help-block
author: clacote
tags: ["Angular 2", "Angular", "bootstrap", "html", "css"]
description: "Une astuce sur la validation de formulaires avec Angular 2 et Bootstrap"
---

Comme tout le monde, vous développez des applications de gestion
(ça se saurait si on pouvait gagner sa vie en développant des jeux vidéo).
Et comme vous n'êtes pas très fort en *front design*, vous bénissez les framework CSS
comme [Bootstrap](http://getbootstrap.com/), qui vous permettent de capitaliser
plein de bonnes pratiques qui vous dépassent,
et d'avoir un rendu plutôt joli sans trop réfléchir.
Ça donne un rendu certes pas très original (*Bootstrap est le nouveau moche* disent certains),
mais ça contribue grandement à votre productivité.
Ne culpabilisez pas, j'en suis là aussi (on doit être de la même génération de vieux).

Vous voilà donc à devoir coder votre formulaire de login en Angular&nbsp;2 et Bootstrap.
Le template HTML, s'il utilise un formulaire Angular&nbsp;2 piloté par le
modèle plutôt que piloté par le template, pourrait ressembler à cela&nbsp;:

    <form (ngSubmit)="login()" [ngFormModel]="loginForm">

      <div class="form-group">
        <label for="username">Login</label>
        <input id="username" type="text"
               class="form-control" ngControl="username" required>
      </div>

      <div class="form-group">
        <label for="password">Mot de passe</label>
        <input id="password" type="password"
               class="form-control" ngControl="password" required>
      </div>

      <button type="submit" class="btn btn-primary">
        Me connecter
      </button>
    </form>

Bravo, vous n'avez pas oublié l'attribut `required` sur les deux éléments `<input>`,
car ces deux champs sont bien obligatoires. Les navigateurs modernes devraient
même empêcher de soumettre le formulaire si ces deux champs ne sont pas saisis.
Mais un peu de feedback utilisateur ne ferait pas de mal pour l'ergonomie.

Alors vous voulez ajouter un petit texte d'aide, pour préciser que ces champs sont obligatoires.
Bootstrap [propose une classe `.help-block`](http://getbootstrap.com/css/#forms-help-text),
dont c'est justement le propos&nbsp;:

    <div class="form-group">
      <label for="password">Mot de passe</label>
      <input id="password" type="password"
             class="form-control" ngControl="password" required>
      <span class="help-block">
        Le mot de passe est obligatoire
      </span>
    </div>

Mais dès que ce formulaire est affiché, ces messages sauteront aux yeux de l'utilisateur,
alors qu'il n'a encore rien saisi. Chez Ninja Squad on aime bien que les messages
ne s'affichent qu'une fois que l'utilisateur a commencé à saisir.
Vous pouvez alors tirer bénéfice des possibilités surnaturelles de validation offertes par un
formulaire Angular&nbsp;2&nbsp;:

    <div class="form-group"
         [ngClass]="{
            'has-error': password.dirty
                         && !password.valid }">
      <label for="password">Mot de passe</label>
      <input id="password" type="password"
             class="form-control" ngControl="password">
      <span class="help-block"
            [hidden]="password.pristine
                      || !password.hasError('required')">
        Le mot de passe est obligatoire
      </span>
    </div>

    <button type="submit" class="btn btn-primary" [disabled]="!loginForm.valid">
      Me connecter
    </button>

Qu'avons-nous mis en œuvre ici&nbsp;?

* On applique grâce à la directive `ngClass` la classe Bootstrap `.has-error` sur la `div.form-group` si le champ `password`&nbsp;:
  1. est `dirty`, c'est à dire modifié par l'utilisateur&nbsp;;
  2. a une erreur de validation.
* On n'active le bouton de soumission que si le formulaire est valide, grâce à la propriété `disabled` du DOM.
* On masque le `span.help-block` grâce à l'attribut HTML&nbsp;5 global `hidden`, si&nbsp;:
   1. le champ est `pristine`, c'est à dire vierge de toute modification par l'utilisateur (l'état lors de l'affichage initial)&nbsp;;
   2. ou si le champ n'a aucune erreur `'required'` de validation.

Plutôt cool. Sauf que... ça ne marche pas complètement.
En l'état, le `span.help-block` sera toujours affiché, même quand le champ est vierge, même quand il n'a pas d'erreur.

Ce n'est pas une erreur dans la condition. Ce n'est pas un bug de votre navigateur qui ne supporterait pas cet attribut HTML&nbsp;5. Ce n'est pas non plus un bug de _binding_ d'Angular&nbsp;2 sur cet attribut HTML&nbsp;5.
Ce problème m'a coûté quelques bonnes minutes de sueurs froides. Ce pourquoi je voulais vous partager ce *ninja tip*, aussi anecdotique soit-il.

En fait, le problème se situe dans le comportement de l'attribut HTML&nbsp;5 global `hidden`, et les styles apportés par la classe Bootstrap `.help-block`. La [documentation de `hidden`](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/hidden) explique&nbsp;:

> changing the value of the CSS `display` property on an element
> with the `hidden` attribute overrides the behavior.

Ce qui signifie pour les auvergnats&nbsp;:

> modifier la valeur de la propriété CSS `display` sur un élement
> avec l'attribut `hidden` surcharge son comportement.

Et en l'occurrence, la classe `help-block` apporte entre autre le style
`display: block;` ([source](https://github.com/twbs/bootstrap/blob/v3.3.6/less/forms.less#L456))...

Voilà pourquoi votre texte d'aide à l'utilisateur apparaît toujours alors que votre utilisation de la validation Angular&nbsp;2 est parfaite.

OK, cool. Et maintenant on fait quoi&nbsp;?
Et bien soit on enlève la classe `help-block` (mais on perd le style apporté), soit on réécrit son template pour ne plus faire du binding sur l'attribut `hidden`. Et la directive `ngIf` arrive alors à la rescousse&nbsp;:

    <span class="help-block"
          *ngIf="password.dirty
                 && password.hasError('required')">
      Password is required
    </span>

Et voilà&nbsp;!
Il nous a fallu inverser la condition initialement placée dans `[hidden]="..."` (mais c'est de l'algèbre de Boole niveau CP), et on a remplacé le test de `pristine` par un test de `dirty`, qui sont les opposés.


<a id="update" />
**Mise à jour du 12/05/2016&nbsp;: solution alternative.**

> Thomas Queste [nous suggère dans les commentaires](/2016/03/22/ninja-tips-3-angular-validation-hidden-vs-bootstrap-help-block-english/#comment-2671575902) de la version anglaise de cet article
> une [autre solution vue sur StackOverflow](http://stackoverflow.com/questions/30744882/angular2-hidden-ignores/30746262#30746262)&nbsp;:
> placer le message d'erreur dans son propre `span` à l'intérieur du `span.help-block`.

Merci d'avoir suivi ce long cheminement pour me permettre de vous expliquer cette anecdote, je me sens mieux d'avoir pu vider mon sac. Vous pouvez reprendre une activité normale (comme la lecture de [notre ebook sur Angular&nbsp;2](https://books.ninja-squad.com/angular2) par exemple).
