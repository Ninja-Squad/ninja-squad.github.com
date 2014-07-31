---
layout: post
title: Les nouveautés d'AngularJS 1.3 - Part 2
author: cexbrayat
tags: ["javascript","angularjs"]
canonical: http://hypedrivendev.wordpress.com/2014/07/31/nouveautes-angularjs-1_3-part-2/
---

Nous poursuivons notre exploration des nouvelles features d'AngularJS 1.3! Si vous avez raté la première partie, c'est [par ici](http://blog.ninja-squad.com/2014/06/24/nouveautes-angularjs-1.3/). 

Et bien sûr, vour pourrez retrouver tout ça dans notre livre dont la sortie se rapproche!

# ngStrictDI

AngularJS offre un système d'injection de dépendances qui permet d'injecter les services voulus dans un composant :

    app.controller('MyCtrl', function($scope, $http){
      // $scope and $http are injected by AngularJS
    });

C'est très pratique, mais cela a un "léger" problème si vous minifiez votre application : `$scope` va devenir `a`, `$http` va devenir `b`, et là c'est le drame, l'injection ne fonctionne plus car Angular se base sur les noms.

Pour éviter cela, une autre syntaxe est disponible :

    app.controller('MyCtrl', ["$scope", "$http", function($scope, $http){
      // $scope and $http are injected by AngularJS
      // and now handles minification
    }]);

Et là, plus de problème. Il faut donc penser à utiliser cette syntaxe (ou s'appuyer sur un plugin dans votre build qui fasse tout ça automatiquement comme [ng-min](https://github.com/btford/ngmin) ou [ng-annotate](https://github.com/olov/ng-annotate). Une autre syntaxe, basée sur l'attribut `$inject` est aussi proposée. Mais il arrive qu'un développeur oublie de l'utiliser à un seul endroit et l'application ne démarre pas, ce qui est bien sûr un peu pénible.

C'est là ou la version 1.3 apporte une nouveauté : il est désormais possible de démarrer Angular en mode 'strict-di' (injection de dépendance stricte), et un beau message d'erreur pour indiquer que tel composant n'utilise pas la bonne syntaxe apparaît.

    <body ng-app="app" ng-strict-di>...</body>

    app.controller('MyBadCtrl', function($scope, $http){
      // not allowed with strict DI
    });
    // --> 'MyBadCtrl is not using explicit annotation and cannot be invoked in strict mode'

# ngMessages

Un nouveau module est également apparu, c'est le module `ngMessages`.

Comme je l'expliquais dans l'article précédent, il est possible en AngularJS d'afficher des messages d'erreur sur vos formulaires en fonction de différents critères : si le champ est vierge ou si l'utilisateur l'a touché, si le champ est obligatoire, si le champ viole une contrainte particulière... Bref vous pouvez afficher le message que vous voulez!

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

Il est possible d'écrire tout ça différemment, avec un attribut `multiple` :

    <ng-messages for="eventForm.eventName.$dirty" multiple>
      <ng-message when="required">...</ng-message>
      <ng-message when="minlength">...</ng-message>
      <ng-message when="maxlength">...</ng-message>
      <ng-message when="pattern">...</ng-message>
    </ng-messages>

Le dernier avantage à utiliser ngMessages réside dans la possibilité d'externaliser les messages d'erreur dans des templates, offrant ainsi la possibilité de les réutiliser par ailleurs. 

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

Là encore, amusez-vous avec le [Plunker associé](http://plnkr.co/edit/jUkOtx30Etb1IbscxiJh?p=preview).

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

Il reste encore quelques fonctionnalités sympatiques à couvrir dans cette version 1.3 : stay tuned !

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/07/31/nouveautes-angularjs-1_3-part-2/ "Article original sur le blog de Cédric Exbrayat")_
