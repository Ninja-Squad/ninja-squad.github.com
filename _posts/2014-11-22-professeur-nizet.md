---
layout: post
title: Dis-moi, professeur Nizet...
authors: [clacote, jbnizet]
tags: ["java", "conseils", "web", "rest"]
description: Nous avons la chance de travailler avec Jean-Baptiste Nizet, et de profiter de son talent de développeur au quotidien. Voici une compilation de ses bons conseils.
---

Chez Ninja Squad, nous avons la chance de travailler avec [Jean-Baptiste Nizet](https://ninja-squad.fr/team#JB). Et il faut avouer qu'en terme de _clean coder_, on a rarement vu mieux. C'est le meilleur développeur que j'ai pu croiser depuis maintenant plus de 13 ans. On a donc une chance incroyable de l'avoir dans notre équipe. Chaque jour, à chaque relecture de pull-request, on s'émerveille de la belle simplicité de son code. Et il nous montre au quotidien la longue marche à suivre pour coder élégamment.

De plus, il a une expérience en Java assez incroyable, ayant déjà mis en oeuvre de nombreux outils, frameworks, et approches. Il en fait déjà profiter très régulièrement la communauté en répondant massivement sur [Stack Overflow, ce qui lui vaut une réputation impressionnante](http://stackoverflow.com/users/571407/jb-nizet).

Mais en tant que ninja, nous avons droit à de pertinentes proses privées, où il nous explique son point de vue sur tel ou tel aspect. Et quand on lui propose de le publier sur ce blog, il ne veut pas l'entendre, parce qu'en plus il est d'une humilité crasse. Combien de fois l'a-t-on entendu stresser avant une journée d'expertise chez un nouveau client, s'inquiétant de n'avoir rien de pertinent à leur apporter... Disons aussi qu'il se définit comme développeur, et n'aime pas porter d'autres casquettes qu'il juge absconses (et on ne peut pas lui en vouloir).

J'ai donc décidé de vous faire profiter de cela, et de fournir ici une compilation de ses explications, qu'il n'aurait jamais osé lui-même rendre publiques.

# Static factory methods

L'extrait d'une conversation sur une pull-request concernant entre autre ce bout de code (bien qu'il ne soit pas l'illustration la plus parlante sur le sujet abordé)&nbsp;:

    package com.ninja_squad.xxx.config;

    import org.springframework.format.Formatter;

    /**
     * A Spring formatter (used to parse path variables and request parameters) that transforms/parses an enum as lowercase.
     * Useful if the enum is part of a URL, to make the URL prettier.
     * @author JB Nizet
     */
    public class LowercaseEnumFormatter<E extends Enum<E>> implements Formatter<E> {

        private final Class<E> clazz;

        private LowercaseEnumFormatter(Class<E> clazz) {
            this.clazz = clazz;
        }

        public static <E extends Enum<E>> LowercaseEnumFormatter<E> forClass(Class<E> clazz) {
            return new LowercaseEnumFormatter<>(clazz);
        }

        // ...snipped...
    }


**JB, why do you often use static factory methods instead of public constructors&nbsp;? Is it to benefit of a semantic description of usage from the method name?**

> Yes, semantic is the main advantage: factories have a name, and constructors don't.
>
> In that case, there is a second advantage: instead of writing
>
>     LowerCaseEnumFormatter<BadgeType> f = new LowerCaseEnumFormatter<BadgeType>(BadgeType.class)
>
> you can write
>
>     LowerCaseEnumFormatter<BadgeType> f = LowerCaseEnumFormatter.forClass(BadgeType.class)
>
> and the generic type is inferred. This is less useful since Java 7 where you can use the diamond operator and write:
>
>     LowerCaseEnumFormatter<BadgeType> f = new LowerCaseEnumFormatter<>(BadgeType.class)
>
> though.
>
> Factory methods have other advantages:
>
> * they can be statically imported
> * you can have several of them, even with the same argument types, since they can have a different name
> * they can do things after the constructor itself has been called
>
> See [Effective Java](http://books.google.fr/books?id=ka2VUBqHiWkC&pg=PA5&dq=effective+java+%22Creating+and+Destroying+Objects%22&hl=fr&sa=X&ei=9sJtVJKnHcPgatiMgJAC&ved=0CCIQ6AEwAA#v=onepage&q=effective%20java%20%22Creating%20and%20Destroying%20Objects%22&f=false) for a whole lot of great explanations.

And yes, we do speak in a beautiful English between ninjas when this is through a pull-request.

# Java, JavaScript, and beyond.

Une question de Marvin Frachet, ancien élève de Licence Pro à l'Université Lyon 1, où nous donnons toujours des cours.

**J'aurais aimé avoir votre avis concernant la stack java et la stack javascript actuelle, et quelles sont selon vous les tendances des années à venir&nbsp;? Quels sont les incontournables pour faire du web en Java a l'heure actuelle et éventuellement des outils Javascript hype et tendance&nbsp;?**

> C'est assez difficile d'y répondre, je dois dire.
>
> Dans le monde Java, pour écrire des services REST, les technos les plus utilisées, ou en tout cas celles qui me viennent à l'esprit, sont [JAX-RS](https://jax-rs-spec.java.net) (c'est un standard, dont les implémentations les plus connues sont [Jersey](https://jersey.java.net) et [RestEasy](http://resteasy.jboss.org)), [Spring MVC](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html) (que je préfère personnellement), et [Restlet](http://restlet.com).
>
> J'aime personnellement [Spring](http://spring.io) parce qu'il fournit une stack complète, ne force pas à utiliser un gros serveur d'appli (un simple [Tomcat](http://tomcat.apache.org) ou [Jetty](http://eclipse.org/jetty/) suffit), et laisse beaucoup de souplesse. Il est aussi en avance sur le standard Java EE sur plusieurs points&nbsp;:
>
> * Spring MVC est à mon sens plus facile à utiliser que JAX-RS
> * Il a un bon support des WebSockets, depuis la version 4, en permettant notamment l'utilisation de [SockJS](https://github.com/sockjs) pour avoir un fallback automatique vers du long polling AJAX pour les environnements ne supportant pas les websockets, et en permettant aussi l'utilisation de [STOMP](http://stomp.github.io), qui est un protocole d'un peu plus haut niveau, permettant par exemple de s'abonner à des topics, de broadcaster des notifications, ect.
> * du côté de la persistance, le projet [Spring-Data](http://projects.spring.io/spring-data/) permet de faire du JPA de manière plus simple (plein de méthodes et de requêtes sont auto-générées par le framework), et une API similaire existe aussi pour [MongoDB](http://www.mongodb.org).
>
> Le projet phare de Spring en ce moment est [Spring Boot](http://projects.spring.io/spring-boot/), qui simplifie le démarrage d'un projet Spring, et promeut les meilleures pratiques (pas de XML, conventions plutôt que configuration, etc.).
>
> Spring n'est pas franchement hype, mais il est solide, évolue toujours, et permet de faire proprement des tas de chose. Le support pour les tests automatisés notamment est excellent. Et Spring supporte sans problème Java 8, qui, avec ses streams et ses lambdas, rend la programmation Java plus fun qu'avant.
>
> Les trucs hype du moment sont plutôt à aller chercher du côté de frameworks "[reactive programming](http://www.reactivemanifesto.org)", mais honnêtement, je n'ai toujours pas vraiment compris ce que ça voulait dire, ni ce que ça apportait concrètement. Si j'ai vaguement compris quelque chose, c'est que le but est de supporter un nombre énorme d'utilisateurs concurrents en utilisant une technique similaire à celle de [NodeJS](http://nodejs.org)&nbsp;: peu de threads, mais beaucoup d'appels asynchrones.
>
> Du côté JavaScript, on aime toujours beaucoup [AngularJS](https://angularjs.org), qui devient vraiment mature et solide. Mais pour ma part, je ne connais pas bien la concurrence. Je connais un peu [Backbone](http://backbonejs.org), mais je le trouve complètement dépassé par rapport à Angular. [KnockoutJS](http://knockoutjs.com) et [Ember](http://emberjs.com) ont toujours la cote, et on entend en ce moment beaucoup parler de [React](http://facebook.github.io/react/), le framework de Facebook.
>
> La tendance des années à venir sera sans doute l'utilisation de [Web Components](http://webcomponents.org), qui encapsuleront du code HTML, du CSS et du JS. Le projet [Polymer](https://www.polymer-project.org) de Google est le projet qui pousse le plus dans ce sens. Mais il est sans doute trop tôt pour envisager de les utiliser réellement.

Voilà, la compilation s'arrête là, pour le moment.  

A vous de nous dire si vous avez appris des choses et si vous en voulez plus, ou si on aurait du écouter Jean-Baptiste qui n'osait pas publier cela&nbsp;!  
On attend vos commentaires.
