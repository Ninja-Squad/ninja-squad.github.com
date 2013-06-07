---
layout: post
title: Puzzler Java - les constantes
author: jbnizet
tags: [java]
---

Un nouveau petit puzzler Java pour se détendre&nbsp;?

Considérons le programme Java suivant&nbsp;:

    public class Answers {
        public static final String MEANING_OF_LIFE = "Who knows?";

        static {
            System.out.println("You'll be disappointed by the answers...");
        }

        public static void main(String[] args) {
            System.out.println("What's the meaning of life? Answer: " 
                               + Answers.MEANING_OF_LIFE);
        }
    }
    
Que se passe-t-il lorsqu'on l'exécute? Les lignes suivantes s'affichent à l'écran&nbsp;:

<pre class="raw">
    You'll be disappointed by the answers...
    What's the meaning of life? Answer: Who knows?
</pre>

Maintenant appliquons un refactoring apparemment sans conséquence. Créons une classe séparée pour la méthode principale&nbsp;:

    public class Answers {
        public static final String MEANING_OF_LIFE = "Who knows?";

        static {
            System.out.println("You'll be disappointed by the answers...");
        }
    }
    
    public class Puzzler {
        public static void main(String[] args) {
            System.out.println("What's the meaning of life? Answer: "
                               + Answers.MEANING_OF_LIFE);
        }
    }

A votre avis, qu'est-ce qui s'affiche à l'écran si on exécute le programme&nbsp;?
Réfléchissez, puis <span><a href="#" id="java-constants-puzzler-showAnswer">cliquez ici</a> pour le découvrir.</span>

<div id="java-constants-puzzler-answer" style="display: none;">
    <p>Et la réponse est&nbsp;:</p>
    <pre class="raw">What's the meaning of life? Answer: Who knows?</pre>
    <p>L'avertissement de la classe Answers  a disparu&nbsp;!</p>
    
    <p style="text-align:center;">
        <img src="/assets/images/scratch-head-boy.jpg" alt="wtf"/>
        <br/>
        <small>Image courtesy of David Castillo Dominici / <a href="http://www.freedigitalphotos.net" target="_blank">FreeDigitalPhotos.net</a></small>
    </p>
</div>

## Explication
    
Le code affiche la valeur de <code>Answers.MEANING_OF_LIFE</code>. On s'attend donc à ce que la classe Answers soit chargée, et donc que son bloc 
statique soit exécuté, et l'avertissement affiché. 

Or il n'en est rien. En effet, <code>MEANING_OF_LIFE</code> est une constante, dont la valeur est connue à la compilation. 
Le compilateur insère donc la valeur de la constante directement dans le code appelant. Et il s'agit là d'un comportement 
[spécifié par la JLS](http://docs.oracle.com/javase/specs/jls/se7/html/jls-13.html#jls-13.4.9), et 
pas d'une optimisation sauvage. En gros, le byte-code réellement généré correspond donc au code Java suivant&nbsp;:

    System.out.println("What's the meaning of life? Answer: Who knows?");

Si l'exemple choisi ici manque de réalisme, il est néanmoins important de bien comprendre ce mécanisme, particulièrement si on développe une API. 
En effet, si le code d'une de vos APIs met à disposition du code extérieur des constantes, il faut considérer ces constantes comme... constantes, 
à tout jamais. 

En effet, même si la valeur d'une de ces constantes change dans la version 1.1 de votre API, le code extérieur, qui a été compilé avec la version 1.0 de 
votre API, ne verra pas la nouvelle valeur de la constante à l'exécution. Il faudra recompiler le code extérieur avec la version 1.1 de votre 
API dans le classpath pour que la nouvelle valeur de la constante soit prise en compte.

Si vous estimez que la valeur d'une constante pourrait être amenée à changer dans le futur, proposez plutôt une méthode pour accéder à cette valeur:

    public static String meaningOfLife() {
        return "Who knows?";
    }
    
Notez aussi que toutes les variables <code>static final</code> ne sont pas des constantes pour le compilateur. Seuls les types primitifs et les Strings
peuvent être des [constantes à la compilation](http://docs.oracle.com/javase/specs/jls/se7/html/jls-15.html#jls-15.28).
    
<script>
$(document).ready(function() {
    $('#java-constants-puzzler-showAnswer').click(function() {
        $('#java-constants-puzzler-answer').slideDown();
        return false;
    });
});
</script>