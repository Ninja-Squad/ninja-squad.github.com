---
layout: post
title: Les nouveautés d'AngularJS 1.3
author: cexbrayat
tags: ["javascript","angularjs"]
canonical: http://hypedrivendev.wordpress.com/2014/06/24/nouveautes-angularjs-1_3/
---
La team Angular prépare avec amour sa nouvelle version.
Ayant abandonné son précédent système de versionning pour adopter le [semantic versionning](http://semver.org/), la 1.3 sera donc la nouvelle version
stable (précédemment 1.0.x, puis 1.2.x, la 1.1.x étant la branche de développement, à la Unix Kernel).

Mais que contient cette version fraichement émoulue? Outre les nombreux "fixes", on note l'abandon définitif du support d'IE8 : cette fois vous êtes seuls au monde si votre application doit tourner sur ce bon vieux IE. Pour le reste, nous avons passé au crible pour vous les différents commits (plus de 400!) qu'elle contient !

> **Disclaimer**  
> Nous sommes dans la phase finale de rédaction d'**un livre** sur AngularJS en français, nous vous en dirons bientôt plus! Et en attendant, si vous voulez en savoir plus, allez voir [notre formation](http://ninja-squad.fr/training/angularjs), qui est d'ores et déjà à jour!

# ngModelOptions

Jusqu'ici la directive `ngModel` lançait une mise à jour du model à chaque action utilisateur (donc à chaque frappe clavier par exemple, les validations étaient exécutées, et une boucle `$digest` se déroulait). Cela fonctionne très bien, mais peut être pénalisant si vous avez une page avec beaucoup de bindings surveillés et à mettre à jour. C'est ici qu'intervient cette nouvelle directive : `ngModelOptions`.

Il devient ainsi possible de changer ce comportement par défaut et de déclencher ces différents événements selon votre envie, en passant un objet représentant les options à cette directive. La pull-request était ouverte depuis plus d'un an, comme quoi il ne faut jamais désespéré quand on contribue à un projet populaire! Tous les inputs portant un `ngModel` vont alors chercher ces options soit sur l'élément actuel ou sur ses ancêtres.

Ces options peuvent contenir un champ `updateOn` qui définit sur quel événement utilisateur la mise à jour du modèle doit être effectuée. Vous pouvez par exemple ne la déclencher que sur la perte de focus du champ :

    <input name="guests" type="number" ng-required="true" ng-model="event.guests" max="10" ng-model-options="{ updateOn: 'blur' }">

Il est possible de passer plusieurs événements par exemple 'blur' pour la perte de focus et 'paste' pour déclencher la mise  à jour si l'utilisateur colle une valeur dans le champs.

    <input name="guests" type="number" ng-required="true" ng-model="event.guests" max="10"
ng-model-options="{ updateOn: 'blur paste' }">

Pour conserver le comportement normal, utilisez l'événement 'default' : utile si vous voulez simplement ajouter de nouveaux événements.

Les options peuvent également contenir un champ `debounce` qui spécifie un temps d'attente depuis le dernier événement avant de lancer la mise à jour. Par exemple, seulement une seconde après la dernière action utilisateur :

    <input name="guests" type="number" ng-required="true" ng-model="event.guests" max="10"
ng-model-options="{ debounce: 1000 }">

La valeur peut être un nombre si le même temps doit être attendu pour tous les événements, ou un objet avec comme attribut chacun des événements pour lequel vous voulez spécifier un debounce et la valeur de celui-ci.

    <input name="guests" type="number" ng-required="true" ng-model="event.guests" max="10"
ng-model-options="{ debounce: { default: 0, paste: 500 }}">

On peut donc également définir cette option pour toute une page ou tout un formulaire, puisque chaque `ngModel` recherchera les options également sur ses ancêtres :


    <form name="eventForm" ng-model-options="{ debounce: 1000 }">
      <input name="week" type="date" ng-required="true" ng-model="event.weekNumber"
        >
      <input name="guests" type="number" ng-required="true" ng-model="event.guests" max="10">
    </form>

Cette nouvelle option est assez pratique, notamment pour un cas très précis qui arrive parfois. Imaginez que vous ayez un formulaire d'inscription et que le champ login vérifie si la valeur entrée par l'utilisateur est disponible côté serveur : on voit ici l'intérêt du debounce pour attendre que l'utilisateur termine son entrée de valeur, ou d'attendre la perte de focus pour faire la vérification, plutôt que de lancer une requête HTTP à chaque frappe clavier!

    <!-- poney-unique-name is a custom validator, implemented as a directive, checking with the server if the value is not already taken by another poney -->
    <input name="name" type="text" ng-required="true" poney-unique-name ng-model="poney.name" ng-model-options="{updateOn: 'blur'}">

Un problème peut cependant apparaître avec cette approche. Imaginez un bouton 'Clear' sur votre formulaire qui vide les champs. Si jamais l'utilisateur remplit un champ avec un debounce, puis clique sur 'Clear', les champs vont se vider, puis le debounce s'éxecuter et remplir à nouveau le champ! Il faut donc penser à supprimer tous les debounces en attente dans le code de la méthode `clear()` appelée par le clic sur le bouton, en utilisant une nouvelle méthode exposée par le controller du champ, appelée `$rollbackViewValue`. Celle-ci est également disponible sur le formulaire pour agir sur tous les champs d'un coup.

Vous pouvez jouer avec cette nouvelle fonctionnalité, et ses limites, avec ce [Plunker](http://plnkr.co/edit/94oLhzYOZeMcJcUBrXKq?p=preview).

# Input date

Jusqu'à maintenant, les formidables capacités d'AngularJS pour les formulaires permettaient de gérer la validation des types `text`, `number`, `email`, `url`, en s'appuyant sur les  [types d'input HTML5](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-input-element.html) dans les navigateurs récents et en la simulant à l'aide d'un polyfill dans les autres. Plus besoin donc d'écrire vos propres expressions régulières, le travail est fait pour vous, et le framework se charge d'ajouter dynamiquement des classes CSS sur l'élément (par exemple `ng-invalid-email`) en cas de violation, ainsi que de maintenir une représentation de votre champ (et du formulaire plus globalement) en JS pour permettre de faire :

    <form name="userForm">
      <input name="email" type="email" ng-required="true" ng-model="user.email">
      <span ng-show="userForm.email.$error.email">Email is incorrect</span>
    </form>

La variable userForm représente le controller du formulaire (le nom vient du champ `name` du formulaire), son attribut email représente lui le controller du champ email.

Ainsi le message d'alerte indiquant que le champ n'est pas bien rempli ne s'affiche que si l'email est incorrect. Rien d'autre à faire pour nous, Angular s'occupe de tout.

Vous pouvez vous référer à [cet article précédent](http://blog.ninja-squad.com/2013/10/22/forms-in-angularjs/) pour plus d'informations sur le sujet.

La version 1.3 apporte maintenant la gestion des type 'date', en utilisant là encore le support HTML5 si disponible (et vous aurez alors le plus ou moins beau date-picker de votre navigateur), ou un champ texte sinon, dans lequel il faudra entrer une date au format ISO-8601, par exemple 'yyyy-MM-dd'. Le modèle lié doit être une Date JS.

    <form name="userForm">
      <input name="birthDate" type="date" ng-required="true" ng-model="user.birthDate"
        min="1900-01-01" max="2014-01-01">
      <span ng-show="userForm.birthDate.$error.date">Date is incorrect</span>
      <span ng-show="userForm.birthDate.$error.min">Date should be after 1900</span>
      <span ng-show="userForm.birthDate.$error.max">You should be born before 2014</span>
    </form>

Si il y a les dates, il y a également les heures.
Si ce type n'est pas supporté par le navigateur, un champ texte sera utilisé et le format ISO sera HH:mm :

    <form name="eventForm">
      <input name="startTime" type="time" ng-required="true" ng-model="event.startTime"
        min="06:00" max="18:00">
      <span ng-show="eventForm.startTime.$error.time">Time is incorrect</span>
      <span ng-show="eventForm.startTime.$error.min">Event should be after 6AM</span>
      <span ng-show="eventForm.startTime.$error.max">Event should be before 6PM</span>
    </form>

Le modèle lié est une Date JS avec la date du 1 Janvier 1970 et l'heure saisie.

La version 1.3 supporte également les champs 'dateTimeLocal', qui sont donc une date et une heure. Si ce type n'est pas supporté par le navigateur, un champ texte sera utilisé et le format ISO sera yyyy-MM-ddTHH:mm :

    <form name="eventForm">
      <input name="startDate" type="datetime-local" ng-required="true" ng-model="event.startDate"
        min="2014-06-01T00:00" max="2014-06-30T23:59">
      <span ng-show="eventForm.startDate.$error.dateTimeLocal">Date is incorrect</span>
      <span ng-show="eventForm.startDate.$error.min">Event should be after May</span>
      <span ng-show="eventForm.startDate.$error.max">Event should be before July</span>
    </form>

Enfin, il est possible d'utiliser les champs 'month' ou 'week', stocké également dans un modèle de type Date,
qui permettent évidemment de choisir un mois ou une semaine.
Si ce type n'est pas supporté par le navigateur, un champ texte sera utilisé et le format ISO à utiliser sera yyyy-## ou yyyy-W## pour les semaines :

    <form name="eventForm">
      <input name="week" type="week" ng-required="true" ng-model="event.weekNumber"
        min="2014-W01" max="2014-W52">
      <span ng-show="eventForm.week.$error.week">Week is incorrect</span>
      <span ng-show="eventForm.week.$error.min">Event should be after 2013</span>
      <span ng-show="eventForm.week.$error.max">Event should be before 2015</span>
    </form>

Ces deux fonctionnalités ne sont qu'une partie de celles offertes par la nouvelle version : on en garde quelques unes pour un prochain post. Stay tuned!

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/06/24/nouveautes-angularjs-1_3/ "Article original sur le blog de Cédric Exbrayat")_
