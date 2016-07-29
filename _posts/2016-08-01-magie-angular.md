---
layout: post
title: Comment Angular 2 rend vos applications plus performantes, la magie du framework révélée
author: cexbrayat
tags: ["Angular 2", "DOM", "Zone"]
description: "Angular 2 est sorti en beta. Il a été conçu pour apporter beaucoup de choses incroyables en développement web. Regardons de plus près, notamment le mécanisme de changements de modèle, de modification du DOM avec le nouveau concept des zones"
---


Développer avec AngularJS&nbsp;1.X dégageait **un sentiment de "magie"**, et Angular&nbsp;2 procure toujours ce même effet&nbsp;: tu entres une valeur dans un input et hop!, magiquement, toute la page se met à jour en conséquence.

J’adore la magie, mais je préfère comprendre comment fonctionnent les outils que j’utilise. Si tu es comme moi, je pense que cette partie devrait t’intéresser&nbsp;: on va se pencher sur **le fonctionnement interne d’Angular&nbsp;2**&nbsp;!

Mais d’abord, laisse moi t’expliquer comment fonctionne AngularJS&nbsp;1.x, ce qui devrait être intéressant, même si tu n’en as jamais fait.

Tous les frameworks JavaScript fonctionnent d’une façon assez similaire&nbsp;: ils aident le développeur à réagir aux événements de l’application, à mettre à jour son état et à rafraîchir la page (le DOM) en conséquence. Mais ils n’ont pas forcément tous le même moyen d’y parvenir.

[EmberJS](http://emberjs.com/), par exemple, demande aux développeurs d’utiliser des setters sur les objets manipulés pour que le framework puisse "intercepter" l’appel au setter et connaître ainsi les changements appliqués au modèle, et pouvoir modifier le DOM en conséquence. [React](https://facebook.github.io/react/), lui, a opté pour recalculer tout le DOM à chaque changement mais, comme mettre à jour tout le DOM est une opération coûteuse, il fait d’abord ce rendu dans un DOM virtuel, puis n’applique que la différence entre le DOM virtuel et le DOM réel.

Angular, lui, n’utilise pas de setter, ni de DOM virtuel. Alors **comment fait-il pour savoir ce qui doit être mis à jour&nbsp;?**


## AngularJS&nbsp;1.x et le digest cycle

La première étape est donc de détecter une **modification du modèle**. Un changement est forcément déclenché par un événement provenant soit directement de l’utilisateur (par exemple un clic sur un bouton, ou une valeur entrée dans un champ de formulaire) soit par le code applicatif (une réponse HTTP, une exécution de méthode asynchrone après un timeout, etc…​).

Comment fait donc le framework pour savoir qu’un événement est survenu&nbsp;? Et bien c’est simple, il nous force à utiliser ses directives, par exemple *ng-click* pour surveiller un clic, ou *ng-model* pour surveiller un input, et ses services, par exemple *$http* pour les appels HTTP ou *$timeout* pour exécuter du code asynchrone.

Le fait d’utiliser ses directives et services permet au framework d’être parfaitement informé du fait qu’un événement vient de se produire. C’est ça la première partie de la magie&nbsp;! Et c’est cette première partie qui va déclencher la seconde&nbsp;: il faut maintenant que le framework analyse le changement qui vient de survenir, et puisse déterminer quelle partie du DOM doit être mise à jour.

Pour cela, en version 1.x, le framework maintient une liste de *watchers* (des observateurs) qui représente la liste de ce qu’il doit surveiller. Pour simplifier, un *watcher* est créé pour chaque expression dynamique utilisée dans un template. Il y a donc un *watcher* pour chaque petit bout dynamique de l’application, et on peut donc avoir facilement plusieurs centaines de *watchers* dans une page.

Ensuite, à chaque fois que le framework détecte un changement, il déclenche ce que l’on appelle le *digest* (la digestion).

Ce *digest* évalue alors toutes les expressions stockées dans les *watchers* et compare leur nouvelle valeur avec leur ancienne valeur. Si un changement est constaté entre la nouvelle valeur d’une expression et son ancienne valeur, alors le framework sait que l’expression en question doit être remplacée par sa nouvelle valeur dans le DOM pour refléter ce changement. Cette technique est ce que l’on appelle du *dirty checking*.

<p style="text-align: center;">
<img itemprop="image" class="img-responsive" src="/assets/images/2016-08-01/digest.png" alt="schema digest AngularJS 1.x" />
</p>

Pendant ce digest, AngularJS parcourt toute la liste des *watchers*, et évalue chacun d’eux pour connaître la nouvelle valeur de l’expression surveillée. Avec une subtilité de taille&nbsp;: ce cycle va être effectué dans son intégralité tant que les résultats de tous les *watchers* ne sont pas stables, c’est à dire tant que la dernière valeur calculée n’est pas la même que la nouvelle valeur. Car bien sûr, dans une vraie application, le résultat d’une expression, donc d’un *watcher*, déclenche parfois un callback qui va lui-même modifier à nouveau le modèle et donc changer la valeur d’une ou plusieurs expressions surveillées&nbsp;!

Prenons un exemple minimaliste&nbsp;: une page avec deux champs à remplir par l’utilisateur, son nom et son mot de passe, et un indice de robustesse du mot de passe qui surveille le mot de passe, recalculé à chaque fois que celui-ci change.

Nous avons alors cette liste de *watchers* après leur première évaluation, lorsque l’utilisateur a saisi le premier caractère de son mot de passe&nbsp;:

    $$watchers (expression -> value)
    - "user.name" -> "Cédric"
    - "user.password" -> "h"
    - "passwordStrength" -> 2

Le cycle va être effectué une seconde fois pour voir si les résultats sont stables, car certains résultats dépendent peut-être d’une autre expression.

    $$watchers
    - "user.name" -> "Cédric"
    - "user.password" -> "h"
    - "passwordStrength" -> 3

C’est le cas&nbsp;: la force du mot de passe dépend de la valeur de celui-ci. Comme les résultats ne sont pas encore stables (une valeur ayant changé entre les deux cycles), le cycle est une nouvelle fois évalué en entier.

    $$watchers
    - "user.name" -> "Cédric"
    - "user.password" -> "h"
    - "passwordStrength" -> 3

Cette fois, c’est stable. C’est seulement à ce moment-là qu’AngularJS&nbsp;1.x applique les résultats sur le DOM. Cette boucle de digest est donc jouée au moins 2 fois à chaque changement dans l’application. Elle peut être jouée jusqu’à 10 fois mais pas plus&nbsp;: après 10 cycles, si les résultats ne sont toujours pas stables, le framework considère qu’il y a une boucle infinie et lance une exception.

Donc mon schéma précédent ressemble en fait plus à&nbsp;:

<p style="text-align: center;">
<img itemprop="image" class="img-responsive" src="/assets/images/2016-08-01/digest-2.png" alt="schema digest AngularJS 1.x détaillé" />
</p>

Et j’insiste&nbsp;: c’est ce qui se passe après chaque événement de notre application. Cela veut dire que si l’utilisateur entre 5 caractères dans un champ, le digest sera lancé 5 fois, avec 3 boucles à chaque fois dans notre petit exemple, soit 15 boucles d’exécution. Dans une application réelle, on peut avoir facilement plusieurs centaines de *watchers* et donc plusieurs milliers d’évaluation d’expression à chaque changement.

Même si ça semble fou, cela marche très bien car les navigateurs modernes sont vraiment rapides, et qu’il est possible d’optimiser deux ou trois choses si nécessaire.

Tout cela signifie deux choses pour AngularJS&nbsp;1.x&nbsp;:

- il faut utiliser les services et les directives du framework pour tout ce qui peut déclencher un changement&nbsp;;

- modifier le modèle à la suite d’un événement non géré par Angular nous oblige à déclencher nous-même le mécanisme de détection de changement (en ajoutant le fameux `$scope.$apply()` qui lance le digest). Par exemple, si l’on veut faire une requête HTTP sans utiliser le service $http, il faut appeler `$scope.$apply()` dans notre callback de réponse pour dire au framework : "Hé, j’ai des nouvelles données, lance le digest s’il te plaît&nbsp;!".


Et la magie du framework peut être scindée en deux parties&nbsp;:

- le déclenchement de la détection de changement à chaque événement&nbsp;;

- la détection de changement elle-même, grâce au digest, et à ses multiples cycles.


Maintenant voyons comment Angular&nbsp;2 fonctionne, et quelle est la différence.


## Angular&nbsp;2 et les zones

Angular&nbsp;2 conserve les mêmes principes, **mais les implémente d’une façon différente**, et on pourrait même dire, plus intelligente.

Pour la première partie du problème —&nbsp;le déclenchement de la détection de changement&nbsp;— l’équipe Angular a construit un petit projet annexe appelé *[Zone.js](https://github.com/angular/zone.js/)*. Ce projet n’est pas forcément lié à Angular, car les zones sont un outil qui peut être utilisé dans d’autres projets. Les zones ne sont pas vraiment un nouveau concept&nbsp;: elles existent dans [le language Dart](https://www.dartlang.org/) (un autre projet Google) depuis quelques temps déjà. Elles ont aussi quelques similarités avec [les Domains de Node.js](https://nodejs.org/api/domain.html#domain_domain) (abandonnés depuis) ou [les ThreadLocal](https://docs.oracle.com/javase/8/docs/api/java/lang/ThreadLocal.html) en Java.

Mais c’est probablement la première fois que l’on voit les Zones en JavaScript&nbsp;: pas d’inquiétude, on va les découvrir ensemble.

## Zones
Une zone est un contexte d’exécution. Ce contexte va recevoir du code à exécuter, et ce code peut être synchrone ou asynchrone.

Une zone va nous apporter quelques petits bonus :

- une façon d’exécuter du code avant et après le code reçu à exécuter&nbsp;;

- une façon d’intercepter les erreurs éventuelles d’exécution du code reçu&nbsp;;

- une façon de stocker des variables locales à ce contexte.

Prenons un exemple. Si j’ai du code dans une application qui ressemble à&nbsp;:

    // calcul du score -> synchrone
    let score = computeScore();
    // mettre à jour le joueur avec son nouveau score -> synchrone
    updatePlayer(player, score);

Quand on exécute ce code, on obtient :

    computeScore: new score: 1000
    udpatePlayer: player 1 has 1000 points

Admettons que je veuille savoir combien de temps prend un tel code. Je peux faire quelque chose comme ça&nbsp;:

    startTimer();
    let score = computeScore();
    updatePlayer(player, score);
    stopTimer();

Et cela produirait ce résultat&nbsp;:

    start
    computeScore: new score: 1000
    udpatePlayer: player 1 has 1000 points
    stop: 12ms

Facile. Mais maintenant, que se passe-t-il si `updatePlayer` est une fonction asynchrone&nbsp;? JavaScript fonctionne de façon assez particulière&nbsp;: les opérations asynchrones sont placées à la fin de la queue d’exécution, et seront donc exécutées après les opérations synchrones.

Donc cette fois mon code précédent&nbsp;:

    startTimer();
    let score = computeScore();
    updatePlayer(player, score); // asynchrone
    stopTimer();

va en fait donner&nbsp;:

    start
    computeScore: new score: 1000
    stop: 5ms
    udpatePlayer: player 1 has 1000 points

Mon temps d’exécution n’est plus bon du tout, vu qu’il ne mesure que le code synchrone&nbsp;! Et c’est par exemple là que les zones peuvent être utiles. On va lancer le code en question en utilisant zone.js pour l’exécuter dans une zone&nbsp;:

    let scoreZone = zone.fork();
    scoreZone.run(() => {
        let score = computeScore();
        updatePlayer(player, score); // asynchrone
    });

Pourquoi est-ce que cela nous aide dans notre cas&nbsp;? Hé bien, si la librairie zone.js est chargée dans notre navigateur, elle va commencer par patcher toutes les méthodes asynchrones de celui-ci. Donc à chaque fois que l’on fera un `setTimeout()`, un `setInterval()`, que l’on utilisera une API asynchrone comme les `Promises`, `XMLHttpRequest`, `WebSocket`, `FileReader`, `GeoLocation`…​ on appellera en fait la version patchée de zone.js. Zone.js connaît alors exactement quand le code asynchrone est terminé, et permet aux développeurs comme nous d’exécuter du code à ce moment là, par le biais d’un hook.

Une zone offre plusieurs hooks possibles :

- `beforeTask` qui sera appelé avant l’exécution du code encapsulé dans la zone&nbsp;;

- `afterTask` qui sera appelé après l’exécution du code encapsulé dans la zone&nbsp;;

- `onError` qui sera appelé dès que l’exécution du code encapsulé dans la zone lance une erreur&nbsp;;

- `onZoneCreated` qui sera appelé à la création de la zone.

On peut donc utiliser une zone et ses hooks pour mesurer le temps d’exécution de mon code asynchrone&nbsp;:

    let scoreZone = zone.fork({
        beforeTask: startTimer,
        afterTask: stopTimer
    });
    scoreZone.run(() => {
        let score = computeScore();
        updatePlayer(player, score);
    });

Et cette fois-ci ça marche&nbsp;!

    start
    computeScore: new score: 1000
    udpatePlayer: player 1 has 1000 points
    stop: 12ms

Vous voyez maintenant peut-être le lien qu’il peut y avoir avec Angular&nbsp;2. En effet, le premier problème du framework est de savoir quand la détection de changement doit être lancée. En utilisant les zones, et en faisant tourner le code que nous écrivons dans une zone, le framework a une très bonne vue de ce qu’il est en train de se passer. Il est ainsi capable de gérer les erreurs assez finement, mais surtout de lancer la détection de changement dès qu’un appel asynchrone est terminé !

Pour simplifier, Angular&nbsp;2 fait quelque chose comme&nbsp;:

    let scoreZone = zone.fork({
        afterTask: triggerChangeDetection
    });
    scoreZone.run(() => {
        // your application code
    });

Et **le premier problème est ainsi résolu&nbsp;!** C’est pour cela qu’en Angular&nbsp;2, contrairement à AngularJS&nbsp;1.x, il n’est pas nécessaire d’utiliser des services spéciaux pour profiter de la détection de changements. Vous pouvez utiliser ce que vous voulez, les zones se chargeront du reste&nbsp;!

A noter que **les zones sont en voie de standardisation**, et pourraient faire partie de la spécification officielle ECMAScript dans un futur proche. Autre information intéressante, l’implémentation actuelle de zone.js embarque également des informations pour WTF (qui ne veut pas dire What The Fuck ici, mais Web Tracing Framework). Cette librairie permet de profiler votre application en mode développement, et de savoir exactement quel temps a été passé dans chaque partie de votre application et du framework. Bref, plein d’outils pour analyser les performances si besoin&nbsp;!

## La détection de changement en Angular&nbsp;2
La seconde partie du problème est la détection de changement en elle-même. C’est bien beau de savoir quand on doit la lancer, mais comment fonctionne-t-elle&nbsp;?

Tout d’abord, il faut se rappeler qu’une application Angular&nbsp;2 est un arbre de composants. Lorsque la détection de changement se lance, le framework va parcourir l’arbre de ces composants pour voir si les composants ont subi des changements qui impactent leurs templates. Si c’est le cas, le DOM du composant en question sera mis à jour (seulement la petite portion impactée par le changement, pas le composant en entier). Ce parcours d’arbre se fait de la racine vers les enfants, et contrairement à AngularJS&nbsp;1.x, il ne se fait qu’une seule fois. **Car il y a maintenant une grande différence** : la détection de changement en Angular&nbsp;2 ne change pas le modèle de l’application, là où un watcher en AngularJS&nbsp;1.x pouvait changer le modèle lors de cette phase. Et en Angular&nbsp;2, un composant ne peut maintenant modifier que le modèle de ses composants enfants et pas de son parent. **Finis les changements de modèle en cascade&nbsp;!**

La détection de changement est donc seulement là pour vérifier les changements et modifier le DOM en conséquence. Il n’y a plus besoin de faire plusieurs passages comme c’était le cas dans la version 1.x, puisque le modèle n’aura pas changé&nbsp;!

Pour être tout à fait exact, ce parcours se fait deux fois lorsque l’on est en mode développement pour vérifier qu’il n’y a pas d’effet de bords indésirables (par exemple un composant enfant modifiant le modèle utilisé par son composant parent). Si le second passage détecte un changement, une exception est lancée pour avertir le développeur.

Ce fonctionnement a plusieurs avantages&nbsp;:

- il est plus facile de raisonner sur nos applications, car on ne peut plus avoir de cas où un composant parent passe des informations à un composant enfant qui lui aussi passe des informations à son parent. Maintenant les données sont transmises dans un seul sens&nbsp;;

- la détection de changement ne peut plus avoir de boucle infinie&nbsp;;

- la détection de changement est bien plus rapide.

Sur ce dernier point, c’est assez simple à visualiser&nbsp;: là où précédemment la version effectuait **(M watchers) * (N cycles)** vérifications, la version 2 ne fait plus que **M vérifications**.

Mais un autre paramètre entre en compte dans l’amélioration des performances d’Angular&nbsp;2&nbsp;: le temps qu’il faut au framework pour faire cette vérification. Là encore, l’équipe de Google fait parler sa connaissance profonde des sciences informatiques et des machines virtuelles.

Pour cela, il faut se pencher sur la façon dont sont comparées deux valeurs en AngularJS&nbsp;1.x et en Angular&nbsp;2. Dans la version 1.x, le mécanisme est très générique : il y a une méthode dans le framework qui est appelée pour chaque watcher et qui est capable de comparer l’ancienne valeur et la nouvelle. Seulement, les machines virtuelles, comme celle qui exécute le code JavaScript dans notre navigateur (V8 si tu utilises Google Chrome par exemple), n’aiment pas vraiment le code générique.

Et si tu le permets, je vais faire une petite parenthèse sur le fonctionnement des machines virtuelles. Avoue que tu ne t’y attendais pas dans un article sur un framework JavaScript ! Les machines virtuelles sont des programmes assez extraordinaires : on leur donne un bout de code et elles sont capables de l’exécuter sur n’importe quelle machine. Vu que peu d’entres nous (certainement pas moi) sont capables de produire du code machine performant, c’est quand même assez pratique. On code avec notre language de haut niveau, et on laisse la VM se préoccuper du reste. Evidemment, les VMs ne se contentent pas de traduire le code, elles vont aussi chercher à l’optimiser. Et elles sont plutôt fortes à ce jeu là, à tel point que les meilleures VMs ont des performances aussi bonnes que du code machine optimisé (voire bien meilleures, car elle peuvent profiter d’informations au runtime, qu’il est plus difficile voire impossible de connaître à l’avance quand on fait l’optimisation à la compilation).

Pour améliorer les performances, les machines virtuelles, notamment celles qui font tourner des languages dynamiques comme JavaScript, utilisent un concept nommé inline caching. C’est une technique très ancienne (inventée pour SmallTalk je crois, soit près de 40 ans, une éternité en informatique), pour un principe finalement assez simple : si un programme appelle une méthode beaucoup de fois avec le même type d’objet, la VM devrait se rappeler de quelle façon elle évalue les propriétés des objets en question. Il y a donc un cache qui est créé, d’où le nom, inline caching. La VM commence donc par regarder dans le cache si elle connaît le type d’objet qu’elle reçoit, et si c’est le cas, utilise la méthode optimisée de chargement.

Ce genre de cache ne fonctionne vraiment que si les arguments de la méthode ont la même forme. Par exemple `{name: 'Cédric'}` et `{name: 'Cyril'}` ont la même forme. Par contre `{name: 'JB', skills: []}` n’a pas la même forme. Lorsque les arguments ont toujours la même forme, on dit que le cache est **monomorphique**, un bien grand mot pour dire qu’il n’a qu’une seule entrée, ce qui donne des résultats très rapides. Si il a quelques entrées, on dit qu’il est polymorphique, cela veut dire que la méthode peut être appelée avec des types d’objets différents, et le code est un peu plus lent. Enfin, il arrive que la VM laisse tomber le cache si il y a trop de types d’objet différents, c’est ce qu’on appelle un état mégamorphique. Et tu l’as compris, c’est le cas le moins performant.

Si j’en reviens à notre détection de changement en AngularJS&nbsp;1.x, on comprend vite que la méthode générique utilisée n’est pas optimisable par la machine virtuelle : on est dans un état mégamorphique, là où le code est le plus lent. Et même si les navigateurs et machines modernes permettent de faire plusieurs milliers de vérification de watchers par seconde, on pouvait quand même atteindre les limites.

D’où l’idée de faire un peu différemment en Angular&nbsp;2&nbsp;! Cette fois, plutôt qu’avoir une seule méthode capable de comparer tous les types d’objet, l’équipe Google a pris le parti de générer dynamiquement des comparateurs pour chaque type. Cela veut dire qu’au démarrage de l’application, le framework va parcourir l’arbre des composants et générer un arbre de ChangeDetectors spécifiques.

Par exemple, pour un composant User avec un champ name affiché dans le template, on aura un ChangeDetector qui ressemble à&nbsp;:

    class User_ChangeDetector {
          detectChanges() {
            if (this.name !== this.previousName) {
                  this.previousName = this.name;
                  isChanged = true;
            }
          }
    }

Un peu comme si on avait écrit le code de comparaison à la main. Ce code est du coup très rapide (monomorphique si vous suivez), permet de savoir si le composant a changé, et donc de mettre à jour le DOM en conséquence.

**Donc non seulement Angular&nbsp;2 fait moins de comparaison que la version 1.x (une seule passe suffit) mais en plus ces comparaisons sont beaucoup plus rapides&nbsp;!**

Depuis le début, l’équipe Google surveille d’ailleurs les performances, avec des benchmarks entre AngularJS&nbsp;1.x, Angular&nbsp;2 et même React sur des cas d’utilisation un peu tordus afin de voir si la nouvelle version est toujours la plus rapide. Il est même possible d’aller encore plus loin, puisque la stratégie de ChangeDetection peut même être modifiée de sa valeur par défaut, et être encore plus rapide dans certains cas. Mais ça c’est pour une autre fois !

*Cet article a été rédigé pour le numéro 196 du magazine Programmez. Il a été publi en mai 2016*


