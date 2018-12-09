---
layout: post
title: Développer pour Google Glass
author: cexbrayat
tags: [google, glass, java, "Java 8"]
canonical: http://hypedrivendev.wordpress.com/2014/04/25/developper-pour-google-glass/
---

Vous n'êtes probablement pas passés à côté de l'existence des Google Glass
et vous êtes même probablement intrigués et impatients d'en essayer.
Peut être aussi un peu effrayés par ces nouvelles caméras qui vont nous
observer dans la vie de tous les jours. Moi aussi. Mais on imagine
aussi les possibilités que peuvent offrir un tel device : cela fait donc
un moment déjà que je voulais voir comment développer pour Google Glass.

Il existe deux façons de procéder :

- utiliser une API REST (nommée Mirror API) pour envoyer des "cartes" (ce qui s'affichera en haut à
droite de l'oeil de votre utilisateur) aux Glasses, pour les insérer dans une Timeline.
- développer une application embarquée sur le device, grâce au Glass Development Toolkit. Cette
option a l'avantage de vous donner accès au hardware et de faire du offline. Le Development Kit est assez proche
de celui qui permet de faire des applications Android.

## L'idée

Mon idée était relativement simple : avec Mix-IT qui approche
  (disclaimer : je fais parti de l'orga), pourquoi ne pas faire le programme de la conf
sur Glass ? Le [site de Mix-IT](http://mixitconf.org) expose déjà une API pour récupérer les différentes sessions,
il suffisait donc de trouver le moyen d'envoyer une notification à l'utilisateur
avant chaque session. Cela ressemblait bien à ce que proposait la Mirror API !

L'API propose même d'envoyer des "bundles" de cartes : c'est à dire un groupe de cartes,
avec une carte particulière pour la couverture. L'idée était donc d'envoyer un
bundle de carte quelques minutes avant le début d'un créneau horaire, avec :

- une carte de couverture qui résume le nombre de talks et de workshops à venir, ainsi que l'heure.
- une carte dans le bundle pour chaque talk et workshop, avec le nom de la salle, le titre et la photo du speaker.

## La stack

Pour la partie technique, ce qui est cool avec la Mirror API,
c'est que vous êtes libres de choisir votre langage préféré pour appeler l'API REST.
Google fournit même des librairies facilitant l'utilisation de l'API dans différents langages.

Bonne occasion pour faire un peu de Java 8!

Il est également nécessaire de demander l'autorisation à l'utilisateur d'accéder à sa timeline,
il faut donc avoir une page Web très simple qui permet à l'utilisateur de déclencher l'autorisation OAuth,
puis à notre code de récupérer le token généré.

Un serveur Web très léger en Java 8 ? Bonne occasion pour essayer [fluent-http](https://github.com/CodeStory/fluent-http) de la team CodeStory !

Enfin, pour le déploiement, mon obsession du moment s'appelle [Docker](http://docker.io). J'espérais donc
pouvoir déployer l'application sur [Google Compute Engine](https://cloud.google.com/products/compute-engine/), qui propose de faire ça depuis peu.

## La réalisation

D'abord, commençons par déclarer notre application Glass. Il suffit de se rendre dans
la [console Google](https://console.developers.google.com/project) et de créer un projet, en activant l'API
Google Glass dans la partie API puis en enregistrant les URLs autorisées qui vous intéressent (serveur de dév et de prod) dans les credentials.
Il faut en effet indiquer à Google quelle URL de callback il devra appeler une fois l'authentification réussie (et
c'est ainsi que l'on récuperera notre token).

Première étape de dév, afficher une petite page statique grâce à fluent-http. Super simple,
ce que vous mettez dans le dossier `app` de votre projet est automatiquement servi! Le serveur supporte
même différents formats (markdown, yml...).

`Application.java`

    new WebServer(routes -> {
      routes.get("/", Model.of("oauth", oAuthUrl)
    }).start(8081);


`index.html`

    <h1>Mix-IT, now on Google Glass</h1>
    <a href='[[oauth]]'>Try it!</a>

Le serveur va répondre le fichier `index.html` et remplacer la variable `oauth` par celle définie dans le code,
qui contient l'url d'authentification à appeler.

Ensuite, il faut récupérer le token renvoyé par OAuth. Google met à
disposition une librairie utilitaire pour faire la majeure partie du travail, mais,
soyons honnête, elle est assez désagréable à utiliser (mal pensée, mal codée, mal documentée).
Elle permet quand même de faire l'essentiel du travail sans trop se fatiguer.

On définit donc une nouvelle route dans notre serveur pour récupérer le token renvoyé sur l'url
de callback `/subscribe?code=monToken`.

    routes
    .get("/", Model.of("oauth", oAuthUrl)
    .get("/subscribe", context -> {
      storeCredentials(context.get("code"));
      return ModelAndView.of("success");
    })

Le token est stocké, et les prochaines notifications peuvent donc être envoyées
à l'utilisateur.

Il ne reste plus qu'à récupérer le programme et envoyer au bon moment
les cartes aux utilisateurs inscrits. Pour cela, on récupère le JSON du programme
 exposé par le site et on le parse. Quitte à être en Java 8, autant utiliser les
 [nouveaux types Date du jdk8](http://www.oracle.com/technetwork/articles/java/jf14-date-time-2125367.html) :
 pour cela Jackson propose un module de sérialisation/déserialisation tout prêt.

 C'est plaisant de faire du Java 8, par exemple regrouper les talks par leur heure
  de début se fait en une ligne :

    talks.stream().collect(groupingBy(Talk::getStart));

`groupingBy` est une méthode offerte par la classe Collectors, et fait le travail pour nous.

ou encore les ordonner, et récupérer le prochain talk :

    talks.keySet()
      .stream()
      .min(Comparator.naturalOrder())
      .get();

C'est simple, ca se lit bien, c'est efficace.

Il n'y a plus qu'à construire le bundle de cartes. Construire une carte est très facile,
la librairie Google possède une classe `TimelineItem` avec un attribut `html` dans
lequel vous mettez ce que vous voulez afficher à votre utilisateur.

Pour simplifier, voilà comment est construite une carte :

    <article>
      <section>
        <div class="layout-figure">
          <div class="align-center">
            <p class="text-x-large">talk.getStart()</p>
            <p class="text-normal">talk.getRoom()</p
          </div>
          <div class="text-large" style="background-image: url(talk.getSpeakers().get(0).getUrlimage())">
            <p>talk.getTitle()</p>
          </div>
        </div>
      </section>
    </article>

Vous pouvez constater qu'il y a quelques classes CSS disponibles pour la taille des textes,
ou leur couleur par exemple.

Une fois les cartes construites, on les envoie aux utilisateurs :

    credentials.forEach(credential -> getMirror(credential).timeline().insert(item).execute());

Yay! \o/

## Le déploiement

Donc en ce moment j'aime bien Docker. Et les articles de [David Gageot](http://javabien.net) m'avaient donné envie de tester
Google Compute Engine. C'est parti pour faire l'image Docker de l'application!
On prépare un Dockerfile qui installe Java 8, on lui ajoute les sources du projet, on expose
le port de la webapp et on la démarre. Ca a l'air facile? Ca l'est!

`Dockerfile`

    from base
    maintainer Cédric Exbrayat

    # Install prerequisites
    run apt-get update
    run apt-get install -y software-properties-common

    # Install java8
    run add-apt-repository -y ppa:webupd8team/java
    run apt-get update
    run echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    run apt-get install -y --force-yes oracle-java8-installer

    # Install tools
    run apt-get install -y maven

    # Add sources
    add ./ ./glass
    workdir ./glass

    # Build project
    run mvn install -DskipTests

    # Expose the http port
    expose 8081

    # Launch server on start
    cmd mvn exec:java

Y'a plus qu'à déployer! Mais en fait Google Compute Engine est payant, même pas
un petit mode gratuit comme App Engine. Pas grave, on a déjà un petit serveur avec Docker installé, ca fonctionne pareil! Je rajoute un petit script chargé de tuer le container démarré, et de lancer la nouvelle version :

`run.sh`

    # Kill old container
    echo "kill old container"
    alias docker="docker -H 0.0.0.0:4243"
    docker kill $(cat docker.pid)

    # Build new image
    echo "build image"
    docker build -t ninjasquad/mix-it-on-glass .

    # Run image
    echo "run image"
    DOCKER_CONTAINER=$(docker run -p 8081:8081 -d ninjasquad/mix-it-on-glass)

    # Save container id
    rm docker.pid
    echo "$DOCKER_CONTAINER" >> docker.pid

Procédure de déploiement : `git pull & ./run.sh`.
Temps de déploiement : 15 secondes (quasi entièrement dévolue au build Maven pendant la construction de l'image).

## Le test

Vous allez me dire : "Mais t'as des Google Glass toi ?". Non, j'en ai pas.
Alors, comment je fais pour tester ? Google propose un [Playground](https://developers.google.com/glass/tools-downloads/playground) pour visualiser sa timeline Glass.
Bizarrement assez buggué (les cartes n'apparaissent pas parfois), cela permet quand même de voir si les cartes
sont correctement insérées dans la timeline (même si il faut rafraîchir manuellement, alors que l'on pourrait s'attendre à quelque chose de plus... temps réel!) et d'éditer leur contenu pour jouer avec.

## TL;DR;

Le développement pour Glass est assez simple, surtout du HTML pour faire de belles cartes, et le langage
 que vous préférez pour insérer ces cartes dans la timeline. La partie OAuth est légérement simplifiée en
 utilisant une librairie proposée par Google, même si celle-ci n'est pas fantastique en Java...

Bon, maintenant j'attends de voir des Glass pour faire un test de mon programme. Si vous en avez, tenez moi au courant !

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2014/04/25/developper-pour-google-glass/ "Article original sur le blog de Cédric Exbrayat")_
