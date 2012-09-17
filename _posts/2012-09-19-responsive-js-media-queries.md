---
layout: post
title: Responsive JS media queries, Bootstrap-compatible.
author: clacote
tags: [web, responsive, javascript]
---
#Responsive?

Tout [le monde a un smartphone](http://www.wired.com/gadgetlab/2011/11/smartphones-feature-phones/), ou presque. Et presque tout le monde a une tablette.   
Il serait dommage de ne pas soigner ces lecteurs, surtout si vous vous adressez à des geeks. Une bonne partie d'entre eux consomme du web en situation de mobilité. Et aujourd'hui, on n'a plus d'excuse à ne pas faire un site responsive : des frameworks CSS aussi communs que [Twitter Bootstrap](http://twitter.github.com/bootstrap/scaffolding.html#responsive) nous mâchent complètement le travail.

C'est in-dis-cu-table, vous n'avez aucune excuse. En tout cas faîtes comme-ci, sinon cet article n'a plus vraiment de raison d'être. OK?

Maintenant, supposons que vous produisiez du contenu par JavaScript. Du genre large le contenu. Par exemple de l'ASCII-art, comme sur [la _home_ de Ninja Squad](http://ninja-squad.com), affiché dans un simili-terminal :

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

	<span class="visible-desktop">Hello Desktop!</span>
	<span class="visible-tablet">Hello Tablet!</span>
	<span class="visible-phone">Hello Phone!</span>

affiche :
<strong> 
<span class="visible-desktop">Hello Desktop!</span>
<span class="visible-tablet">Hello Tablet!</span>
<span class="visible-phone">Hello Phone!</span>
</strong>

Essayez de redimensionner la fenêtre de votre navigateur, si vous êtes sur desktop : le texte affiché dépend de la largeur du navigateur. <small>Ce côté magique du responsive me fait vibrer en ce moment.</small>

Vu du [source de Bootstrap](https://github.com/twitter/bootstrap/blob/master/less/responsive-utilities.less), c'est une media query testant uniquement la largeur d'affichage et affichant/masquant ces classes en fonction. Par exemple, pour les devices de type _phone_ :

	@media (max-width: 767px) {
	  .visible-desktop   { display: none !important; }
	  // etc.
	}

Bootstrap permet donc nativement de rendre responsive notre contenu HTML. C'est déjà énorme. Mais ça ne répond pas encore à notre besoin initial.    
Maintenant, comment mettre en oeuvre ces fonctionnalités en JavaScript?

#JS window.matchMedia()

Une fonction JS permet de tester des media queries CSS : [`window.matchMedia`](https://developer.mozilla.org/en-US/docs/DOM/window.matchMedia).

Le support de `window.matchMedia` est encore assez limité. Heureusement, [Paul Irish nous fournit un polyfill](https://github.com/paulirish/matchMedia.js/) assurant la compatibilité avec les navigateurs plus anciens.

En réutilisant les queries definies par Bootstrap, on peut donc se définir des fonctions utilitaires JavaScript testant les types de devices conformes à Bootstrap :

	window.matchMediaPhone = function() {
	    return matchMedia('(max-width: 767px)').matches;
	}
	window.matchMediaTablet = function() {
	    return matchMedia('(min-width: 768px) and (max-width: 979px)').matches;
	}
	window.matchMediaDesktop = function() {
	    return matchMedia('(min-width: 979px)').matches;
	}

Cela nous permet d'écrire du code comme : `if (isMatchMediaPhone()) return "Hello Phone!"`;

Nous avons ainsi tout en main pour produire le ASCII-art qui nous intéresse en fonction du media.  

	<pre id='ascii'></pre>
	<script>
	  function draw() {
	    var ascii;
	    if (matchMediaDesktop()) {
	      ascii = "...Desktop ASCII-art...";
	    } else if (matchMediaTablet()) {
	      ascii = "...Tablet ASCII-art...";
	    } else if (matchMediaPhone()) {
	      ascii = "...Phone ASCII-art...";
	    }
	    document.getElementById('ascii').innerHtml = ascii;
	  }
	  window.setInterval(draw(), 500);
	</script>

Nous voilà avec un magnifique ASCII-art responsive (n'oubliez pas de redimensionner la fenêtre de votre navigateur pour le _Wow effect!_) :

<pre id='ascii'>ASCII</pre>

<script src="/assets/matchMedia.js">
</script>

<script>
	function draw() {
		var ascii;
		if (matchMediaDesktop()) {
			ascii =                                              
	" _____     _ _        ____          _   _           \n"+
	"|  |  |___| | |___   |    \\ ___ ___| |_| |_ ___ ___ \n"+
	"|     | -_| | | . |  |  |  | -_|_ -| '_|  _| . | . |\n"+
	"|__|__|___|_|_|___|  |____/|___|___|_,_|_| |___|  _|\n"+
	"                                                |_| \n";
		} else if (matchMediaTablet()) {
			ascii =
	" _____     _ _        _____     _   _     _   \n"+
	"|  |  |___| | |___   |_   _|___| |_| |___| |_ \n"+
	"|     | -_| | | . |    | | | .'| . | | -_|  _|\n"+
	"|__|__|___|_|_|___|    |_| |__,|___|_|___|_|  \n";

		} else if (matchMediaPhone()) {
			ascii =
	"   _____     _ _       \n"+
	"  |  |  |___| | |___   \n"+
	"  |     | -_| | | . |  \n"+
	"  |__|__|___|_|_|___|  \n"+
	" _____ _               \n"+
	"|  _  | |_ ___ ___ ___ \n"+
	"|   __|   | . |   | -_|\n"+
	"|__|  |_|_|___|_|_|___|\n";                   
		}
		document.getElementById('ascii').innerHTML = ascii;
	}
	window.setInterval(draw, 500);
</script>

_Et voilà_, commme disent les américains francophones et les francophones américanophiles.  

<p align="center"><img class="img-polaroid" src="/assets/images/success_baby.jpeg" alt="Success!" /></p>
