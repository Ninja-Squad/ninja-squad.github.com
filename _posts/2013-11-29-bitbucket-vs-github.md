---
layout: post
title: Bitbucket vs Github
author: cexbrayat
tags: [git, github, bitbucket]
canonical: http://hypedrivendev.wordpress.com/2013/11/29/bitbucket-vs-github/
---

Vous savez peut-être que [Bitbucket](https://bitbucket.org) vous permet depuis fin 2011 d'héberger vos projets Git, comme [Github](http://github.com), après avoir été un temple de Mercurial. Est-ce pour autant une bonne alternative ? Passons en revue leurs particularités !

<h1>Repository</h1>

Les interfaces du site sont extrêmement similaires, même si les designers de Github sont probablement légèrement meilleurs.

Chacun permet de créer des repositories publics et privés (mais pratique des prix différents, voir plus bas). Une fois le repository créé, on obtient une URL de remote, sur laquelle il est possible de pousser du code.

La navigation dans les sources se fait de façon identique sur le site, en parcourant les répertoires ou en utilisant les raccourcis claviers (par exemple `t` pour rechercher un fichier dans Github et `f` dans Bitbucket). Une fois le fichier trouvé, il est possible de le visionner, de faire un `blame`, de voir son historique ou de le modifier depuis le navigateur dans les deux cas.

Il est également possible de voir l'activité du projet, et les deux concurrents utilisent le fichier README de façon similaire pour décrire le projet.

L'historique des commits est un peu plus fonctionnel dans Bitbucket avec l'affichage possible de toutes les branches. La visualisation des branches est aussi intéressante, plus graphique que celle proposée par Github.

<h1>Fork/Pull Request/Code review</h1>

On trouve également le même mécanisme de fork (copie d'un repository dans votre espace utilisateur sur lequel vous avez tous les droits), de pull requests (demande d'intégration d'une fonctionnalité que vous avez codé dans un repo qui ne vous appartient pas) et de code reviews (possibilité de voir les différences introduites et de commenter le code).

Bitbucket ajoute quelques features "nice to have" : il est possible d'afficher un diff avec le fichier dans son ancienne version et dans sa nouvelle version côte à côte, d'[affecter les code reviews](http://blog.bitbucket.org/2013/02/25/pull-requests-now-with-reviewers-and-smarter-notifications/
) à certains collaborateurs pour approbation et de ne pouvoir merger que si la pull request a été approuvée un certain nombre de fois. Ce petit workflow d'intégration n'est pas sans intérêt, même s'il est souvent pratiqué informellement sur Github. Autre petit avantage : lorsqu'une pull request ne peut être mergée pour cause de conflit, Bitbucket affiche clairement quels sont les fichiers et lignes en cause.

<h1>Administration</h1>

Peu de différence là encore : possibilité de créer des équipes et de leur affecter certains droits sur un repository. Bitbucket innove avec la possibilité de donner certains [droits sur une branche spécifique](http://blog.bitbucket.org/2013/09/16/take-control-with-branch-restrictions/)

<h1>Bug tracking</h1>

Chacun des concurrents propose un bug tracker intégré. Les fonctionnalités sont à peu près identiques :

- création d'anomalie avec assignation possible et version cible de correction.
- description au format markdown, avec images jointes.
- recherche des anomalies.
- lien possible entre anomalies (mais pas d'autocomplétion sur Bitbucket...).
- surveiller les anomalies.
- résolution automatique par commit.

Bitbucket propose en plus une criticité, une priorité et une gestion du workflow intégrée alors que Github compense en permettant la création dynamique de labels comme vous l'entendez. Le système de Github est flexible mais demande un peu plus de travail.

Une autre fonctionnalité intéressante réside dans le [vote sur les issues](http://blog.bitbucket.org/2013/08/14/no-more-1s-bitbucket-issues-now-has-voting/). Là où Github ne permet toujours pas de voter, et où les commentaires '+1' sont le seul moyen de manifester son intérêt, Bitbucket intègre directement le vote sur les issues, ce qui permet de jauger l'intérêt de la communauté pour une feature particulière.

La synchronisation avec d'autres bug trackers est généralement possible. L'intégration de Bitbucket avec Jira est mise en avant mais le même [connecteur](https://confluence.atlassian.com/display/BITBUCKET/Use+the+JIRA+DVCS+Connector+Plugin) est utilisé pour Github et Bitbucket dans JIRA, les fonctionnalités sont donc possiblement équivalentes (mais je n'ai pas testé).

<h1>Wiki</h1>

Un wiki minimaliste est disponible pour les deux sites, avec syntaxe markdown, code highlighting et téléchargement possible (avec Git bien sûr) pour consultation offline.

<h1>Money, Money</h1>

Bitbucket mise sur un bon argument pour attirer les développeurs : les repositories privés. Alors que sur Github, le plan gratuit ne vous donne accès qu'à des repositories publics, Bitbucket autorise la création gratuite et illimitée de repositories privés. La restriction, car il faut bien une incitation à passer à la version payante, concerne le nombre maximum d'utilisateurs d'un repository privé : 5. Vous ne pouvez donc donner les droits d'accès à ces repo privés qu'à 5 de vos collègues : au-delà, il faudra mettre la main au portefeuille.

Les stratégies sont donc différentes en terme de marketing :

- [Github](https://github.com/pricing) limite le nombre de repositories privés en fonction du prix (0 en gratuit, puis 5 pour 7$, 10 pour 12$...), le nombre de collaborateurs étant illimité.
- [Bitbucket](https://bitbucket.org/plans) permet de créer un nombre illimité de repositories privés mais limite le nombre de collaborateurs (5 en gratuit, puis 10 pour 10$, 25 pour 25$...).

Bitbucket a donc un argument intéressant pour une petite équipe créant un projet privé. A noter également la possibilité d'héberger vous même un [Github Enterprise](https://enterprise.github.com/) ou la suite professionelle de Bitbucket, nommée [Stash](https://www.atlassian.com/software/stash/overview), si la perspective d'avoir vos sources sur des serveurs américains vous trouble (mais franchement on ne voit pas pourquoi...). Ces outils vous donnent toutes les fonctionnalités de base plus la possibilité de s'intégrer avec votre système d'authentification interne.

Les prix sont tout de suite plus ... entreprise! Github Enterprise démarre à 5000$ par an pour 20 utilisateurs, et est à peu près linéaire avec [250$ par utilisateur](https://enterprise.github.com/pricing) (100 utilisateurs donnent donc 25000$ par an, aïe). Bitbucket utilise là aussi une stratégie incitative avec une offre à seulement 10$ par mois pour 10 utilisateurs. La pente est ensuite plus raide mais [les prix](https://www.atlassian.com/software/stash/pricing) restent beaucoup plus abordables que ceux de Github avec 100 utilisateurs à 6000$ par an. A noter que Stash offre quelques fonctionnalités intéressantes comme une intégration poussée avec Jira (le bugtracker de la même société), ou les merges automatiques en cascade (un bugfix sur une ancienne release peut être automatiquement mergé sur les releases plus récentes).

<h1>Extras</h1>

Tous deux proposent une très bonne API REST, et des "hooks" qui permettent de s'intégrer avec tout ce que votre écosystème comporte d'important (les intégrations continues, dashboards, issue trackers...).
Bitbucket ne pose [aucune limite sur la taille des fichiers](https://confluence.atlassian.com/pages/viewpage.action?pageId=273877699), là où Github [restreint à 100Mb par fichier](https://help.github.com/articles/what-is-my-disk-quota).
Dans les petits bonus de Github, il ne faut pas oublier [Github Pages](http://pages.github.com/), un support de nouveaux formats ([fichier STL 3D](https://github.com/cexbrayat/3d-pixel-art/blob/master/ninja-squad-3d-smoothed.stl), [fichier GeoJSON](https://github.com/benbalter/dc-maps/blob/master/embassies.geojson)) et une application mobile (même si c'est un peu anecdotique).

<h1>Communauté</h1>

Difficile de concurrencer Github, leader historique, dans le domaine. Avec près de 5 millions d'utilisateurs contre 1.5 million pour Bitbucket, la marge est encore grande. Les projets OSS phares hébergés sur Github sont très connus : Twitter Bootstrap, Node.js, Rails, JQuery, Angular.js, MongoDB, Linux Kernel. Bitbucket de son coté héberge les projets Atlassian, quelques projets de l'écosystème Python/Django et... pas grand chose d'autre de renommé. Mais surtout très difficile de trouver l'information, qui n'est pas mise en avant. A croire donc que les projets open source boudent le produit.

Les deux sites ont un petit aspect social, avec la possibilité de suivre des utilisateurs, de voir leur flux d'activité public, de mettre en favoris certains projets...

<h1>TL; DR;</h1>

Bitbucket a bien rattrapé son retard et ne souffre d'aucune lacune flagrante, au-delà de sa communauté moins nombreuse. Il possède même quelques fonctionnalités que l'on retrouverait avec plaisir sur Github.

Pour résumer :

- vous avez un projet open source ? Github sans réfléchir. L'exposition sera un ordre de magnitude supérieure.
- vous avez beaucoup de repositories privés, une petite équipe et peu d'argent&nbsp;? Bitbucket est la solution économique. Vous pouvez même envisager Stash, leur solution pro.
- vous avez peu de repo privés et/ou de grandes équipes ? Github a un pricing plus intéressant.
- vous voulez héberger la solution chez vous ? Stash est beaucoup moins cher et ajoute quelques fonctionnalités intéressantes. Mais vous pouvez également regarder du côté des projets open source gratuits comme [Gitlab](http://gitlab.org/) par exemple.

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/11/29/bitbucket-vs-github/ "Article original sur le blog de Cédric Exbrayat")_
