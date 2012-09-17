---
layout: post
title: Responsive JS media queries
author: clacote
tags: [web, responsive, javascript]
---
#Responsive?

Tout [le monde a un smartphone](http://www.wired.com/gadgetlab/2011/11/smartphones-feature-phones/), ou presque. Et presque tout le monde a une tablette.   
Il serait dommage de ne pas soigner ces lecteurs, surtout si vous vous adressez à des geeks. Une bonne partie d'entre eux consomme du web en situation de mobilité. Et aujourd'hui, on n'a plus d'excuse à ne pas faire un site responsive : des frameworks CSS aussi communs que [Twitter Bootstrap](http://twitter.github.com/bootstrap/scaffolding.html#responsive) nous mâchent complètement le travail.

C'est indiscutable, vous n'avez aucune excuse. En tout cas faîtes comme-ci, sinon cet article n'a plus vraiment de raison d'être. OK?
Maintenant, supposons que vous produisiez du contenu par JavaScript. Du genre large le contenu. Par exemple, de l'ASCII-art :

     _____ _     _        _____               _
    |   | |_|___|_|___   |   __|___ _ _ ___ _| |
    | | | | |   | | .'|  |__   | . | | | .'| . |
    |_|___|_|_|_| |__,|  |_____|_  |___|__,|___|
              |___|              |_|

Pourquoi ce contenu n'aurait-il pas droit, lui aussi, a être responsive? Sur un smartphone, sa largeur est trop grande, j'aimerais que les deux mots s'affichent sur deux lignes. Comme ça :

	   _____ _     _       
	  |   | |_|___|_|___   
	  | | | | |   | | .'|  
	  |_|___|_|_|_| |__,|  
	 _____      |___|    _ 
	|   __|___ _ _ ___ _| |
	|__   | . | | | .'| . |
	|_____|_  |___|__,|___|
	        |_|            


Je suis d'accord, ce use-case n'est pas le plus commmun. Mais à quoi bon faire un blog post sur un sujet bateau, sinon?

#CSS3 media queries

CSS3, grâce aux *media queries*, permet de styler le contenu en fonction de caractéristiques d'affichage : ratio, device, ou dimensions. C'est ce que met en oeuvre [Twitter Bootstrap](http://twitter.github.com/bootstrap/scaffolding.html#responsive) pour assurer le responsive. Ainsi, il adapte sa grille naturellement, transformant les colonnes en lignes quand la largeur ne suffit plus.

Des classes CSS (`.visible-desktop`, `.hidden-phone`, etc...) vous permettent même de masquer ou afficher du contenu en fonction d'un type de device visé.

Par exemple :

	<div class="visible-desktop">Hello Desktop!</div>
	<div class="visible-tablet">Hello Tablet!</div>
	<div class="visible-phone">Hello Phone!</div>

affiche : 
<div class="visible-desktop">Hello Desktop!</div>
<div class="visible-tablet">Hello Tablet!</div>
<div class="visible-phone">Hello Phone!</div>

Essayez de redimensionner la fenêtre de votre navigateur, si vous êtes sur desktop : le texte affiché dépend de la largeur du navigateur. <small>Ce côté magique du responsive me fait vibrer en ce moment.</small>

Vu du [source de Bootstrap](https://github.com/twitter/bootstrap/blob/master/less/responsive-utilities.less), c'est simplement une media query testant la largeur d'affichage et affichant/masquant ces classes en fonction. Par exemple, pour les devices de type _phone_ :

	@media (max-width: 767px) {
	  .visible-desktop   { display: none !important; }
	  // etc.
	}

Bootstrap permet donc nativement de rendre responsive notre contenu HTML.
Maintenant, comment mettre en oeuvre ces fonctionnalités en JavaScript?

#JS window.matchMedia()

Une fonction JS permet de tester des media queries CSS : [`window.matchMedia`](https://developer.mozilla.org/en-US/docs/DOM/window.matchMedia).
En réutilisant les queries definies par Bootstrap, on peut donc se définir des fonctions utilitaires JavaScript testant le type de device :

	window.matchMediaPhone = function() {
	    return matchMedia('(max-width: 767px)').matches;
	}
	window.matchMediaTablet = function() {
	    return matchMedia('(min-width: 768px) and (max-width: 979px)').matches;
	}
	window.matchMediaDesktop = function() {
	    return matchMedia('(min-width: 979px)').matches;
	}

Cela me permet d'écrire : `if (isMatchMediaPhone()) return "Hello Phone!";

Le support de `window.matchMedia` est encore assez limité. Heureusement, [Paul Irish nous fournit un polyfill](https://github.com/paulirish/matchMedia.js/) assurant la compatibilité avec les navigateurs plus anciens.

"Et voilà", commme disent les américains francophones et les francophones américanophiles.