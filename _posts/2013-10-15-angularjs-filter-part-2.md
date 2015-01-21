---
layout: post
title: Angular filter - Part 2
author: [cexbrayat]
tags: [angularjs]
canonical: http://hypedrivendev.wordpress.com/2013/10/15/angular-filter-part-2
---

Cet article fait suite à la [première partie sur les filtres en AngularJS](http://blog.ninja-squad.com/2013/06/28/angular-filter-part-1). 

# Filter

Nous avons vu les principaux filtres, mais il manque un qui se nomme … ‘filter’.

Ce filtre agit sur un tableau pour en retourner un sous ensemble correspondant à l'expression passée en paramètre. L'expression la plus simple consiste à passer une chaîne de caractère : le filtre va alors retenir tout élément du tableau dont une propriété contient la chaîne de caractère en question.

Il devient alors très simple de faire une recherche dans un tableau dans votre application AngularJS.

Supposons que vous ayez un liste de personnes. Au hasard une équipe de ninjas.

    $scope.ninjas = [
      { 'name': 'Agnes', 'superpower': 'Java Champion', 'skills': ['Java', 'JavaEE', 'BDD']},
      { 'name': 'JB', 'superpower': 'Stack Overflow Superstar', 'skills': ['Java', 'Javascript', 'Gradle']},
      { 'name': 'Cyril', 'superpower': 'VAT specialist' /*I'm joking buddy*/, 'skills': ['Java', 'Play!']},
      { 'name': 'Cédric', 'superpower': 'Hype developper', 'skills': ['Java', 'Javascript', 'Git']},
    ];

Maintenant vous voulez les afficher dans un tableau. Facile, un coup de 'ng-repeat' et l'affaire est pliée.

    <tr ng-repeat="ninja in ninjas">
      <td>{{ ninja.name }}</td>
      <td>{{ ninja.superpower }}</td>
      <td>{{ ninja.skills.join(',') }}</td>
    </tr>

Maintenant nous voulons ajouter notre filtre, qui s'utilise comme les autres filtres, sur notre tableau de ninjas. Pour cela nous ajoutons le pipe suivi du filtre 'filter' avec un paramètre nommé search qui contiendra la chaîne de caractère à rechercher dans le tableau (et ne retiendra donc que les ninjas qui satisfont la recherche).

    <tr ng-repeat="ninja in ninjas | filter:search">
      <td>{{ ninja.name }}</td>
      <td>{{ ninja.superpower }}</td>
      <td>{{ ninja.skills.join(',') }}</td>
    </tr>

Nous allons ajouter un input qui aura comme modèle 'search' et rendra donc la recherche dynamique.

    <input ng-model='search' placeholder='filter...'/>

Et voilà! Le tableau est filtré dynamiquement! [Essayez, on vous attend ici!](http://embed.plnkr.co/qgaSkx/)

Il est également de limité la recherche à certaines propriétés de l'objet, en passant un objet au filtre plutôt qu'une chaîne de caractère. Par exemple on peut chercher seulement le nom, en transformant l'input comme suit :

    <input ng-model='search.name' placeholder='filter...'/>

Il est également possible de passer une fonction à évaluer contre chaque élément du tableau plutôt qu'une chaîne de caractère ou un objet.

Enfin, ce filtre peut prendre un deuxième paramètre, pouvant être un booléen indiquant si la recherche doit être sensible à la casse (par défaut, elle ne l'est pas) ou une fonction définissant directement comment comparer l'expression avec les objets du tableau. Si vous voulez une recherche sensible à la casse :

    <tr ng-repeat="ninja in ninjas | filter:search:true">
      <td>{{ ninja.name }}</td>
      <td>{{ ninja.superpower }}</td>
      <td>{{ ninja.skills.join(',') }}</td>
    </tr> 

# Créer vos propres filtres

Il est également possible de créer ses propres filtres et cela peut être parfois très utile. Il existe une fonction pour enregistrer un nouveau filtre dans votre module. Elle se nomme 'filter' et prend comme argument le nom du filtre que vous utiliserez et une fonction. Cette fonction doit renvoyer une fonction prenant comme paramètre les inputs.

Par exemple, nous utilisons souvent la librairie [moment.js](http://momentjs.com/) pour la gestion des dates en Javascript. Nous avons donc créé un filtre 'moment' pour Angular, qui nous permet d'utiliser facilement cette librairie dans nos templates.

    filtersModule.filter('moment', function() {
        return function(input, format) {
            format = format || 'll';
            return moment(input).format(format);
        }
    });

Notre filtre se nomme donc 'moment' et prend 2 paramètres possibles :
- un input, la date à formatter.
- un format, qui est optionnel, et est initialisé à 'll' si il n'est pas défini.

Nous pouvons ensuite utiliser ce filtre dans nos templates :
    
    {{ '2013-10-15' | moment }} // Oct 15 2013
    {{ '2013-10-15' | moment:'LL' }} // October 15 2013

L'input est formaté avec 'll' par défaut ou celui précisé, 'LL' dans le deuxième exemple.

Vous savez tout sur les filtres!

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/09/30/git-config-les-options-indispensables "Article original sur le blog de Cédric Exbrayat")_
{% raw %}