---
layout: post
title: Angular, Express et Socket.io
author: cexbrayat
tags: [angularjs, websocket]
canonical: http://hypedrivendev.wordpress.com/2013/12/19/angular-express-socketio
---

Vous savez, si [vous nous lisez](http://blog.ninja-squad.com/2013/09/11/rentree-des-ninjas/) régulièrement, que nous donnons des cours dans différents établissements, de la fac aux écoles d'ingé, en passant par l'IUT. Avec cette nouvelle année scolaire, nous voici repartis!

Je donne depuis quelques années un cours sur les web services à l'INSA, à l'invitation du [Docteur Ponge](https://twitter.com/jponge) : c'est l'occasion de parler SOAP (beurk), REST (yay!) et Websocket (re-yay!).

Cette année, je veux faire une démo des websockets pour que cela soit un peu moins mystérieux. Faire un peu de code live est toujours un exercice périlleux, mais c'est un bon moyen pour échanger avec les étudiants et leur présenter un certain nombre de technologies, qu'ils connaissent parfois de nom ou pas du tout.

Les websockets sont l'occasion idéale de faire une application web basique, mais permettant d'introduire quelques concepts du Web parfois mal connus (HTML, CSS, Javascript) et un peu de code plus innovant (Node.js, Express, Socket.io, AngularJS, Bootstrap), de discuter sur l'histoire du Web, le fonctionnement des navigateurs (Chrome, Firefox, V8...) et quelques outils pratiques (npm, Git). Bref, d'apporter un peu de culture générale de notre métier, chose que j'appréciais beaucoup lors des interventions de professionnels lorsque j'étais étudiant.

Après cette remise en contexte, passons aux choses sérieuses!

Il me fallait donc un exemple d'application, qui me prenne une trentaine de minutes à réaliser au maximum. J'ai choisi de faire simple : une application de vote qui permet de choisir votre framework Javascript préféré, et de voir les résultats en temps réel. Nous allons voir les différentes étapes pour y parvenir.

Vous trouverez le nécessaire pour utiliser l'application sur le repo [Github de Ninja Squad](https://github.com/Ninja-Squad/angular-express-socketio).

<h1>Express/Angular</h1>

La première branche Git, nommée `express` met en place une application Node.js/Express minimale.

    var express = require('express')
      , app = express()
      , server = require('http').createServer(app);

    app.use(express.static(__dirname + '/'));

    server.listen(9003);

L'application Node.js va servir les ressources statiques sur le port 9003. On peut alors ajouter le fichier [HTML de notre application](https://github.com/Ninja-Squad/angular-express-socketio/blob/express/vote.html), qui contient basiquement :

    <div class="row" ng-repeat="vote in votes">
      <div class="col-xs-4 vote"> {{ vote.choice }} </div>
      <div class="col-xs-4 vote"> {{ vote.votes }} </div>
      <div class="btn btn-primary col-xs-4" ng-click="voteFor(vote.choice)">+1</div>
    </div>

Pour chaque vote de la collection `votes`, le choix (VanillaJS, AngularJS, BackboneJS ou EmberJS), le nombre de vote pour ce choix et un bouton pour ajouter un vote seront affichés. Cela est réalisé en utilisant la directive `ng-repeat` d'Angular.

Le bouton de vote comporte l'attribut `ng-click` qui permet de lui lier une fonction à exécuter. Cette fonction `voteFor` est définie dans le controller :

	function VoteCtrl($scope){
      $scope.votes = [ { choice: 1, label: 'VanillaJS', votes: 0 }, { choice: 2, label: 'AngularJS', votes: 0 }, { choice: 3, label: 'BackboneJS', votes: 0 }, { choice: 4, label: 'EmberJS', votes: 0 }];

      $scope.voteFor = function(choice){ $scope.votes[choice-1].votes++; }
    }

Le controller Angular initialise les votes et définit la fonction de vote, qui ajoute simplement 1 aux votes du choix cliqué.

Etape 1 terminée! Passons maintenant à l'intégration de Socket.io.

<h1>Socket.io</h1>

[Socket.io](http://socket.io) est l'une des librairies les plus utilisées pour les websockets dans Node (même si elle est maintenant concurrencée par d'autres comme [SockJS](https://github.com/sockjs)). Elle a l'avantage de gérer le fallback si les websockets ne sont pas disponibles, et d'être très simple à utiliser à la fois côté client et côté serveur.

La branche `websocket` contient le code correspondant. Outre l'installation de socket.io (`npm install` is your best friend), il nous faut modifier un peu le serveur :

    io.sockets.on('connection', function (socket) {
      socket.emit('votes', { votes: votes });
      socket.on('vote', function(msg){
      	votes[msg.vote-1].votes++;
      	io.sockets.emit('votes', { votes: votes });
      })
    });

L'implémentation est naïve mais suffit à la démonstration : à la connexion d'un nouveau client (`socket.on('connection', ...)`), on envoie les votes dans l'état du moment (`socket.emit`). Puis, lorsque l'on recevra un vote (`socket.on('vote', ...)`), on incrémente les votes du choix correspondant et on informe tous les participants avec les nouvelles valeurs (`io.sockets.emit`).

Reste à mettre à jour le client pour communiquer avec les sockets :

    var socket = io.connect('http://localhost:9003');

    $scope.voteFor = function(choice){
      socket.emit('vote', {vote : choice })
    }

    socket.on('votes', function(msg){
      $scope.votes = msg.votes;
      $scope.$apply();
    });

On commence par se connecter aux websockets (`io.connect`). La fonction `voteFor` est modifiée pour maintenant envoyer un évenement de vote au serveur (`socket.emit`). Enfin, à chaque fois que les votes sont reçus, les votes du `$scope` Angular sont mis à jour. Petite subtilité : comme cette mise à jour intervient en dehors de la boucle d'exécution d'Angular, il nous faut appeler la fonction `$apply()` pour que le framework prenne les nouvelles valeurs en compte et rafraîchisse les vues.

Nous sommes prêts : si vous ouvrez cette application dans deux onglets, vous pourrez la voir se mettre à jour en temps réel!

A noter que le brillant [Brian Ford](https://twitter.com/briantford) de l'équipe Angular propose un [service Angular](https://github.com/btford/angular-socket-io) pour Socket.io, afin de simplifier son utilisation et notamment les appels à `$apply()`.

Vous pouvez voir [une démo en ligne](http://angular-express-socketio.herokuapp.com/vote.html), déployé sur Heroku (le code nécessaire pour cette partie est également sur le repo Github).

Espérons que ce petit essai vous plaise et plaise à nos étudiants!

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/12/19/angular-express-socketio "Article original sur le blog de Cédric Exbrayat")_
