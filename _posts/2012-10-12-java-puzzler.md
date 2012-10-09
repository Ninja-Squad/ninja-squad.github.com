---
layout: post
title: Puzzler Java
author: jbnizet
tags: [java]
---

Un petit puzzler Java pour se détendre&nbsp;?.

Considérons le programme Java suivant&nbsp;:

    public class TernaryPuzzler1 {
        public static void main(String[] args) {
            System.out.println(getBase(true) instanceof Sub1);
            System.out.println(getBase(true));
        }

        private static Base getBase(boolean condition) {
            Base result = condition ? new Sub1() : new Sub2();
            return result;
        }
    }

    class Base {
    }

    class Sub1 extends Base {
        @Override
        public String toString() {
            return "Sub1";
        }
    }

    class Sub2 extends Base {
        @Override
        public String toString() {
            return "Sub2";
        }
    }
    
Que se passe-t-il lorsqu'on l'exécute? Ne vous inquiétez pas, il n'y a pas de piège. Oui, la condition est
vraie, donc une instance de <code>Sub1</code> est retournée, et les lignes suivantes s'affichent donc à l'écran&nbsp;:

    true
    Sub1

Maintenant appliquons le même code aux classes <code>Number</code>, <code>Long</code> et <code>Double</code>:

    public class TernaryPuzzler2 {
        public static void main(String[] args) {
            System.out.println(getNumber(true) instanceof Long);
            System.out.println(getNumber(true));
        }

        private static Number getNumber(boolean condition) {
            Number result = condition ? new Long(10L) : new Double(20.0);
            return result;
        }
    }
    
Que se passe-t-il lorsqu'on l'exécute? Attention, là, il y a un piège. <span><a href="#" id="java-puzzler-showAnswer">Cliquez ici</a> pour afficher la réponse.</span>

<div id="java-puzzler-answer" style="display: none;">
    <p>Et la réponse est&nbsp;:</p>
        <pre>
false
10.0</pre>

    <p style="text-align:center;">
        <img src="/assets/images/scratch-head-boy.jpg" alt="wtf"/>
        <br/>
        <small>Image courtesy of David Castillo Dominici / <a href="http://www.freedigitalphotos.net" target="_blank">FreeDigitalPhotos.net</a></small>
    </p>
</div>
    
Si vous voulez comprendre pourquoi, lisez donc la réponse à [cette question sur StackOverflow](http://stackoverflow.com/q/12788865/571407), qui a inspiré ce post.

<script>
$(document).ready(function() {
    $('#java-puzzler-showAnswer').click(function() {
        $('#java-puzzler-answer').slideDown();
        return false;
    });
});
</script>