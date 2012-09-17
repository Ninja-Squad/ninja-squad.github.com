---
layout: post
title: Responsive JS media queries
author: clacote
tags: [web, responsive, javascript]
---
#Responsive?

Tout [le monde a un smartphone](http://www.wired.com/gadgetlab/2011/11/smartphones-feature-phones/), ou presque. Et presque tout le monde a une tablette.   
Il serait dommage de ne pas soigner ces consommateurs, surtout si vous vous adressez à des geeks. Une bonne partie d'entre eux consomme du web en situation de mobilité. Et aujourd'hui, on n'a plus d'excuse à ne pas faire un site responsive : des frameworks CSS aussi communs que [Twitter Bootstrap](http://twitter.github.com/bootstrap/scaffolding.html#responsive) nous mâchent complètement le travail.

OK.  
Maintenant, supposons que vous produisiez du contenu par JavaScript. Du genre large le contenu. Par exemple, de l'ASCII-ART :

     _____ _     _        _____               _
    |   | |_|___|_|___   |   __|___ _ _ ___ _| |
    | | | | |   | | .'|  |__   | . | | | .'| . |
    |_|___|_|_|_| |__,|  |_____|_  |___|__,|___|
              |___|              |_|

Pourquoi ce contenu n'aurait-il pas droit, lui aussi, a être responsive? Sur un smartphone, sa largeur est trop grande, j'aimerais que les deux mots s'affichent sur deux lignes.
OK, ce use-case n'est pas le plus commmun. Mais à quoi bon faire un blog post sur un sujet bateau, sinon?

#CSS3 media queries

CSS3 permet de styler son contenu en fonction de caractéristiques d'affichages : ratio, device, ou dimensions. C'est ce que met en oeuvre [Twitter Bootstrap](http://twitter.github.com/bootstrap/scaffolding.html#responsive) pour assurer le responsive, en testant uniquement la largeur d'affichage, par exemple `@media (max-width: 767px)` pour sa définition d'un affichage type _phone_.  
Ainsi, la grille s'adapte naturellement, transformant les colonnes en lignes quand la largeur ne suffit plus. Des classes CSS (`.visible-desktop`, `.hidden-phone`, etc...) vous permettent même de masquer ou afficher du contenu en fonction d'un type de device visé.

Par exemple :

	<div class="visible-desktop">Hello Desktop!</div>
	<div class="visible-tablet">Hello Tablet!</div>
	<div class="visible-phone">Hello Phone!</div>

affiche : 
<div class="visible-desktop">Hello Desktop!</div>
<div class="visible-tablet">Hello Tablet!</div>
<div class="visible-phone">Hello Phone!</div>

Essayer de redimenssioner la fenêtre de votre navigateur : c'est magique!


Maintenant, comment mettre en oeuvre ces fonctionnalités en JavaScript?

#JS window.matchMedia()

Une fonction JS permet de tester des media queries CSS : [`window.matchMedia`](https://developer.mozilla.org/en-US/docs/DOM/window.matchMedia).  
Son support est encore assez limité. Heureusement, [Paul Irish nous fournit un polyfill](https://github.com/paulirish/matchMedia.js/) assurant la compatibilité.



