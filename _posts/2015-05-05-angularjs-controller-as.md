---
layout: post
title: "Using Controller As in AngularJS"
author: ["cexbrayat"]
tags: ["AngularJS"]
description: "La syntaxe 'controller as' devient la syntaxe privilégiée pour écrire les controllers AngularJS. Voyons à quoi elle ressemble et ce qu'elle apporte !"
---

Ce n'est pas réellement une nouveauté, mais depuis la version 1.2, il est possible d'utiliser une syntaxe alternative pour déclarer vos controllers. Jusqu'ici, ce n'est pas quelque chose que nous avons beaucoup utilisé dans nos projets, mais cette fonctionnalité est de plus en plus mise en avant, alors nous allons l'examiner plus en détails.

Tout d'abord, en quoi cela consiste-t-il ? Imaginons un controller assez typique :

    angular.module('controllers')
      .controller('MainCtrl', function($scope){
        $scope.name = 'Cedric';
        $scope.greetings = function(name){
          return 'Hello ' + name;
        };
      });

Avec son template :

{%raw%}
    <div ng-controller="MainCtrl">
      <input ng-model="name">
      <p>{{greetings(name)}}</p>
    </div>  
{%endraw%}

Un simple `input`, initialisé avec une valeur par défaut, permet de renseigner un nom, et un message de bienvenue est affiché en dessous.

Si l'on utilise la syntaxe alternative du `controller as`, le code est légérement modifié pour que le controller manipule `this` au lieu de `$scope` :

    angular.module('controllers')
      .controller('MainCtrl', function(){
        this.name = 'Cedric';
        this.greetings = function(name){
          return 'Hello ' + name;
        };
      });

Le template doit lui aussi être modifié :

{%raw%}
    <div ng-controller="MainCtrl as vm">
      <input ng-model="vm.name">
      <p>{{vm.greetings(vm.name)}}</p>
    </div>
{%endraw%}

Un alias est créé pour le controller `ng-controller="MainCtrl as vm"`, ce qui implique que l'on devra utiliser `vm` pour référencer le controller dans le template.

L'alias que vous donnez est laissé à votre appréciation, mais on distingue plusieurs tendances :

- `vm`, alias pour `ViewModel` est souvent recommandé dans les guides de style, notamment ceux de [John Papa](https://github.com/johnpapa/angular-styleguide#style-y032) et de [Todd Motto](https://github.com/toddmotto/angularjs-styleguide#controllers). A noter que ce n'est pas notre préféré chez Ninja Squad, mais nous nous devons de vous informer de la préférence de la communauté :).
- `ctrl` est parfois vu.
- `main` ou `mainCtrl` pourrait aussi être utilisé, et c'est celui qui nous satisfait le plus. Cela permet de savoir rapidement à quel controller appartient la vue que l'on a sous les yeux, sans nécessairement devoir regarder la configuration du router. Ce type de nommage a aussi un avantage sur les deux précédents lorsque plusieurs controllers sont utilisés dans le même template, permettant de les distinguer nettement.

Vous utilisez probablement un router dans votre application. Les différents routers, aussi bien le router officiel `ngRoute`, que les routers proposés par la communauté, proposent aussi cette option dans leur configuration. Par exemple, avec `ngRoute`, on peut imaginer la configuration suivante :

    myApp.config(function($routeProvider){
        $routeProvider.when('/', {
            controller: 'MainCtrl',
            controllerAs: 'vm'
          });
      });

Pour les tests, vous aviez probablement un test de controller qui commence comme celui-ci :

    var scope;
    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      $controller('MainCtrl', {
        $scope: scope
      });
    });
    // we then call scope.greetings() to test it...

Avec `controller as`, vous pouvez le simplifier en :

    var mainCtrl;
    beforeEach(inject(function($controller) {
      mainCtrl = $controller('MainCtrl', {});
    }));
    // we then call mainCtrl.greetings() to test it...

En fait, on pourrait expliquer la transformation du controller par le code équivalent à ce que produit `controller as` :

    angular.module('controllers')
      .controller('MainCtrl', function($scope){
        $scope.vm = this;
        this.name = 'Cedric'; // revient à définir vm.name
        this.greetings = function(name){ // revient à définir vm.greetings
          return 'Hello ' + name;
        };
      });

L'avantage de cette syntaxe ne saute peut-être pas aux yeux, rendant les templates plus verbeux, et il faut connaître l'un des pièges d'AngularJS pour l'apprécier. Sans rentrer dans les détails ici, il peut arriver de se faire pièger par l'héritage des controllers. La technique habituelle pour éviter tout problème est de manipuler des models avec un `.`, par exemple `user.name` plutôt que `name`. Cette nouvelle syntaxe résoud finalement le problème, avec un niveau intermédiaire introduit dans nos models par l'alias.

Les partisans de `controller as` mettent également en avant le meilleur découplage visuel entre le controller et le vrai rôle de `$scope`, qui n'apparaîtra plus dans le code du controller, sauf à utiliser des watchers ou des événements. Mais dans ce cas, ce sera plus aisé de s'en rendre compte.

Comme je le disais, ce n'est pas la syntaxe que nous utilisions jusqu'à présent, car elle n'est pas sans faille non plus. Si vous connaissez un peu JavaScript, vous savez que manipuler `this` peut aussi amener son lot de problèmes... Afin de parer à cette éventualité, on voit donc souvent la création d'une variable locale au controller référençant `this`, workaround habituel mais toujours un peu triste :

    angular.module('controllers')
      .controller('MainCtrl', function(){
        var vm = this;
        vm.name = 'Cedric';
        vm.greetings = function(name){
          return 'Hello ' + name;
        };
      });

Ce genre de problème disparaîtra avec l'utilisation de ES6, grâce aux [arrow functions](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Fonctions/Fonctions_fl%C3%A9ch%C3%A9es), mais si vous écrivez encore vos applications en ES5, c'est une bonne précaution à prendre.

En fait, cette syntaxe est particulièrement adaptée si vous écrivez vos applications AngularJS en ES6, ce qui est parfaitement possible en utilisant un transpiler comme [Babel](https://babeljs.io/) ou [Traceur](https://github.com/google/traceur-compiler). A ce moment là, non seulement le problème du `this` peut être évité, mais on peut aussi utiliser des classes pour déclarer les controllers, ce qui a pour effet d'effectivement manipuler le `this` de la classe en définissant des méthodes de classe :

    class MainCtrl {
      constructor(){
        this.name = 'Cedric';  
      }

      greetings(name){
        return 'Hello ' + name;
      };
    }
    angular.module('controllers')
      .controller('MainCtrl', MainCtrl);

Dans cette optique futuriste d'applications écrites en ES6 ou TypeScript, la team Angular essaye de promouvoir la syntaxe `controller as`. Car c'est bien sûr cette écriture qui sera prévilégiée dans les applications [Angular](https://books.ninja-squad.com/angular). Si vous voulez préparer votre application à une éventuelle migration vers la version 2, il est donc probablement plus intéressant d'adopter cette syntaxe. D'autant que le tout nouveau router, qui devrait être utilisé aussi bien en AngularJS 1.x qu'en Angular 2, demande d'utiliser la syntaxe `controller as`. Pas le choix donc si vous voulez utiliser ce nouveau router !

Si vous avez une application existante, et que vous voulez migrer vers cette syntaxe, c'est faisable, mais bien sûr un peu long (il faut reprendre chaque controller, template et test) et un peu risqué (attention au `this` notamment dans les callbacks, et il ne faut rien oublier dans les templates : rien ne vous préviendra si vous oublier de renommer `name` en `vm.name`...). A noter que cette syntaxe est également possible avec les controllers des directives.

On voit donc que `controller as` est la syntaxe qui devient privilégiée officiellement : vous savez donc ce qu'il vous reste à faire pour votre prochaine application, voire pour votre application actuelle. [Notre ebook](https://books.ninja-squad.com/angularjs) va être mis à jour avec plus de détails sur cette partie, ainsi que sur les nouveautés de la version 1.4. Les heureux possesseurs d'un exemplaire recevront très bientôt une version mise à jour. Et si vous ne l'avez pas encore acheté (est-ce possible ?), c'est le moment !
