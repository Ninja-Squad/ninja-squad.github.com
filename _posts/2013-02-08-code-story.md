---
layout: post
title: Les sélections de Code Story 2013
author: [clacote]
tags: [codestory, concours]
---

<img src="/assets/images/codestory.png" width="50%" style="float:right; margin-left:20px; margin-bottom:10px;" alt="Code Story" title="Code Story">

Le 4 janvier commençait la phase de sélection de [Code Story](http://code-story.net/ "Site de Code Story") 2013, organisé depuis déjà deux ans par [David Gageot](http://code-story.net/about/david.html) et [Jean-Laurent de Morlhon](http://code-story.net/about/jean-laurent.html).

Cette première phase s'est terminée le 31 janvier. Trois de nos ninjas y participaient&nbsp;: deux à découverts, un sous l'anonymat d'un pseudonyme (pour le seul plaisir de l'algorithmie, parce qu'il considérait avoir triché en recopiant l'infrastructure et les tests unitaires d'un des premiers).

Pourquoi on vous en parle maintenant que l'épreuve ouverte à tous est terminée?

Certainement parce qu'on est trop bêtes de ne pas avoir pris le temps de vous en parler avant. Si on se cherchait des excuses, on pourrait vous dire qu'on était tout entier consacrés à la satisfaction de nos clients le jour, et à Code Story lui-même la nuit.

Probablement aussi pour se faire mousser un peu : les trois ninjas ont tous été sélectionnés à l'issue de cette phase, [atteignant le score maximal](http://code-story.net/2013/02/01/concours-2013-phase-1.html). Et on est quand même pas peu fier d'y être arrivé. Bon moi je dois quand même avouer avoir bien peiné à atteindre l'algorithme optimal sur [la location d'astronef Jajascript](http://code-story.net/2013/02/02/jajascript.html) permettant de répondre aux performances maximales (trouver le planning optimal parmis 50000 vols).


<p style="text-align:center;">
  <img class="img-polaroid" src="/assets/images/carlton.gif" alt="La victoire des ninjas" />
</p>
<br/>

Mais surtout parce que ce concours était formidable, sur la forme comme dans le fond.

La forme était surprenante&nbsp;: on ne connaissait pas les questions à l'avance. Elles nous étaient posées sous forme de requête HTTP à un serveur web à implémenter, dont on indiquait le domaine lors de l'inscription. Chaque question était répétée indéfiniment tant que l'on n'y répondait pas correctement. On découvrait alors la question suivante, qui était soit un prolongement de l'exercice en cours (plus compliquée, plus de volume, plus de précision), soit nous dirigeait vers un autre exercice.  
Si certains se sont arrachés les cheveux sur ce protocole qui poussait toujours plus loin les exigences, sans nous laisser l'opportunité de nous y préparer dès le départ, je la trouvais très féconde et pertinente : elle poussait naturellement au refactoring constant, pour améliorer son implémentation. Inutile de préciser combien des tests unitaires solides permettaient d'assurer ou limiter les régressions. Du développement agile.

Dans le fond, les exercices permettaient de bien éprouver (ou dérouiller) ses capacités algorithmiques. Les deux principaux [sont](http://code-story.net/2013/01/22/scalaskel.html "Exercice Code Story 2013 : L'échoppe de monade sur Scalaskel") [décrits](http://code-story.net/2013/02/02/jajascript.html "Exercice Code Story 2013 : Location d’astronef sur Jajascript") sur le site de Code Story. Un autre demandait d'implémenter une calculatrice, sachant par exemple résoudre `((1,1+2)+3,14+4+(5+6+7)+(8+9+10)*4267387833344334647677634)/2*553344300034334349999000`.  
Et cela fait du bien, en tout cas pour nous qui baignons dans l'informatique de gestion, où les besoins en pure algorithmie sont finalement bien peu importants.

Certains participants utilisaient aussi ce concours comme un prétexte pour s'essayer à différents langages ou infrastructures. Notre [Jean-Baptiste Nizet](http://ninja-squad.com/team#JB "Jean-Baptiste Nizet sur le site de Ninja Squad") a par exemple réimplémenté manuellement son serveur HTTP, de la `socket` au `body` : voici [son code sur GitHub](https://github.com/jnizet/CodeStory2013 "Code de Jean-Baptiste Nizet pour Code Story 2013"). Et si jeter un oeil au code vous intéresse, vous pouvez retrouver [le mien](https://github.com/clacote/CodeStory2013 "Code de Cyril Lacôte pour Code Story 2013").  
On peut quand même s'émerveiller des incroyables outils à notre disposition aujourd'hui, avec lesquels on peut, dans le langage de son choix, obtenir en trois clics un serveur gratuit dans le cloud, avec intégration continue à chaque commit (merci [GitHub](http://github.com), [Travis](https://travis-ci.org/), [Heroku](http://www.heroku.com/) et [CloudBees](http://www.cloudbees.com/), pour ne citer que ceux que nous avons utilisés).

La phase suivante se déroulera le 21 février : les sélectionnés s'affronteront en live dans les locaux de Google. Nous avons finalement convenu, avec regret, qu'il n'était pas raisonnable de faire le déplacement, avec nos plannings actuels.  

On souhaite bonne chance à tous les participants, et on félicite David et Jean-Laurent pour cette formidable épreuve! Nous les retrouverons dans les couloirs de [Devoxx France](http://www.devoxx.fr).

Quant à vous, lecteur, on ne peut que vous encourager, l'année prochaine, à ne pas rater la prochaine édition.


<p align="center">
  <a href="http://www.youtube.com/watch?v=8FMFxaT-n7U">On IrA ToUs à CoDeStOrY, MêMe tOi!</a>
</p>
<br/>
