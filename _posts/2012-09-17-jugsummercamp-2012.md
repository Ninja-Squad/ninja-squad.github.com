---
layout: post
title: JUG Summer Camp 2012
author: cexbrayat
tags: [java, jug, conference]
---
Premier voyage de l'équipe <a href="https://ninja-squad.com">Ninja Squad</a>, direction La Rochelle pour le <a href="https://sites.google.com/site/jugsummercamp/">JUG Summer Camp</a>. Du Java, du Web, l'océan, une conf gratuite d'une journée avec une organisation irréprochable, il faudrait être difficile pour ne pas aimer!

<div style="text-align: center"><a href="http://www.jugsummercamp.org"><img title="JUG Summer Camp 2012" src="http://www.jugsummercamp.org/assets/images/logo-summercamp.png" alt="JUG Summer Camp"/></a></div>

<br/>
<br/>

___Keynote___&nbsp;:&nbsp;Nicolas de Loof -&nbsp;<a href="https://twitter.com/ndeloof">@ndeloof</a><br/>
Nicolas nous a fait un numéro de stand up très drôle en parodiant le podcast bien connu dans le monde Java : les <a href="http://lescastcodeurs.com/">Castcodeurs</a>. Comme aucun d'entre eux n'étaient présents, Nicolas a eu l'idée de faire un puppet show en reprenant les traits caractéristiques de chacun d'entre eux, pour faire une keynote originale sur notre métier. Franc succès dans la salle (évidemment seulement drôle si on écoute ce podcast).
La journée se déroule ensuite sur deux tracks de confèrence, il faut donc faire des choix.
<br/><br/>
___Google TV___ : Olivier Gonthier -&nbsp;<a href="http://twitter.com/rolios">@rolios</a><br/>
Première présentation sur la Google TV, petit boîtier qui permet de faire tourner des applis Android sur votre télé, mais pas encore disponible en France (on ne connait même pas les partenariats avec les opérateurs). Le principe est simple : une prise HDMI en entrée reçoit le flux vidéo et une prise HDMI de sortie le renvoie vers la TV. A noter que le code de Google TV n'est pas open source. Sinon techniquement c'est le même market que les applis Android traditionnelles.
Commençons par le point qui fâche et qui, à mon sens, fait perdre tout l'intérêt de la chose : il n'est pas possible de récupérer le flux video, ni la chaine visionnée par l'utilisateur, donc vous pouvez oublier toutes les idées d'applications contextuelles: IMDB sur le film en cours ou les stats du match que vous êtes en train de regarder, c'est foutu!
Mais il y a deux ou trois trucs intéressants quand même : par exemple, le "<a href="https://developers.google.com/tv/remote/">second screen app</a>", qui permet aux devices Android de s'interfacer avec la GoogleTV et de vous servir de télécommande ou mieux, d'écran annexe pour certaines applications. L'exemple que je trouve assez cool : un jeu de poker Hold'em où la TV affiche la table de jeu (avec les cartes communes et les mises) et chaque joueur voit ses cartes sur son téléphone. Ce genre d'application peut avoir un grand potentiel, je suis sûr que l'on va voir apparaître des applications géniales!
Le développement est de la programmation Android traditionnelle, le SDK étant complété avec des fonctions pures TV (touches telecommande par ex). Si vous souhaitez développer une application Android utilisant le "second screen", vous pouvez utiliser <a href="https://developers.google.com/tv/remote/docs/samples">Anymote library</a> (voir dans les exemples de code fournis par Google, dans l'application <a href="http://code.google.com/p/googletv-android-samples/source/browse/#git%2FBlackJackTVRemote">Blackjack TV</a>).
Il est également possible de développer des applications en html5, la GoogleTV ayant un très bon navigateur Chrome intégré (très bien documenté d'après le speaker). Il est aussi possible de packager votre application avec <a href="https://phonegap.com">Phonegap</a> pour la distribuer directement sur le Market.
En plus j'ai gagné la GoogleTV du concours, yay!
<br/><br/>
___Node.js___ : Romain Maton -&nbsp;<a href="http://twitter.com/rmat0n">@rmat0n</a><br/>
Romain faisait une présentation générale de Node.js (voir <a title="Getting started with Node.js : Part 1" href="http://hypedrivendev.wordpress.com/2011/06/28/getting-started-with-node-js-part-1/">articles</a> <a title="Getting started with Node.js : Part 2" href="http://hypedrivendev.wordpress.com/2011/07/31/getting-started-with-node-js-part-2/">précédents</a> et les excellents articles de Romain) avec quelques rappels sur les principes de base. C'était une présentation très orientée web-app avec le framework web Express et son moteur de template par défaut Jade (cf <a title="Node, Express et Jade" href="http://hypedrivendev.wordpress.com/2011/08/23/node-express-jade/">article précédent également</a>).
Puis les modules importants :
- &nbsp;l'incontournable <a href="http://socket.io/">Socket.io</a> pour faire des websockets
- &nbsp;logging avec <a href="https://github.com/flatiron/winston">Winston</a>
- &nbsp;<a href="https://github.com/remy/nodemon">nodemon</a>, redémarrage automatique dès que vous modifiez un fichier.
- &nbsp;<a href="https://github.com/nodejitsu/forever">forever</a> pour relancer l'application en cas d'erreur qui coupe l'appli
- &nbsp;<a href="https://jasmine.github.io">jasmine</a>, <a href="http://qunitjs.com/">qunit</a>, pour les tests

Et pour terminer une petite démo sympa avec la librairie <a href="https://github.com/christopherdebeer/speak.js">speak</a> qui fait parler le navigateur pour annoncer le prochain bus qui passe.
<br/><br/>
___Start me up___ : Nicolas de Loof -&nbsp;<a href="http://twitter.com/ndeloof">@ndeloof</a><br/>
Après le buffet repas le plus incroyable pour une conf que j'aie vu (les membres de l'orga MiXiT présents étaient impressionnés), on reprend avec 'Start me up' ou comment passer rapidement de l'idée à la réalisation (en utilisant <a href="http://www.cloudbees.com/">Cloudbees</a>, dont Nicolas est employé). L'idée est ici de faire un mini moteur de recherche sur les talks de la conf. Nicolas utilise au passage un autre service dans le cloud que je ne connaissais pas : <a href="http://websolr.com">WebSolr</a>, un Solr as a Service. Cloudbees on aime bien, MiXiT est hébergé gracieusement dessus et ça marche très bien (le support a toujours été très réactif en cas de problème).
La présentation est intéressante, Nicolas étant un bon speaker, mais si vous avez déjà vu une présentation de Cloudbees le contenu ne vous suprendra pas (comment déployer, comment gérer ses instances, comment déclarer des propriétés pour le déploiement, etc.). La nouveauté la plus notable est sans doute le Click Start, qui permet en un clic de créer tout ce qui va bien pour un type d'application (squelette du projet, repository de code, instance jenkins, base de données et instance de run). Pour l'instant, quatre types de <a href="http://blog.cloudbees.com/2012/08/clickstarts-deploy-app-repo-database.html">Click Start</a> sont disponibles (JavaEE6, Hibernate/Tomcat, Rest/Backbone, Scala/Lift).
<br/><br/>
___Du legacy au cloud___ : David Gageot -&nbsp;<a href="http://twitter.com/dgageot">@dgageot</a><br/>
David est un excellent speaker que je vous recommande de voir si il est dans une conférence à laquelle vous assistez. Son talk est du pur live coding, sans aucun slide, et reprenait le kata de Gilded Rose où une application existante doit être refactorée.  Une spécification est disponible, mais David ne recommande pas particulièrement de la lire pour commencer mais plutôt de créer des tests sur le code existant que l'on doit retravailler. La logique étant que si l'application convient aux utilisateurs actuellement, le plus important est de préserver son fonctionnement. Les tests sont assez simples à écrire, on appelle chaque méthode et on colle dans le assert le résultat renvoyé : on obtient ainsi une série de tests au vert qui seront notre sécurité.
David utilise le plugin <a href="http://infinitest.github.com/">infinitest</a> qui relance les tests dès que le code est modifié : si vos tests sont très courts, le feed-back est immédiat.
La marche à suivre pour refactorer le code est la suivante :
- augmenter la symétrie (mettre les if/else et les equals de la même façon, en enlevant les conditions inversées par exemple).
- puis faire apparaître les duplications de code afin d'extraire de nouvelles méthodes

David finit par introduire de la délégation (un objet était passé dans toutes les méthodes de la classe), en utilisant une <a href="http://projectlombok.org/features/Delegate.html">annotation de Lombok</a>.
Une fois le code propre, David écrit un petit serveur http qui expose les données en JSON, déploie l'application sur <a href="http://www.heroku.com/">heroku</a>, puis déploie un front statique sur <a href="http://pages.github.com/">Github Pages</a> (comme le <a href="https://blog.ninja-squad.com">blog de NinjaSquad</a>) qui consomme les données.
Le tout en 45 minutes, en expliquant très bien ses choix et en utilisant IntelliJ avec maestria. C'est la présentation que j'ai préféré de la journée, même si parfois le refactoring était un peu magique, David connaissant bien le code et étant pressé par le temps. Si vous voulez tester le dojo par vous même, les projets sont <a href="https://github.com/dgageot/jug-summer-camp-json">disponibles</a> sur le <a href="https://github.com/dgageot">compte Github</a> de David.
<br/><br/>
___Beaglebone = Arduino^10___ : Laurent Huet -&nbsp;<a href="https://twitter.com/lhuet35">@lhuet35</a><br/>
Laurent nous faisait descendre de quelques niveaux d'abstraction avec un talk sur <a href="http://beagleboard.org/bone">Beaglebone</a>, une carte plus puissante qu'un <a href="https://www.arduino.cc">Arduino</a>, un peu du même type que le <a href="http://www.raspberrypi.org/">Raspberry Pi</a>. La présentation était intéressante, avec une explication générale des principes, une démo, et les technos que l'on peut faire tourner sur ce type de cartes (C/C++, Java, Python, Node.js …). Manque de chance pour Laurent, sa carte de démo avait grillé la veille (les risques du métiers), mais son talk n'en a pas été trop perturbé, bravo à lui!
<br/><br/>
___Programatoo pour les grands___ : Audrey Neveu -&nbsp;<a href="https://twitter.com/audrey_neveu">@audrey_neveu</a> et Ludovic Borie - <a href="https://twitter.com/LudovicBorie">@ludovicborie</a><br/>
Vous avez peut être entendu parler de <a href="https://twitter.com/Programatoo">Programatoo</a>, un atelier de programmation pour initier les enfants dès l'age de 6 ans aux joies du code. Audrey et Ludovic nous ont montré les différents outils que l'on peut utiliser pour  éveiller la curiosité des plus petits (je ne sais pas si cela peut fonctionner avec vos collègues également) : <a href="http://scratch.mit.edu/">Scratch</a>, <a href="http://www.kidsruby.com/">KidsRuby</a> ou encore <a href="http://tortuescript.appspot.com/">TortueScript</a>. Très sympa, si vous avez des enfants, ce genre d'outils devraient vous intéresser!
<br/><br/>
La journée de conf se termine déjà, l'assemblée se dirige vers le port pour un repas tous ensemble. Le JUGSummerCamp aura été une très belle journée, superbement organisée par <a href="https://twitter.com/jeromepetit">Jerôme Petit</a>, <a href="https://twitter.com/oriannetisseuil">Orianne Tisseuil</a> et leur équipe. L'équipe <a href="https://mixitconf.org ">MiXiT</a> en partie présente compte bien leur emprunter quelques bonnes idées! Si vous avez l'occasion de vous rendre à la prochaine édition, n'hésitez pas, la conférence, gratuite, est l'une des toutes meilleures en France et la Rochelle et ses alentours ne manquent pas de charme pour rester quelques jours supplémentaires!
<br/><br/>
_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com)_
