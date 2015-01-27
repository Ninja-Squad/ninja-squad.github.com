---
layout: post
title: 5 astuces sur les directives AngularJS et leurs tests
author: ["cexbrayat"]
tags: ["javascript", "angularjs"]
description: 5 astuces sur la façon d'écrire les directives AngularJS et leurs tests
---

*Looking for the English version? It's [here](http://blog.ninja-squad.fr/2015/01/27/5-tricks-about-directives-and-tests/)*.

S'il y a bien un sujet compliqué en Angular, c'est l'écriture de directives. J'espère que les chapitres de [notre livre](https://books.ninja-squad.com) aident à passer un cap sur ce problème, mais il manque sur les internets un article un peu complet sur la façon de tester celles-ci.

Angular est très bien pensé pour les tests, avec un système de mock, d'injection de dépendance, de simulation des requêtes HTTP, bref la totale. Mais les tests de directive restent souvent le parent pauvre de tout ça.

Une directive un peu complète va contenir un template, un scope à elle avec différentes valeurs initialisées, et un ensemble de méthodes de comportement. Essayons de prendre une exemple pratique et pas trop compliqué :

{% raw %}
    angular.module('myProject.directives').directive('gravatar', function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          user: '=',
          size: '@'
        },
        template: '<img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{ user.gravatar }}?s={{ sizePx }}&d=identicon"/>',
        link: function(scope) {
          if (scope.size === 'lg') {
            scope.sizePx = '40';
          } else {
            scope.sizePx = '20';
          }
        }
      };
    });
{% endraw %}

Cette directive permet d'afficher le gravatar d'un utilisateur (passé en paramètre `user`), avec 2 tailles possibles : 20px par défaut et 40px si le paramètre `size` est précisé avec la valeur `lg`. Cette logique de composant est assez agréable à manipuler, puisque pour l'utiliser, il suffit de mettre dans un template :

    <gravatar user="user" size="lg"></gravatar>

Tester une directive ressemble à un test classique, avec quelques instructions en plus qui ressemblent à des incantations de magie noire quand on débute, et que l'on copie/colle religieusement en espérant que personne ne nous pose de questions sur leur signification.

    beforeEach(inject(function($rootScope, $compile) {
      scope = $rootScope;
      scope.user = {
          gravatar: '12345',
          name: 'Cédric'
      };

      gravatar = $compile('<gravatar user="user" size="lg"></gravatar>')(scope);

      scope.$digest();
    }));

# 1. C'est quoi ce bordel&nbsp;?!

On commence par créer une chaîne de caractères avec le HTML que l'on veut interpréter. Celui-ci doit, bien sûr, contenir la directive que vous voulez tester :

    '<gravatar user="user" size="lg"></gravatar>'

Ensuite l'élément est compilé : c'est peut-être la première fois que vous voyez le service `$compile`. Celui-ci est un service fourni par Angular, utilisé par le framework lui-même, mais rarement dans notre code. A l'exception des tests donc.
Pour le compiler, on lui passe un scope, qui correspond aux variables auxquelles la directive aura accès. La nôtre a, par exemple, besoin d'un utilisateur : on crée donc un scope avec une variable `user` qui contient l'id gravatar qui va bien.

Le `$digest()` à la fin permet de déclencher les watchers, c'est à dire résoudre toutes les expressions contenues dans notre directive : `user.gravatar` et `sizePx`.

Une fois compilée, on récupère un élément Angular, comme lorsque l'on utilise la méthode [angular.element](https://docs.angularjs.org/api/ng/function/angular.element) qui wrappe un élément de DOM ou du HTML sous forme de chaîne de caractères pour en faire un élément jQuery.

Et voilà, le setup est fait. Maintenant, nous allons pouvoir passer au test proprement dit.

Ce que vous ne savez probablement pas, c'est qu'un élément Angular offre de petits bonus. Ainsi, nous pouvons accéder au scope de la directive, qu'il soit isolé ou non. Dans notre cas, la directive `gravatar` utilise un scope isolé, donc notre test ressemblerait à quelque chose comme ça :

    it('should have the correct size on scope', function() {
        expect(gravatar.isolateScope().sizePx).toBe('40');
    });

Si le scope n'était pas isolé, on utiliserait `scope()` :

    it('should have the correct size on scope', function() {
        expect(gravatar.scope().sizePx).toBe('40');
    });

On peut aussi s'assurer que le HTML produit par la directive est conforme à ce que l'on attend. Vous pouvez utiliser la méthode `html()` qui renvoie le HTML de l'élément sous forme de chaîne de caractères, mais cela donne des tests un peu pénibles à maintenir. On peut faire quelque chose d'un peu plus sympa, pour tester la validité de l'élément, des classes ou attributs avec :

    it('should create a gravatar image with large size', function() {
        expect(gravatar[0].tagName).toBe('IMG');
        expect(gravatar.hasClass('gravatar')).toBe(true);
        expect(gravatar.attr('src')).toBe('http://www.gravatar.com/avatar/12345?s=40&d=identicon');
    });

Il est pas beau ce test ? Mais on peut encore mieux faire...

# 2. La logique dans un controller

La logique d'une directive peut être un pénible à tester. Le plus simple est de l'externaliser dans un controller dédié, que l'on peut tester comme un controller classique :

{% raw %}
    angular.module('myProject.directives').directive('gravatar', function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          user: '=',
          size: '@'
        },
        template: '<img class="gravatar" ng-src="http://www.gravatar.com/avatar/{{ user.gravatar }}?s={{ sizePx }}&d=identicon"/>',
        controller: 'GravatarDirectiveController'
      };
    });
{% endraw %}

C'est d'autant plus utile si votre controller grossit et devient plus complexe.

# 3. Externaliser le template

De la même façon, si le template grossit trop, n'hésitez pas à l'extraire dans un fichier à part.

    angular.module('myProject.directives').directive('gravatar', function() {
      return {
        restrict: 'E',
        replace: true,
        scope: {
          user: '=',
          size: '@'
        },
        templateUrl: 'gravatar.html',
        controller: 'GravatarDirectiveController'
      };
    });

Cela introduit cependant une petite subtilité pour les tests. Si vous relancez celui que vous aviez avant d'externaliser le template, vous allez avoir l'erreur suivante :

    Error: Unexpected request: GET gravatar.html
    No more request expected

Et oui, si on externalise le template, AngularJS va faire une requête pour le récupérer auprès du serveur. D'où une requête GET inattendue...
Mais on peut charger le template dans le test pour éviter ce problème. Il suffit pour cela d'utiliser [karma-ng-html2js](https://github.com/karma-runner/karma-ng-html2js-preprocessor) (ou le module grunt/gulp équivalent). Le principe est de charger les templates dans un module à part et d'inclure ce module dans notre test.

Il suffit alors de charger le template dans le test :

    beforeEach(module('gravatar.html'));

Et le tour est joué !

# 4. Récursivité

Si vous faites des directives un peu avancées, un jour ou l'autre, vous allez tomber sur une directive qui s'appelle elle-même. Bizarrement, ce n'est pas supporté par défaut par AngularJS. Vous pouvez cependant ajouter un module, RecursionHelper, qui offre un service permettant de compiler manuellement des directives récursives :

    angular.module('myProject.directives')
    .directive('container', function(RecursionHelper) {
      return {
        restrict: 'E',
        templateUrl: 'partials/container.html',
        controller: 'ContainerDirectiveCtrl',
        compile: function(element) {
          return RecursionHelper.compile(element, function() {
          });
        }
      };
    });

# 5. Apprendre des meilleurs

Le meilleur moyen de progresser en écriture de directives est de vous inspirer des projets open-source. Le projet AngularUI contient un grand nombre de directives, notamment les directives de [UIBootstrap](http://angular-ui.github.io/bootstrap/) qui peuvent vous inspirer. L'un des principaux contributeurs au projet, [Pawel](https://github.com/pkozlowski-opensource), a fait un talk avec [quelques idées](http://pkozlowski-opensource.github.io/ng-europe-2014/presentation/#/) complémentaires à cet article.

Et si vous voulez mettre tout ça en pratique, [notre prochaine formation](http://ninja-squad.fr/training/angularjs) a lieu à Paris les 9-11 Février, et la suivante à Lyon les 9-11 Mars !

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2015/01/27/5-astuces-sur-les-directives-et-leurs-tests/ "Article original sur le blog de Cédric Exbrayat")_
