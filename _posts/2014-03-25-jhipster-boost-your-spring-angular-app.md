---
layout: post
title: JHipster - boost your Spring and AngularJS app
author: cexbrayat
tags: [java, spring, yeoman, angularjs]
canonical: http://hypedrivendev.wordpress.com/2014/03/25/jhipster-boost-your-spring-and-angularjs-app/
---

Mon blog s'appelant [Hype Driven Development](http://hypedrivendev.wordpress.com), ça me semblait difficile
de ne pas faire un article sur [JHipster](http://jhipster.github.io/), le générateur d'application full stack pour
les hipsters du Java (avouez, c'est difficile de résister).

Un générateur? Oui, un générateur [Yeoman](http://yeoman.io/). Vous avez peut être entendu parler
de cet outil, fort pratique pour générer des squelettes de projets,
par exemple pour commencer votre prochain projet Angular (c'est d'ailleur le générateur le plus connu).
Yeoman fournit le moteur de base, et vous pouvez installer les générateurs qui vous intéressent.
Il y en a [plein](http://yeoman.io/community-generators.html) et JHipster commence à être fort populaire.

JHipster est un générateur d'application Spring/AngularJS, et donne un projet tout bien
configuré et prêt à démarrer en moins de 10 minutes,
qui se répartissent entre taper 2 commandes et répondre à quelques questions (2 minutes),
regarder NPM télécharger la partie paire de l'internet (3 minutes) et Maven télécharger la partie impaire (5 minutes).
Oui c'était jour de circulation alternée.
Les seuls pré-requis sont donc NodeJS et NPM, un JDK 1.7 et Maven 3.

## Stack serveur

Alors qu'est-ce que ça nous a installé ?
Côté serveur, cela s'appuie sur [Spring Boot](http://projects.spring.io/spring-boot/), un projet assez récent
qui permet de créer rapidement une application fonctionnelle avec Spring 4.
C'est clairement un projet que les équipes Spring veulent mettre en avant, pour montrer
que la création d'une application Spring peut être très simple. Spring Boot va créer une application toute prête
(une CLI est disponible, ou un plugin pour votre outil de build préféré), un `pom.xml` configuré, un serveur Tomcat ou Jetty embarqué,
pas de XML ou de code généré. Vous avez une classe de démarrage de votre application
avec quelques annotations dessus, et ça roule. Spring Boot ramène des copains à la fête :
- [Spring MVC](http://projects.spring.io/spring-framework/) pour les controllers REST.
- [Jackson](https://github.com/FasterXML/jackson) pour la sérialisation JSON.
- [Spring JPA](http://projects.spring.io/spring-framework/) et [Hibernate](http://hibernate.org/) pour la partie accès aux données.
- [HikariCP](http://brettwooldridge.github.io/HikariCP/) pour le pool de connexion JDBC.
- [Spring Security](http://projects.spring.io/spring-security/) pour la gestion des utilisateurs et de l'authentification.
- [Joda Time](http://www.joda.org/joda-time/) pour la gestion des dates (ca devrait être inutile en Java 8).
- [Metrics](http://metrics.codahale.com/) un framework de monitoring, développé par Yammer.
- [Thymeleaf](http://www.thymeleaf.org/) si vous voulez faire des templates côté serveur.
- les drivers de la base de données choisie (H2, PG ou MySQL).
- [Liquibase](http://www.liquibase.org/) pour gérer les changements de schéma (très pratique comme outil).
- [JavaMail](https://javamail.java.net/nonav/docs/api/) pour les... mails.
- [EhCache](http://ehcache.org/) ou [Hazelcast](http://www.hazelcast.com/) selon le cache choisi.
- [Logback](http://logback.qos.ch/) pour la gestion des logs.
- [JUnit](http://junit.org/), [Mockito](https://github.com/mockito/mockito) et
[Awaitility](https://code.google.com/p/awaitility/) pour les tests.

Pas mal de code est déjà généré également, notamment pour la partie sécurité,
avec une classe utilisateur, une pour les rôles, une autre pour les audits...
Et bien sûr les repositories, services et controllers associés.
Un service d'authentification est déjà prévu avec une configuration très solide.
L'organisation des sources est claire et très classique, on s'y retrouve facilement.
Les ressources contiennent le nécessaire pour la configuration Liquibase, les fichiers
YAML de paramétrage de Spring selon le profil (deux profils, prod et dev sont fournis).
C'est dans ces fichiers que vous pourriez configurer votre BDD ou votre serveur mail par exemple.
On trouve également les fichiers de messages pour l'i18n, dans plusieurs langues.
Enfin, figurent aussi les fichiers de config du cache et du logger.

Dans les tests, on trouve des exemples de tests unitaires et de tests de controllers REST.

## Stack client

Passons côté client. On a bien sûr du [AngularJS](http://angularjs.org/) (what else?).
[Grunt](http://gruntjs.com/) est l'outil de build choisi (pas encore de [Gulp](http://gulpjs.com/)? c'est pourtant plus hype...), il est déjà bien configuré
pour surveiller les fichiers et les recharger à chaud au moindre changement sauvegardé, passer [JsHint](http://www.jshint.com/) pour vérifier,
tout minifier et concaténer. [Bower](http://bower.io/) est là pour la gestion de dépendances, rien d'exotique dans ce qui est récupéré :
Angular et ses différents modules indispensables (routes, cookies, translate...). On retrouve bien sûr Twitter Boostrap
pour faire joli et responsive. Les tests unitaires (avec quelques exemples fournis) sont lancés grâce à Karma,
pas de tests end-to-end en revanche.

Le fichier `index.html` est basé sur [HTML5 Boilerplate](http://html5boilerplate.com/), les fichiers CSS et i18n sont là.
Les scripts JS sont regroupés par type (`controllers.js`, `services.js` ...).
Les déclarations d'injection Angular sont faites en mode tableau de chaîne de caractères pour éviter les problèmes de minification.
C'est un bon point, le générateur Yeoman pour Angular propose d'utiliser le plugin [ngmin](https://github.com/btford/ngmin), mais celui-ci a quelques limites.
La sécurité est aussi gérée côté client. Enfin un certain nombre de vues sont disponibles d'origine pour le login et des vues
d'administration : gestion des logs, des perfs.

## Run

Lançons tout ça!
Le projet démarre sur le port 8080 avec un simple `mvn spring-boot:run`, sur un écran d'accueil. On peut se connecter en tant qu'admin
et voir des écrans de gestion de profil (mot de passe, settings, sessions), l'écran d'audit (avec la liste des événements), l'écran de configuration des (977!!) loggers par défaut,
dont on peut changer le niveau à chaud, et enfin l'écran exposé par Metrics, avec les différentes... métriques donc!
On peut y voir des 'Health checks' (est-ce que la base de données est up? le serveur de mail?), les stats de la JVM
(mémoire, threads, GC), les requêtes HTTP, les statistiques des différents services (nombres d'appel, temps moyen, min, max et différents percentiles)
et enfin les statistiques du cache. J'aime beaucoup cette intégration d'un outil de monitoring simple, c'est certainement
quelque chose que j'utiliserai sur mes projets.
Il est possible de changer dynamiquement le langage de l'application (merci [angular-translate](http://angular-translate.github.io/)).

## Développement

JHipster permet aussi de générer des entités pour nous,
depuis la base de données jusqu'à la vue Angular, en passant par le repository et le controller Spring,
la route, le service et le controller Angular. C'est un peu anecdotique (la génération de code, à force...), mais ça marche, et ça
donne un CRUD tout à fait utilisable pour des écrans d'admin. Le service Spring doit lui être généré à part, pour
ne pas encourager la production de code inutile (ce qui est un peu paradoxal pour un générateur de code, vous en conviendrez, mais
  je suis sensible au geste).

Ce qui est plus impressionnant, c'est que le projet utilise [Spring Loaded](https://github.com/spring-projects/spring-loaded), que j'ai découvert très récemment
(merci [Brian](https://twitter.com/brianclozel) de l'équipe Spring au détour d'un café à la Cordée!), et que cet agent permet le rechargement de code à chaud, même
lors d'un ajout de bean Spring! Couplez ça à Grunt et son LiveReload, et chaque modification est prise en compte
instantanément. Très très cool! Je pense que Spring Loaded va se retrouver sur les projets Ninja Squad d'ici peu.

Il faut quand même reconnaître qu'entrer la commande

    yo jhipster:entity campaign

Puis se rendre directement dans son navigateur à l'url '/campaign' et avoir le CRUD fonctionnel devant les yeux
en moins d'une seconde alors que cela a créé des tables en base, des beans Springs, du JS, qu'on a rien relancé,
c'est quand même pas mal la classe internationale.


## TL, DR;

La stack complète est au final extrêmement proche de celle que nous utilisons
sur certains projets chez Ninja Squad : Spring MVC, Spring JPA, Spring Data,
HikariCP, Liquibase, Bower, Grunt, NPM, AngularJS, à l'exception donc
de Spring Boot, Spring Loaded, Metrics, Spring Security et nous préférons LESS à Compass et FestAssert pour les tests.
Puis on fait du Gradle, parce que certains n'aiment pas Maven (je ne donnerai pas de noms).

Mais je crois que Spring Loaded et Metrics vont bientôt rejoindre mes outils favoris.

JHipster propose aussi de faire des WebSockets avec [Atmosphere](https://github.com/Atmosphere/atmosphere) ou
de gérer le clustering des sessions HTTP avec [Hazelcast](http://www.hazelcast.com/).

Bref, plein de bonnes idées, même si vous connaissez bien toutes les technos, et de bonnes pistes de configuration
si vous les découvrez.

Si vous ne saviez pas comment démarrer votre prochain projet Web Java, vous savez maintenant par quoi commencer!
En plus JHipster propose un [container Docker](https://github.com/jhipster/jhipster-docker) pour tester. Si ça c'est pas le top
de la hype 2014, je sais plus quoi faire...

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/03/25/jhipster-boost-your-spring-and-angularjs-app/ "Article original sur le blog de Cédric Exbrayat")_
