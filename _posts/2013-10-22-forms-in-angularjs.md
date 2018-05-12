---
layout: post
title: Forms in AngularJS
author: cexbrayat
tags: ["AngularJS"]
canonical: http://hypedrivendev.wordpress.com/2013/10/22/forms-in-angular
---

Nous continuons notre série d'articles sur AngularJS, sur lequel nous vous proposons [une formation](https://ninja-squad.fr/formations/formation-angularjs). Aujourd'hui&nbsp;: la validation de formulaires.

Si vous lisez ceci, vous savez probablement créer un formulaire en HTML. Toute application web en contient son lot. Un formulaire contient un ensemble de champs, chaque champ étant une manière pour l'utilisateur de saisir des informations. Ces champs groupés ensemble dans un formulaire ont un sens, que ce soit une page d'enregistrement pour vos utilisateurs, ou une formulaire de login.

Les formulaires en Angular étendent les formulaires HTML en leur ajoutant un certain nombre d'états et en donnant aux développeurs de nouvelles façon d'agir.

Les formulaires, comme beaucoup de composants en Angular, sont des directives. Chaque fois que vous utilisez un formulaire en Angular, la directive `form` va instancier un controller nommé `FormController`. Il est possible d'accéder au controller dans votre code en utilisant comme nom l'attribut `name` de votre formulaire.

Ce controller expose un ensemble de méthode et de propriétés :
- `$pristine` : permet de savoir si l'utilisateur a déjà touché au formulaire. On pourrait traduire en français par vierge. Ce booléen sera donc vrai tant qu'il n'y aura pas eu d'interaction, puis faux ensuite.
- `$dirty` : à l'inverse de `$pristine`, `$dirty` sera vrai si l'utilisateur a commencé à interagir avec le formulaire. Pour résumer : $dirty == !$pristine.
- `$valid` : sera vrai si l'ensemble des champs (et éventuellement des formulaires imbriqués) sont valides.
- `$invalid` : sera vrai si au moins un champ (ou formulaire imbriqué) est invalide.
- `$error` : représente un dictionnaire des erreurs, avec comme clé le nom de l'erreur, par exemple `required`, et comme valeur la liste des champs avec cette erreur, par exemple login et password.

Ces états sont disponibles sur le formulaire global mais également sur chaque champ du formulaire. Si votre formulaire se nomme `loginForm`, et contient un champ `password` alors vous pouvez voir si ce champ est valide grâce au code suivant :

    loginForm.password.$valid

Vous vous voyez déjà ajouter du code JS pour surveiller ces états et changer le CSS en cas d'erreur. Pas besoin! Angular ajoute ces états comme classe CSS directement sur chaque champ et le formulaire. Ainsi lorsque le formulaire encore vierge s'affiche, il contient déjà la classe CSS `ng-pristine` :

    <form name='loginForm' class='ng-pristine'>
      <input name='login' ng-model='user.login' class='ng-pristine'/>
      <input name='password' ng-model='user.password' class='ng-pristine'/>
    </form>

Dès la saisie du premier caractère dans le champ `input`, le formulaire devient dirty :

    <form name='loginForm' class='ng-dirty'>
      <input name='login' ng-model='user.login' class='ng-dirty'/>
      <input name='password' ng-model='user.password' class='ng-pristine'/>
    </form>

A noter que le formulaire, ainsi que l'input, reste dirty une fois modifié, même si la modification est annulée.

Si l'un des champs présente une contrainte (comme par exemple `required` ou `url`), alors le formulaire sera invalide tant que cette contrainte ne sera pas satisfaite. Le champ comme le formulaire aura donc la classe `ng-invalid` ainsi que le champ en question. Une fois la condition satisfaite, la classe `ng-valid` remplace la classe `ng-invalid`.

Vous pouvez donc très facilement customiser votre CSS pour ajouter un style selon l'état de votre formulaire. Cela peut être un bord rouge en cas de champ invalide :

    input.ng-dirty.ng-invalid {
      border: 1px solid red;
    }

Ou encore afficher un message d'erreur dans votre HTML :

    <form name='loginForm'>
      <input name='login' type='email' ng-model='user.login'/>
      <span ng-show='loginForm.login.$invalid'>Your login should be a valid email</span>
      <input name='password' ng-model='user.password'/>
    </form>

Ajouter un type `email` sur un champ place une contrainte sur celui-ci, obligeant l'utilisateur à entrer un login sous la forme d'une adresse email valide. Dès que l'utilisateur commencera sa saisie de login, le champ deviendra invalide, rendant l'expression `loginForm.login.$invalid` vraie. La directive `ng-show` activera alors l'affichage du message d'avertissement. Dès que le login saisi sera un email valide, l'expression deviendra fausse et l'avertissement sera caché. Plutôt pas mal pour une ligne de HTML non?

Vous pouvez bien sûr cumuler les conditions d'affichage de l'avertissement, ou faire un avertissement par type d'erreur :

    <form name='loginForm'>
      <input name='login' required type='email' ng-model='user.login'/>
      <span ng-show='loginForm.login.$dirty && loginForm.login.$error.required'>A login is required</span>
      <span ng-show='loginForm.login.$error.email'>Your login should be a valid email</span>
      <input name='password' ng-model='user.password'/>
    </form>

Ainsi si l'utilisateur, après avoir entré un login (rendant ainsi le champ "dirty"), l'efface, un message d'avertissement apparaîtra pour indiquer que le login est nécessaire. Les combinaisons ne sont limitées que par votre imagination!

Plusieurs méthodes sont disponibles sur le controller :
- `addControl()`, `removeControl()` permettent d'ajouter ou de supprimer des champs du formulaire. Par défaut tous les inputs "classiques" (input, select, textarea) que vous utilisez avec un `ng-model` sont ajoutés au formulaire pour vous. Ils ont tous un controller nommé ngModelController, qui gère justement les états ($pristine, $valid, etc...), la validation, l'ajout au formulaire pour vous ainsi que le binding des vues au modèle. Les méthodes `addControl()` et `removeControl()` peuvent être intéressantes si vous voulez ajouter un autre type de champ à votre formulaire.
- `setDirty()`, `setPristine()` vont respectivement mettre le formulaire dans un état `dirty` ou `pristine` avec les classes CSS associées positionnées. A noter que les méthodes se propagent vers les formulaires parents si ils existent. En revanche, seule la méthode `setPristine()` s'applique sur chaque champ du formulaire. Vous pouvez donc faire un 'reset' du formulaire et de ses champs grâce à `$setPristine()`.
- `setValidity(errorType, isValid, control)` va, comme son nom l'indique, passer un champ de votre formulaire comme $valid ou $invalid pour le type d'erreur précisé, affectant par le même coup la validité du formulaire ainsi que celles des éventuels formulaires parents.

La dernière chose à retenir sur les formulaires concerne la soumission. Angular étant conçu pour les "single page applications", on cherche à éviter les rechargements non nécessaires. Ainsi l'action par défaut du formulaire sera désactivée, à moins que vous le vouliez explicitement en précisant une `action` dans la balise `form`. Angular cherchera plutôt à vous faire gérer vous même la soumission du formulaire, soit en utilisant la directive `ngSubmit` dans la balise `form` soit en utilisant la directive `ngClick` sur un `input` de type `submit` (mais pas les deux à la fois, sinon vous avez une double soumission!).

Vous avez maintenant toutes les clés pour faire une bonne validation côté client de vos formulaires en Angular. Mais que cela ne vous empêche de vérifier côté serveur! ;-)

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/10/22/forms-in-angular "Article original sur le blog de Cédric Exbrayat")_
