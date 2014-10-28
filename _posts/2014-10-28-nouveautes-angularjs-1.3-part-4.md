---
layout: post
title: Les nouveautés d'AngularJS 1.3 - Part 4
author: cexbrayat
tags: ["javascript","angularjs"]
canonical: http://hypedrivendev.wordpress.com/2014/10/28/nouveautes-angularjs-1.3-part-4/
---

Angular est [finalement sorti en version 1.3.0](http://angularjs.blogspot.fr/2014/10/angularjs-130-superluminal-nudge.html), près d'un an après la release de la 1.2.0. Pas mal de petites nouveautés sont disponibles et vous pouvez voir celles des premières bétas dans les articles précédents&nbsp;:

- [part 1](http://blog.ninja-squad.com/2014/06/24/nouveautes-angularjs-1.3/)
- [part 2](http://blog.ninja-squad.com/2014/07/31/nouveautes-angularjs-1.3-part-2/)
- [part 3](http://blog.ninja-squad.com/2014/08/28/nouveautes-angularjs-1.3-part-3/)

Cet article est donc le dernier de la série, et nous allons voir quels sont les derniers goodies que les 400 contributeurs (dont [@jbnizet](https://twitter.com/jbnizet) et moi-même \o/) ont concoctés.

# Validation

Le mécanisme de validation a été légèrement revu dans la version 1.3 et reprend le principe des validateurs de Dart. L'idée est de découpler la validation des champs qui était pour l'instant à la charge des `$formatters` ou des `$parsers`. Ceux-ci existent toujours et peuvent transformer les valeurs comme ils le souhaitent, mais c'est maintenant les `$validators` qui choisissent si une valeur est valide ou non pour le champ, en prenant en compte les différentes directives présentes sur le champ en question (`ngMinLength`, `ngPattern`, nos propres directives, etc...). 

Cela impacte donc la façon d'écrire une directive de validation custom, pour les rendre plus simples. Par exemple, pour n'autoriser que des logins avec au moins un chiffre&nbsp;:

    app.directive('atLeastOneNumber', function(){
      return {
        require: '?ngModel',
        link: function(scope, element, attributes, modelCtrl){
          modelCtrl.$validators.atLeastOneNumber = function(value){
            return (/.*\d.*/).test(value);
          }
        }
      }
    });

Vous pouvez jouer avec cette nouvelle fonctionnalité [ici](http://plnkr.co/edit/aGUq6F9K5tNlNrHjSmg3?p=preview).

On note aussi l'ajout de validateurs asynchrones. Si vous devez ajouter une validation custom à un champ, en interrogeant votre backend pour savoir si le nom de l'utilisateur est disponible par exemple, alors vous allez pouvoir ajouter votre validateur aux `asyncValidators`. Ceux-ci ne se lanceront que lorsque les validateurs synchrones auront fini avec succès (par exemple, la taille minimum du login de l'utilisateur).
En plus, une classe `ng-pending` sera ajoutée au champ, et vous pourrez donc indiquer visuellement que vous attendez une réponse du serveur. En attendant, le champ n'est ni valide, ni invalide.

Si vous voulez voir un exemple détaillé de l'ajout de validateurs (synchrones et asynchrones), c'est sur ce [plunkr](http://plnkr.co/edit/IcU9GMzTKD8zDBDqP1ZV?p=preview).

# Performance

Il y a eu un gros focus sur la performance, avec pas mal d'optimisations internes et de nouvelles possibilités pour les développeurs. Les références aux benchmarks internes donnent des résultats assez impressionnants.

Vous pouvez maintenant désactiver un certain nombre d'info de debug en prod. Si vous ajoutez cette ligne au démarrage de votre application :

    $compileProvider.debugInfoEnabled(false)

alors Angular ne stockera pas les infos de binding et du scope courant dans le DOM. Les gains sont d'environ 20% sur certains benchmarks utilisés par la team Angular. Attention toutefois, les outils de debug comme Batarang, ou de test comme Protractor ont besoin de ces informations&nbsp;: il faudra donc réactiver les infos de debug pour les tests end-to-end.
Une méthode globale a été ajoutée pour réactiver ces informations à chaud si nécessaire&nbsp;: dans la console du navigateur, entrez `angular.reloadWithDebugInfo()`. L'appli va alors se recharger, cette fois avec les informations de debug.

Les filtres ont également été revus et optimisés&nbsp;: 
{% raw %}
    {{ 'prenom' + ' nom' | uppercase }} 
{% endraw %}
ne sera réévalué que si `prénom` ou `nom` change et pas à chaque cycle comme actuellement. Cela considère donc maintenant par défaut que votre filtre est sans état, c'est à dire qu'il ne dépend que des entrées. C'est déjà ce qu'il était conseillé de faire. Si ce n'est pas le cas pour l'un de vos filtres, alors vous devrez marquer le filtre en question comme `$stateful`. Mais vous comprenez que ce ne doit être qu'un cas exceptionnel.

# ngAria

Un autre module fait son apparition : après ngMessages, c'est au tour de ngAria, qui ajoute automatiquement les attributs d'accessibilité sur certaines directives si le module est présent (aria-hidden, aria-checked, aria-disabled, aria-required, aria-invalid, aria-multiline, aria-valuenow, aria-valuemin, aria-valuemax, tabindex). Il est possible de désactiver sélectivement celles que l'on veut.  
Plus d'excuses pour ne pas faire d'application Angular accessible&nbsp;!

Vous pouvez bien sûr trouver toutes ces nouveautés et d'autres astuces dans notre [ebook à prix libre](https://books.ninja-squad.com).

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/10/28/nouveautes-angularjs-1.3-part-4/ "Article original sur le blog de Cédric Exbrayat")_