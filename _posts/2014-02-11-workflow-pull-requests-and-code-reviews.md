---
layout: post
title: Workflow, Pull Requests &amp; Code Reviews
author: cexbrayat
tags: [git, github]
canonical: http://hypedrivendev.wordpress.com/2014/02/11/workflow-pull-requests-and-code-reviews
---

Si vous suivez le blog, vous savez que nous avons déjà parlé du [workflow Git](http://blog.ninja-squad.com/2013/06/03/branching-with-git/) que nous utilisons en local. Mais on ne vous a jamais expliqué les différentes façons de collaborer à plusieurs sur un projet.

Il y a deux grandes façons de travailler à plusieurs :
- un repo partagé par toute l'équipe
- un repo pour chaque développeur

# Workflow &amp; Pull Requests

## Open Source style

Cette dernière façon est la plus répandue dans le monde open source. Admettons que vous vouliez contribuer au projet AngularJS. Vous n'avez pas les droits d'écriture sur le repository Github utilisé par le projet tant que quelqu'un de l'équipe ne vous les donne pas. Ce qui semble assez logique vu qu'ils ne vous connaissent pas :)

Donc, si vous voulez contribuer au projet, il faut commencer par faire un fork. Il y a un gros bouton sur Github qui permet de faire ça et qui va copier le projet AngularJS dans votre espace utilisateur (par exemple `cexbrayat/angular.js`). Sur ce nouveau repository, j'ai les droits d'écriture. Je peux donc le cloner sur mon laptop :

    git clone https://github.com/cexbrayat/angular.js

Une fois cloné, le repository Github est référencé comme le repo 'origin' dans nos remotes. Je peux faire des modifications dans une branche :

    cd angular.js
    git branch awesome-feature
    git checkout awesome-feature
    ... commits

et pousser mon code sur mon repository :

    git push origin awesome-feature

Il faut noter que ce repository n'est pas synchronisé automatiquement avec le repository forké : si les développeurs de la team Google ajoutent de nouveaux commits au repository `angular/angular.js`, nous ne les verrons pas dans notre repository. Si ces commits nous intéressent, il est possible d'ajouter ce repo come un autre de nos remotes. Par convention, ce repository est généralement appelé 'upstream'.

    git remote add upstream https://github.com/angular/angularjs

On peut coder notre fonctionnalité comme précédemment :

    git branch awesome-feature
    git checkout awesome-feature
    ... commits

Et l'on peut maintenant récupérer les modifications de la team Google et mettre à jour notre branche locale avec celles-ci :
    
    # on récupère les derniers commits de upstream
    git fetch upstream
    git rebase upstream/master
    # on pousse notre branche à jour
    git push origin awesome-feature

Une nouvelle branche `updated-with-upstream` sera alors ajoutée sur notre repository Github, à jour avec les dernières modifications faites par l'équipe de Google.

Si cette branche contient une fonctionnalité que vous voulez contribuer, vous pouvez alors créer une pull request. En vous plaçant sur votre branche dans l'interface Github, vous pouvez choisir de créer une pull request vers le repository que vous avez forké, par défaut sur la branche `master`, mais rien ne vous empêche de changer de branche. Vous entrez alors un titre, une description du but de cette PR. Lorsque vous validez, les propriétaires du repository sur lequel vous avez fait la PR vont recevoir un mail leur indiquant l'arrivée d'une nouvelle requête.

Dans l'interface Github, ils pourront faire une revue de code, mettre des commentaires sur certaines lignes (vous ne vous attendiez pas à réussir du premier coup si?), puis enfin choisir de refuser la PR (dommage) ou de la merger (\o/). Dans ce dernier cas, votre code sera ajouté à la branche en question, bravo!

Github fournit maintenant un ensemble de [guides](http://guides.github.com/) fort pratiques pour débuter : vous pouvez regarder celui sur le [workflow des PRs](http://guides.github.com/overviews/flow/).

## Enterprise style

En entreprise, le workflow est généralement différent. La plupart du temps, l'équipe collabore sur un seul repository sur lequel tout le monde possède les droits d'écriture. Il y a donc deux façons de procéder. 

La première consiste à pousser ses modifications directement sur le `master` (si c'est votre branche de développement actif). On laisse alors le soin à l'intégration continue de repérer tout problème (il n'y a plus qu'à espérer avoir suffisamment de tests...).

    git branch feature-one
    git checkout feature-one
    ... commits
    # on récupère les derniers commits de origin
    git fetch origin
    git rebase origin/master
    # on pousse notre branche à jour sur le master
    git push origin feature-one:master

La seconde consiste à pousser ses modifications sur une branche partagée, puis de créer une pull request entre cette branche et le master! L'avantage est de pouvoir faire une revue de code sur cette pull request, d'en discuter puis de l'intégrer.

    git branch feature-one
    git checkout feature-one
    ... commits
    # on récupère les derniers commits de origin
    git fetch origin
    git rebase origin/master
    # on pousse notre branche à jour sur une branche partagée pour faire une PR
    git push origin feature-one

# Code review, sweet code review

Le mécanisme de code review est vraiment intéressant à systématiser. Bien sûr, cela introduit une tâche supplémentaire, que l'on peut voir comme une perte de temps. Mais il est très difficile de coder juste tout le temps du premier coup (en tout cas moi je sais pas faire), et un oeil externe peut souvent voir certains problèmes qui nous ont échappé au moment de la réalisation. 

Au-delà de ça, le niveau d'une équipe n'est jamais parfaitement homogène : certains sont d'excellents développeurs front-end, d'autres seront plus à l'aise sur le back-end, ou l'automatisation du projet. La code review est alors un excellent moyen de transmettre des compétences! Si la personne qui relit le code est plus expérimentée, elle sera à même de donner des conseils, des solutions plus élégantes et de repérer des problèmes. Si elle est moins expérimentée que celle qui a développé, elle pourra poser des questions, comprendre de nouvelles choses, s'inspirer. Et elle trouvera des erreurs aussi, c'est garanti! 

C'est une procédure délicate, car il faut être capable de dire les choses sans blesser les autres (on est tous un peu sensible sur notre code), ou être capable d'admettre que l'on ne sait pas ce que fait cette méthode et de poser la question. 

La code review permet aussi d'homogénéiser les développements, parce que cela force à relire le code des autres, ce que l'on ne fait que rarement si on est la tête dans le guidon. Et surtout, surtout, cela partage les connaissances fonctionnelles. Si vous avez connu le phénomène de "j'ai pas codé cette partie, je sais pas comment ça marche", vous savez de quoi je parle. Faire une revue de code force à comprendre les nouvelles fonctionnalités de l'application même si l'on a pas codé directement dessus. Cela limite ensuite le 'Bus Effect' (autrement appelé 'Scooter Effect' chez Ninja Squad, grâce aux aventures de Cyril).

Selon les projets et les clients, nous utilisons actuellement ces 3 façons de travailler. La dernière (un seul repo, avec une branche partagée par fonctionnalité, puis pull request pour intégration sur master) est vraiment agréable à utiliser.

Nous avons récemment commencé un projet avec ce workflow et notre intégration continue (Jenkins) se charge de construire chaque pull request indépendamment et d'inscrire sur Github un commentaire avec 'Tests pass' ou 'Tests fail'. De plus nous pouvons déployer un container Docker pour tester une Pull Request de façon isolée. Je trouve ça génial : en 35 secondes l'application est buildée complètement, un container Linux isolé est démarré avec le nécessaire (serveur, bases et données), et l'application est exposée sur un port aléatoire. On se rend alors sur cette adresse pour tester la fonctionnalité et éventuellement remonter des bugs à l'auteur. Sans ouvrir un IDE, sans taper une seule ligne de commande, il est possible de lire le code, le commenter, voir si des tests échouent, et tester la fonctionnalité dans un environnement similaire à la prod. Magique.

Vous l'aurez compris, faire une pull request n'est pas très compliqué. Si vous démarrez un projet et hésitez sur la façon de travailler, pensez à considérer un workflow basé sur des pull requests et des revues de code : votre équipe finira par ne plus pouvoir s'en passer!

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/02/11/workflow-pull-requests-and-code-reviews "Article original sur le blog de Cédric Exbrayat")_
