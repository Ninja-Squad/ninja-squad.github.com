---
layout: post
title: Angular 2 - Les Types, comme dans TypeScript
author: cexbrayat
tags: ["Angular 2", "ES6", "TypeScript"]
description: "Angular 2 est sorti en beta. Il a été conçu pour apporter beaucoup de choses incroyables en développement web, comme TypeScript. Regardons de plus près!"
---

Cette semaine au lieu d'un Ninja Tip, nous te proposons un article sur TypeScript, extrait de [notre ebook sur Angular&nbsp;2](https://books.ninja-squad.com/angular2) et traduction en français d'[un précédent post](/2015/11/03/types/).

Tu sais probablement que les applications Angular&nbsp;2 peuvent être écrites en ES5, ES6 (voir [nos posts](/tags.html#ES6-ref) à ce propos), ou TypeScript. Et tu te demandes peut-être qu'est-ce que TypeScript, et ce qu'il apporte de plus.

JavaScript est dynamiquement typé. Tu peux donc faire des trucs comme&nbsp;:

    let pony = 'Rainbow Dash';
    pony = 2;

Et ça fonctionne. Ça offre pleins de possibilités&nbsp;: tu peux ainsi passer n'importe quel objet à une fonction, tant que cet objet a les propriétés requises par la fonction&nbsp;:

    let pony = { name: 'Rainbow Dash', color: 'blue' };
    let horse = { speed: 40, color: 'black' };
    let printColor = animal => console.log(animal.color);

Cette nature dynamique est formidable, mais elle est aussi un handicap dans certains cas, comparée à d'autres langages plus fortement typés. Le cas le plus évident est quand tu dois appeler une fonction inconnue d'une autre API en JS&nbsp;: tu dois lire la documentation (ou pire le code de la fonction) pour deviner à quoi doivent ressembler les paramètres. Dans notre exemple précédent, la méthode `printColor` attend un paramètre avec une propriété `color`, mais encore faut-il le savoir. Et c'est encore plus difficile dans notre travail quotidien, où on multiplie les utilisations de bibliothèques et services développés par d'autres.

Un des co-fondateurs de Ninja Squad se plaint souvent du manque de type en JS, et déclare qu'il n'est pas aussi productif, et qu'il ne produit pas du code aussi bon qu'il le ferait dans un environnement plus statiquement typé. Et il n'a pas entièrement tort, même s'il trolle aussi par plaisir&nbsp;! Sans les informations de type, les IDEs n'ont aucun indice pour savoir si tu écris quelque chose de faux, et les outils ne peuvent pas t'aider à trouver des bugs dans ton code. Bien sûr, nos applications sont testées, et Angular a toujours facilité les tests, mais c'est pratiquement impossible d'avoir une parfaite couverture de tests.

Cela nous amène au sujet de la maintenabilité. Le code JS peut être difficile à maintenir, malgré les tests et la documentation. Refactoriser une grosse application JS n'est pas chose aisée, comparativement à ce qui peut être fait dans des langages statiquement typés. La maintenabilité est un sujet important, et les types aident les outils comme les développeurs à éviter les erreurs lors de l'écriture et la modification de code. Google a toujours été enclin à proposer des solutions dans cette direction&nbsp;: c'est compréhensible, étant donné qu'ils gèrent des applications parmi les plus grosses du monde, avec GMail, Google apps, Maps... Alors ils ont essayé plusieurs approches pour améliorer la maintenablité des applications _front-end_&nbsp;: GWT, Google Closure, Dart... Elles devaient toutes faciliter l'écriture de grosses applications web.

Avec Angular&nbsp;2, l'équipe Google voulait nous aider à écrire du meilleur JS, en ajoutant des informations de type à notre code. Ce n'est pas un concept nouveau pour JS, c'était même le sujet de la spécification ECMASCRIPT&nbsp;4, qui a été abandonnée. Au départ ils annoncèrent AtScript, un sur-ensemble d'ES6 avec des annotations (des annotations de type et d'autres). Ils annoncèrent ensuite le support de TypeScript, le langage de Microsoft, avec des annotations de type additionnelles. Et enfin, quelques mois plus tard, l'équipe TypeScript annonçait, après un travail étroit avec l'équipe de Google, que la nouvelle version du langage (1.5) aurait toutes les nouvelles fonctionnalités d'AtScript. L'équipe Angular déclara alors qu'AtScript était officiellement abandonné, et que TypeScript était désormais la meilleure façon d'écrire des applications Angular&nbsp;2&nbsp;!

# Hello TypeScript

Je pense que c'était la meilleure chose à faire pour plusieurs raisons. D'abord, personne n'a vraiment envie d'apprendre une nouvelle extension de langage. Et TypeScript existait déjà, avec une communauté et un écosystème actifs. Je ne l'avais jamais vraiment utilisé avant Angular&nbsp;2, mais j'en avais entendu du bien, de personnes différentes. TypeScript est un projet de Microsoft, mais ce n'est pas le Microsoft de l'ère Ballmer et Gates. C'est le Microsoft de Nadella, celui qui s'ouvre à la communauté, et donc, à l'open-source. Google en a conscience, et c'est tout à leur avantage de contribuer à un projet existant, plutôt que de maintenir le leur. Le framework TypeScript gagnera de son côté en visibilité&nbsp;: _win-win_ comme dirait ton manager.

Mais la raison principale de parier sur TypeScript est le système de types qu'il offre. C'est un système optionnel qui vient t'aider sans t'entraver. De fait, après avoir codé quelque temps avec, il s'est fait complètement oublier&nbsp;: tu peux faire des applications Angular&nbsp;2 en utilisant les trucs de TypeScript les plus utiles et en ignorant tout le reste avec du pur JavaScript (ES6 dans mon cas).

Si tu te demandes "mais pourquoi avoir du code fortement typé dans une application Angular&nbsp;2&nbsp;?", prenons un exemple. Angular 1 et 2 ont été construits sur le puissant concept d'injection de dépendance. Tu le connais déjà peut-être, parce que c'est un _design pattern_ classique, utilisé dans beaucoup de frameworks et langages, et notamment AngularJS&nbsp;1.x comme je le disais.

# Un exemple concret d'injection de dépendance

Pour synthétiser ce qu'est l'injection de dépendance, prenons un composant d'une application, disons `RaceList`, permettant d'accéder à la liste des courses que le service `RaceService` peut retourner. Tu peux écrire `RaceList` comme ça&nbsp;:

    class RaceList {
      constructor() {
        this.raceService = new RaceService();
        // let's say that list() returns a promise
        this.raceService.list()
        // we store the races returned into a member of `RaceList`
          .then(races => this.races = races);
          // arrow functions, FTW!
      }
    }

Mais ce code a plusieurs défauts. L'un d'eux est la testabilité&nbsp;: c'est compliqué de remplacer `raceService` par un faux service (un bouchon, un _mock_), pour tester notre composant.

Si nous utilisons le _pattern_ d'injection de dépendance (_Dependency Injection_, DI), nous déléguons la création de `RaceService` à un framework, lui réclamant simplement une instance. Le framework est ainsi en charge de la création de la dépendance, et il peut nous "l'injecter", par exemple dans le constructeur&nbsp;:

    class RaceList {
      constructor(raceService) {
        this.raceService = raceService;
        this.raceService.list()
          .then(races => this.races = races);
      }
    }

Désormais, quand on teste cette classe, on peut facilement passer un faux service au constructeur&nbsp;:

    let fakeService = {
      list: () => {
        // returns a fake promise
      }
    };
    let raceList = new RaceList(fakeService);
    // now we are sure that the race list
    // is the one we want for the test

Mais comment le framework sait-il quel composant injecter dans le constructeur&nbsp;? Bonne question&nbsp;! AngularJS&nbsp;1.x se basait sur le nom du paramètre, mais cela a une sérieuse limitation&nbsp;: la minification du code va changer le nom du paramètre. Pour contourner ce problème, tu pouvais utiliser la notation à base de tableau, ou ajouter des métadonnées à la classe&nbsp;:

    RaceList.$inject = ['RaceService'];

Il nous fallait donc ajouter des métadonnées pour que le framework comprenne ce qu'il fallait injecter dans nos classes. Et c'est exactement ce que proposent les annotations de type&nbsp;: une métadonnée donnant un indice nécessaire au framework pour réaliser la bonne injection. En Angular&nbsp;2, avec TypeScript, voilà à quoi pourrait ressembler notre composant `RaceList`&nbsp;:

    class RaceList {
      raceService: RaceService;
      races: Array<string>;

      constructor(raceService: RaceService) {
        // the interesting part is `: RaceService`
        this.raceService = raceService;
        this.raceService.list()
          .then(races => this.races = races);
      }
    }

Maintenant l'injection peut se faire sans ambiguité&nbsp;! Tu n'es pas obligé d'utiliser TypeScript en Angular&nbsp;2, mais clairement ton code sera plus élégant avec. Tu peux toujours faire la même chose en pur ES6 ou ES5, mais tu devras ajouter manuellement des métadonnées d'une autre façon.

Angular&nbsp;2 est clairement construit pour tirer parti d'ES6 et TS 1.5+, et rendre notre vie de développeur plus facile en l'utilisant. Et l'équipe Angular a envie de soumettre le système de type au comité de standardisation, donc peut-être qu'un jour il sera normal d'avoir de vrais types en JS.

Voici donc un des chapitres de [notre ebook sur Angular&nbsp;2](https://books.ninja-squad.com/angular2), si celui-là vous a plu, n'hésitez pas à lire les autres&nbsp;!
