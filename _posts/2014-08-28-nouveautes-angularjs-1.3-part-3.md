---
layout: post
title: Les nouveautés d'AngularJS 1.3 - Part 3
author: cexbrayat
tags: ["javascript","angularjs"]
canonical: http://hypedrivendev.wordpress.com/2014/08/28/nouveautes-angularjs-1.3-part-3/
---

Nous poursuivons notre exploration des nouvelles features d'AngularJS 1.3!
Pour vous rafraîchir la mémoire, nous avons déjà parlé de ngModelOptions et des nouveaux inputs dans [la première partie](http://blog.ninja-squad.com/2014/06/24/nouveautes-angularjs-1.3/), ainsi que de ngStrictDI, bindOnce, ngMessages et watchCollection dans [la seconde partie](http://blog.ninja-squad.com/2014/07/31/nouveautes-angularjs-1.3-part-2/).

# No more global controllers

Changement particulièrement "BREAKING" ! Par défaut, il n'est désormais plus possible de déclarer un controller comme une fonction globale : tout passera désormais par l'utilisation des modules et de la méthodes d'enregistrement `.controller()`.

Ainsi, ce que vous aviez probablement utilisé dans votre première application de TodoList, ne fonctionnera plus :

    // won't work in 1.3
    function PersonCtrl($scope){
      ...
    }

    // now you must use
    angular.module('controllers')
      .controller('PersonCtrl', function($scope){
        ...
      })

A noter qu'il est possible de réactiver l'ancien comportement en configuration le `$controllerProvider` avec la méthode `.allowGlobals()` :

    angular.module('todoApp')
      .config($controllerProvider){
        $controllerProvider.allowGlobals();
      }

    // work again
    function PersonCtrl($scope){
      ...
    }

# Getter / Setter

Je vous avais déjà parlé de la directive `ngModelOptions`. Une autre option est dorénavant disponible pour celle-ci : celle d'activer un mode getter/setter pour votre modèle.

    <input ng-model="todo.name" ng-model-options="{ getterSetter: true }" />

Votre controller devra alors posséder un attribut du scope `todo.name` qui sera une fonction. Si celle-ci est appelée sans paramètres, elle renverra la valeur de l'attribut, sinon elle modifiera éventuellement la valeur de l'attribut avec la valeur du paramètre, de la façon dont vous le déciderez.
Un getter/setter qui fonctionnerait sans modification ressemblerait à celui-ci :

    var _name = 'internal name'
    $scope.todo {
      name: function(newName){
        _name = angular.isDefined(newName) ? newName : _name;
        return _name;
      }
    }

L'intérêt principal réside dans le fait que l'on peut alors avoir une représentation interne différente de la représentation envoyée à l'utilisateur. Cela peut remplacer ce qui aurait été précédemment fait avec un watcher, [voir cet exemple avec $location](https://github.com/angular/angular.js/commit/5963b5c69f5dc145c9535f734c43ee6027ae24bd).

Vous pouvez alors accéder à votre attribut par son getter avec `todo.name()` ou changer sa valeur avec `todo.name('new name')`.

# multiElement directives

Si vous utilisez des directives multi élements, par exemple :

    <div poney-start></div>
    <div>... some content</div>
    <div poney-end></div>

Vous devez maintenant déclarer la directive avec un attribut `multiElement :

    angular.module('directives')
      .directive('poney', function() {
        return {
          multiElement: true,
          ...
        };
      });

# Directives as Element or Attribute by default

Autre nouveauté dans les directives, elles sont maintenant par défaut à la fois un élément et un attribut (`restrict: 'EA'`). Jusqu'ici, si rien n'était précisé, la directive cherchait seulement les attributs (`restrict: 'A'`).

# ngRepeat alias

Vous savez qu'il est possible de filtrer la collection que vous allez afficher dans un `ngRepeat`, par exemple :

    <div ng-repeat="poney in poneys | filter:search">{{ poney }}</div>

C'est très pratique, mais si l'on veut utiliser le nombre de résultats affichés, on est obligé de réappliquer le même filtre à la même collection :

    <div ng-repeat="poney in poneys | filter:search">{{ poney }}</div>
    <div ng-if="(poneys | filter:search).length === 0">No results.</div>

La version 1.3 introduit un alias `as`, qui permet justement de stocker le résultat du filtre dans le `ngRepeat` et de le réutiliser plus tard.

    <div ng-repeat="poney in poneys | filter:search as poneysFiltered">{{ poney }}</div>
    <div ng-if="poneysFiltered.length === 0">No results.</div>

# New promise syntax

Il est maintenant possible de construire une promise directement avec le constructeur `$q`.

Précédemment, il était nécessaire d'utiliser cette syntaxe, dont je n'ai jamais été très fan :

    var d = $q.defer();
    d.promise.then(function() {
      deferred.resolve.call(deferred);
    });
    d.resolve('foo');

Il maintenant possible de faire plus élégant, et beaucoup plus proche de la syntaxe adoptée par ES6 :

    var d = $q(function(resolve) {
      resolve('foo');
    }).then(function(value) {
      deferred.resolve(value);
    });

# ngTouched and ngSubmitted

Jusqu'ici les champs d'un formulaire avaient les propriétés (et les règles CSS associées) :

- `$pristine` si le champ était vierge
- `$dirty` si l'utilisateur avait changé le modèle
- `$invalid` si l'une des règles de validation n'était pas respectée
- `$valid` sinon

Deux nouveaux états sont maintenant disponibles, avec les classes CSS associées :

- `$untouched` si le champ a le focus
- `$touched` si le champ a perdu le focus (même sans avoir changé le modèle)

Concrètement, cela permet d'afficher les erreurs de validation dès qu'un utilisateur sort du champ, même sans l'avoir modifié, là ou `$dirty` demande d'avoir au moins une modification pour s'appliquer. Par exemple :

    <form name="userForm">
      <input name="email" type="email" ng-model="email" required>
      <div ng-if="userForm.email.$touched && userForm.email.$invalid">Required email</div>
    </form>

Nous saurons également maintenant si un formulaire a été soumis ou non avec l'attribut `$submitted` qui sera géré au niveau de celui-ci, et avec la classe `ng-submitted` qui apparaîtra une fois le formulaire soumis.

Vous pouvez tester l'exemple dans [ce Plunker](http://plnkr.co/edit/u1JcxrqJgmNObOGltOMz?p=preview).

Déjà une vingtaine de betas sont sorties pour cette version 1.3.0, on se rapproche de la sortie finale. Mais il reste probablement de quoi faire un dernier article avant celle-ci ;).

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/08/28/nouveautes-angularjs-1.3-part-3/ "Article original sur le blog de Cédric Exbrayat")_
