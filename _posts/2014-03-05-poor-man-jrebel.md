---
layout: post
title: The poor man's JRebel
author: [jbnizet]
tags: [java, productivity]
---

*Un développeur*&nbsp;:

>Rhaa, malgré mes tests unitaires, je m'aperçois en testant mon application lightweight full-stack enterprise web 3.0 qu'il y a un bug&nbsp;! 
>
>Il va me falloir un quart d'heure avec Maven pour tout rebuilder et redéployer l'appli dans mon serveur, juste pour corriger deux lignes de code. 
>
>Ah, si seulement mon chef de projet scrum master responsable des achats nous achetait des licences de [JRebel](http://zeroturnaround.com/software/jrebel/), tout irait plus vite.

*Un ninja*&nbsp;:

> Hahaha mon bon Blaze, qu'est-ce que tu perds comme temps&nbsp;! Nous les Ninjas, on est un peu comme Mac Gyver. Juste besoin d'un debugger, et
>on te fabrique un JRebel&nbsp;:
>
> - tu lances ton serveur en debug
> - tu testes ton code de développeur lambda
> - tu t'aperçois qu'il y a un bug, mais c'est pas grave
> - tu corriges ton code et tu mets un *// TODO: ajouter un test unitaire*
> - tu recompiles ton code
> - tu rafraichis la page dans ton navigateur, et voilà. Le nouveau code est rechargé à chaud, et il n'y a pas besoin de tout rebuilder et redéployer.

*Un développeur*&nbsp;:

>Ben oui, avec Eclipse ça le faisait tout seul, mais avec IntelliJ, il compile pas tout seul tant que t'es en debug

*Un ninja*&nbsp;:

>Ctrl-F9 mon bon blase. *Build - Make Project* si tu es un adepte de la souris. Et puis quand IntelliJ te demande s'il faut recharger les classes,
> ben tu dis oui, évidemment.

*Un développeur*&nbsp;:

>Ouais, bon c'est super, mais dès que j'ajoute un champ à ma classe ou que j'ajoute une méthode ou que je change une signature, ça ne marche plus.

*Un ninja*&nbsp;:

>Ouais, bon. En même temps, je t'ai fait un JRebel avec juste un debugger, tu ne peux pas non plus en demander trop. Déjà, si tu utilisais Gradle, t'aurais un build incrémental. Et puis bon, hein, t'as qu'à demander une licence JRebel à ton chef de projet scrum master responsable des achats.

The End.
