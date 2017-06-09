---
layout: post
title: Getting started with lambdas - Part 1
author: cexbrayat
tags: ["Java 8", lambda]
canonical: http://hypedrivendev.wordpress.com/2013/02/28/getting-started-with-lambdas-part-1/
---

Si vous avez suivi l’actualité Java ces derniers temps, vous avez peut-être entendu que la sortie de la “developer preview” du JDK 8 a été repoussée. Bien sûr tout le monde s’en donne à coeur joie pour vanner Oracle, c’est de bonne guerre. Mais pour une fois, ce retard est peut-être une bonne chose : toute l’équipe du JDK travaille d’arrache-pied pour peaufiner la grande nouveauté de cette version : les lambdas. Nous avons suivi avec attention leur avancée ces derniers mois, testant des JDKs, pestant contre certains choix et en admirant d’autres. Si au début je trouvais un intérêt minimal aux lambdas par rapport à ce que proposent Scala et consort, j’avoue maintenant attendre la sortie de Java 8 pour profiter des nouveautés, et écrire du code un peu plus sympa dans un langage que j’apprécie.

Voilà assez parlé de ma vie.

Ce post démarre une série qui vise à présenter les lambdas, qui sont probablement la plus grande nouveauté dans le langage depuis les génériques. Plutôt que de vous montrer directement une lambda, et nous extasier devant leur utilisation, j’aimerais vous expliquer un peu ce qui se passe derrière.

Tout repose sur le concept d’interface fonctionnelle.
Une interface vous voyez ce que c’est : un ensemble de méthodes abstraites que l’on devra implémenter dans une classe. Jusque là ça va.

    public interface MessageInterface {
        public String transform(String message);
        public void print(String message);
    }

Mais cette définition change avec Java 8 : une interface peut maintenant avoir des méthodes concrètes et des méthodes statiques. Oui, oui, c’est nouveau. Le mot clé `default` est utilisé pour définir une méthode concrète dans une interface. Par exemple :

    public interface MessageInterfaceWithDefault {
        public String transform(String message);
        public default void print(String message) {
            System.out.println(message);
        }
    }

Ca fait bizarre, mais on s’y fait. Dans le cas de cette interface, la méthode `print()` a une implémentation par défaut. Il peut également y avoir plusieurs méthodes `default` bien sûr. Ainsi si vous voulez implémenter cette interface vous avez deux solutions :

    public class MessageWithoutDefault implements MessageInterfaceWithDefault {
        public String transform(String message) {
            return message;
        }
        public void print(String message) {
            System.out.println(“message :” + message);
        }
    }

Cette première solution implémente l’interface en donnant une implémentation à chaque méthode, la méthode `default` étant surchargée.
Une autre solution est possible, si l’implémentation par défaut de print vous convient, vous pouvez seulement fournir une implémentation à `transform()` :

    public class MessageWithDefault implements MessageInterfaceWithDefault {
        public String transform(String message) {
            return message;
        }
    }

Donc en résumé, une méthode `default` dans une interface vous fournit une implémentation par défaut, libre à vous de la redéfinir ou pas.

Qu’en est il de l’héritage multiple?

Si vous héritez de deux interfaces possédant une méthode `default` avec la même signature, le compilateur va regarder si l’une des interfaces hérite de l’autre. Si c’est le cas, l’interface la plus spécialisée est préférée. Sinon vous obtenez l’erreur de compilation suivante :

    class training.lambda.Both inherits unrelated defaults for print() from types training.lambda.Interface1 and training.lambda.Interface2

Voilà pour les méthodes `default`.

Revenons-en aux interfaces fonctionnelles. Lorsque vous allez écrire une lambda, vous allez en fait implémenter une interface fonctionnelle. Une interface fonctionnelle est une interface qui ne possède qu’une seule méthode abstraite. Elle peut en revanche avoir plusieurs méthodes `default`. L’interface `MessageInterfaceWithDefault` est donc une interface fonctionnelle. Vous pourriez écrire :

    MessageInterfaceWithDefault asALambda = message -> “message : “ + message;

Ce code est tout à fait valide. L’expression de droite est en fait l’implémentation de la méthode `transform()` de l’interface. Ainsi si vous exécutez le code suivant :

    String result = asALambda.transform(“hello”); // result = “message : hello”

On est d’accord, il n’y a pas beaucoup d’intérêt à utiliser les lambdas ainsi. Cet exemple montre seulement ce que sont réellement les lambdas. Ainsi, vous ne pouvez pas utiliser les lambdas pour implémenter des interfaces qui possèdent plusieurs méthodes abstraites : le compilateur ne saurait pas quelle méthode vous essayez d’implémenter.

Le JDK contient déjà beaucoup d’interfaces fonctionnelles : `FileFilter`, `Runnable`, `Callable`, `ActionListener`, `Comparator`...

`FileFilter` a par exemple une seule méthode abstraite : `boolean accept(File pathname)`, qui prend donc un fichier en argument et renvoie un booléen. `FileFilter` est utilisé comme argument dans la methode `listFiles()` de `File`, pour renvoyer une liste de fichiers qui correspondent au filtre. Vous voulez récupérer les répertoires d’un dossier dir, en une ligne en utilisant les lambdas ?

    File[] files = dir.listFiles(f -> f.isDirectory())

`f -> f.isDirectory()` est une lambda que le compilateur interprète comme l’implémentation d’un `FileFilter`. Rapide et efficace, je ne vous montre même pas le code que l’on doit écrire actuellement.

Dans votre code, vous pourrez faire vos propres interfaces fonctionnelles, qui seront joyeusement implémentées sous forme de lambda par vos collègues, parfois même dans des modules différents. Mais que se passe-t-il si quelqu’un ajoute une méthode abstraite à votre interface? Et bien les lambdas écrites par vos collègues vont poser problème à la compilation des modules qui utilise votre interface :

incompatible types: lambda.Interface1 is not a functional interface
multiple non-overriding abstract methods found in interface com.ninja_squad.training.lambda.Interface1

Pour prévenir ce problème, une annotation @FunctionalInterface a été ajoutée. Celle-ci indique au compilateur que l’interface en question ne doit avoir qu’une et une seule méthode abstraite. Si vous essayez d’ajouter une méthode abstraite à cette interface, vous obtenez l’erreur de compilation suivante :

Unexpected @FunctionalInterface annotation
training.lambda.Interface1 is not a functional interface
multiple non-overriding abstract methods found in interface training.lambda.Interface

Autant dire que ce garde-fou devra être systématiquement utilisé si vous créez des interfaces fonctionnelles afin de prévenir de potentiels (probables?) problèmes à l’avenir. Toute personne qui modifiera l’interface saura immédiatement à quoi s’en tenir!

La prochaine fois, on regardera comment écrire une lambda en détail (enfin!).

_Article publié sur le [blog de Cédric](http://hypedrivendev.wordpress.com/2013/02/28/getting-started-with-lambdas-part-1 "Article original sur le blog de Cédric Exbrayat")_
