---
layout: post
title: Les nouveautés d'AngularJS 1.3
author: cexbrayat
tags: ["javascript","angularjs"]
canonical: http://hypedrivendev.wordpress.com/2014/06/11/nouveautes-angularjs-1.3/
---
La team Angular prépare avec amour sa nouvelle version.
Ayant abandonné son précédent système de versionning pour adopter le [semantic versionning](http://semver.org/), la 1.3 sera donc la nouvelle version
stable (précédemment 1.0.x, puis 1.2.x, la 1.1.x étant la branche de développement, à la Unix Kernel).
Mais que contient cette version fraichement émoulue? Nous avons passé au crible les différents commits (plus de 400!) qu'elle contient pour vous !

Outre les nombreux "fixes", on note l'abandon défnitif du support d'IE8 : cette fois vous êtes seuls au monde si votre application doit tourner sur ce bon vieux IE.

# Input date

Jusqu'à maintenant, les formidables capacités d'AngularJS pour les formulaires permettaient de gérer la validation des types `text`, `number`, `email`, `url`, en s'appuyant sur les  [type d'input HTML5](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-input-element.html) dans les navigateurs récents et en la simulant à l'aide d'un polyfill dans les autres. Plus besoin donc d'écrire vos propres expressions régulières, le travail est fait pour vous, et le framework se charge d'ajouter dynamiquement des classes CSS sur l'élément (par exemple `ng-invalid-email`) en cas de violation, ainsi que de maintenir une représentation de votre champ (et du formulaire plus globalement) en JS pour permettre de faire :

    <form name="userForm">
      <input name="email" type="email" ng-required="true" ng-model="user.email">
      <span ng-show="userForm.email.$error.email">Email is incorrect</span>
    </form>

La variable userForm représente le controller du formulaire (le nom vient du champ `name` du formulaire), son attribut email représente lui le controller du champ email.

Ainsi le message d'alerte indiquant que le champ n'est pas bien rempli ne s'affiche que si l'email est incorrect. Rien d'autre à faire pour nous, Angular s'occupe de tout.

Vous pouvez vous référer à [cet article précédent](TODO) pour plus d'informations sur le sujet.

La version 1.3 apporte maintenant la gestion des type 'date', en utilisant là encore le support HTML5 si disponible (et vous aurez alors le plus ou moins beau date-picker de votre navigateur), ou un champ texte sinon, dans lequel il faudra entrer une date au format ISO-8601, par exemple 'yyyy-MM-dd'. Le modèle lié doit être une Date JS.

    <form name="userForm">
      <input name="birthDate" type="date" ng-required="true" ng-model="user.birthDate"
        min="1900-01-01" max="2014-01-01">
      <span ng-show="userForm.birthDate.$error.date">Date is incorrect</span>
      <span ng-show="userForm.birthDate.$error.min">Date should be after 1900</span>
      <span ng-show="userForm.birthDate.$error.max">You should be born before 2014</span>
    </form>

Si il y a les dates, il y a également les heures. Si ce type n'est pas supporté par le navigateur, un champ texte sera utilisé et le format ISO sera HH:mm :

    <form name="eventForm">
      <input name="startTime" type="time" ng-required="true" ng-model="event.startTime"
        min="06:00" max="18:00">
      <span ng-show="eventForm.startTime.$error.time">Time is incorrect</span>
      <span ng-show="eventForm.startTime.$error.min">Event should be after 6AM</span>
      <span ng-show="eventForm.startTime.$error.max">Event should be before 6PM</span>
    </form>

La version 1.3 supporte également les champs 'dateTimeLocal', qui sont donc une date et une heure. Si ce type n'est pas supporté par le navigateur, un champ texte sera utilisé et le format ISO sera yyyy-MM-ddTHH:mm :

    <form name="eventForm">
      <input name="startDate" type="date" ng-required="true" ng-model="event.startDate"
        min="2014-06-01T00:00" max="2014-06-30T23:59">
      <span ng-show="eventForm.startDate.$error.dateTimeLocal">Date is incorrect</span>
      <span ng-show="eventForm.startDate.$error.min">Event should be after May</span>
      <span ng-show="eventForm.startDate.$error.max">Event should be before July</span>
    </form>

Enfin, il est possible d'utiliser les champs 'month' ou 'week', qui permettent évidemment de choisir un mois ou une semaine. Si ce type n'est pas supporté par le navigateur, un champ texte sera utilisé et le format ISO à utiliser sera yyyy-## ou yyyy-W## pour les semaines :

    <form name="eventForm">
      <input name="week" type="date" ng-required="true" ng-model="event.weekNumber"
        min="2014-W01" max="2014-W52">
      <span ng-show="eventForm.week.$error.week">Week is incorrect</span>
      <span ng-show="eventForm.week.$error.min">Event should be after 2013</span>
      <span ng-show="eventForm.week.$error.max">Event should be before 2015</span>
    </form>

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

Un problème peut cependant apparaître avec cette approche. Imaginez un bouton 'Clear' sur votre formulaire qui vide les champs. Si jamais l'utilisateur remplit un champ avec un debounce, puis clique sur 'Clear', les champs vont se vider, puis le debounce s'éxecuter et remplir à nouveau le champ! Il faut donc penser à supprimer tous les debounces en attente dans le code de la methode `clear()` appelée par le clic sur le bouton, en utilisant une nouvelle méthode exposée par le controller du champ, appelée `$rollbackViewValue`.

Vous pouvez jouer avec cette nouvelle fonctionnalité, et ses limites, avec ce [Plunker](http://plnkr.co/edit/94oLhzYOZeMcJcUBrXKq?p=preview).

# ngStrictDI

AngularJS offre un système d'injection de dépendances qui permet d'injecter les services voulus dans un composant :

    app.controller('MyCtrl', function($scope, $http){
      // $scope and $http are injected by AngularJS  
    });

C'est très pratique, mais cela a un "léger" problème si vous minifiez votre application : `$scope` va s'appeler `a`, `$http` va s'appeler `b`, et là c'est le drame, l'injection ne fonctionne plus car Angular se base sur les noms.

Pour éviter ça une autre syntaxe est disponible :

    app.controller('MyCtrl', ["$scope", "$http", function($scope, $http){
      // $scope and $http are injected by AngularJS  
      // and now handles minification
    }]);

Et là, plus de problème. Il faut donc penser à utiliser cette syntaxe (ou s'appuyer sur un plugin dans votre build qui fasse tout ça automatiquement comme [ng-min](https://github.com/btford/ngmin) ou [ng-annotate](https://github.com/olov/ng-annotate), ou encore une autre syntaxe, basée sur l'attribut `$inject`). Mais il arrive qu'un développeur oublie de l'utiliser à un seul endroit et l'application ne démarre pas, ce qui est bien sûr un peu pénible.

C'est là ou la version 1.3 apporte une nouveauté : il est désormais possible de démarrer Angular en mode 'strict-di' (injection de dépendance stricte), et un beau message d'erreur pour indiquer que tel composant n'utilise pas la bonne syntaxe apparaît.

    <body ng-app="app" ng-strict-di>...</body>

    app.controller('MyBadCtrl', function($scope, $http){
      // not allowed with strict DI
    });
    // --> 'MyBadCtrl is not using explicit annotation and cannot be invoked in strict mode'

# ngMessages

Un nouveau module est également apparu, c'est le module `ngMessages`.

Comme je l'expliquais plus haut, il est possible en Angular d'afficher des messages d'erreur sur vos formulaires en fonction de différents critères : si le champ est vierge ou si l'utilisateur l'a touché, si le champ est obligatoire, si le champ viole une contrainte particulière... Bref vous pouvez afficher le message que vous voulez!

Le reproche fait à la version actuelle est que la condition booléenne à écrire pour afficher le message est souvent verbeuse du type :

    <span ng-if="eventForm.eventName.$dirty && eventForm.eventName.$error.required">The event name is required</span>
    <span ng-if="eventForm.eventName.$dirty && eventForm.eventName.$error.minlength">The event name is not long enough</span>
    <span ng-if="eventForm.eventName.$dirty && eventForm.eventName.$error.maxlength">The event name is too long</span>
    <span ng-if="eventForm.eventName.$dirty && eventForm.eventName.$error.pattern">The event name must be in lowercase</span>

Ce n'est pas insurmontable mais on a souvent plusieurs messages par champ, et plusieurs champs par formulaire : on se retrouve avec un formulaire HTML bien rempli ! On peut aussi vouloir n'afficher qu'un seul message à la fois, par ordre de priorité.

C'est ici qu'entre en jeu le nouveau module, l'exemple précédent pourra s'écrire :

    <div ng-if="eventForm.eventName.$dirty" ng-messages="eventForm.eventName.$error">
      <div ng-message="required">The event name is required</div>
      <div ng-message="minlength">The event name is too short</div>
      <div ng-message="maxlength">The event name is too long</div>
      <div ng-message="pattern">The event name should be in lowercase</div>
    </div>

C'est un peu plus lisible et cela gère pour nous le fait de n'afficher qu'un seul message et de les afficher par ordre de priorité. Si vous voulez afficher plusieurs messages à la fois, c'est facile, vous ajoutez la directive `ng-messages-multiple`.

Il est possible d'écrire tout ça différemment :

    <ng-messages for="eventForm.eventName.$dirty" multiple>
      <ng-message when="required">...</ng-message>
      <ng-message when="minlength">...</ng-message>
      <ng-message when="maxlength">...</ng-message>
      <ng-message when="pattern">...</ng-message>
    </ng-messages>

Le dernier avantage à utiliser ngMessages réside dans la possibilité d'externaliser les messages d'erreur dans des templates.

    <!-- error-messages.html -->
    <ng-message when="required">...</ng-message>
    <ng-message when="minlength">...</ng-message>
    <ng-message when="maxlength">...</ng-message>
    <ng-message when="pattern">...</ng-message>

Puis dans votre formulaire :

    <ng-messages for="eventForm.eventName.$dirty" ng-include-messages="error-messages.html"/>

Et si jamais les messages d'erreur sont trop génériques, vous pouvez les surcharger directement dans votre formulaire :

    <ng-messages for="eventForm.eventName.$dirty" ng-include-messages="error-messages.html">
      <ng-message when="required">An overloaded message</ng-message>
    </ng-messages>

A noter que cela fonctionne également avec vos directives de validation custom!

La encore, amusez vous avec le [Plunker associé](http://plnkr.co/edit/jUkOtx30Etb1IbscxiJh?p=preview).

# Watchgroup

Le `$scope` est enrichi d'une nouvelle méthode pour observer un ensemble de valeurs : `watchGroup`. Elle fonctionne sensiblement comme la méthode `watch` déjà existante, à la nuance près qu'au lieu d'observer une seule valeur, elle en observe une collection :

    $scope.watchGroup([user1, user2, user3], function(newUsers, oldUsers) {
      // the listener is called any time one of the user is updated
      // with newUsers representing the new values and oldUsers the old ones.
    );

# One time binding

Il est maintenant possible de demander à Angular de cesser d'observer une expression une fois celle-ci évaluée. Il suffit pour cela de la précéder de `::` dans vos templates. Ainsi tout changement ultérieur ne sera pas repercuté à l'affichage.
{% raw %}
    $scope.name = 'Cédric';

    <!-- updating the input won't affect the displayed div -->
    <input type="text" ng-model="name">
    <div>Bind once {{ ::name }}</div>
{% endraw %}
Cela fonctionne aussi avec les collections, par exemple lorsqu'elles sont utilisées dans un `ng-repeat` :
{% raw %}
    $scope.tasks = ["laundry", "running", "shopping"];
    $scope.remove = function(){ $scope.tasks.pop(); };

    <!-- removing tasks will not affect the displayed list -->
    <button ng-click="remove()">remove</button>
    <div ng-repeat="task in ::tasks">
      {{ task }}
    </div>
{% endraw %}
Bien sûr, c'est plus sympa à essayer dans le [Plunker associé](http://plnkr.co/edit/bwX7SLqpUNv9Q5KXVgOj?p=preview).

Have fun!

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/06/11/nouveautes-angularjs-1.3/ "Article original sur le blog de Cédric Exbrayat")_
