---
layout: post
title: Le visitor pattern, et pourquoi l'utiliser avec JPA
author: jbnizet
tags: [java, pattern, jpa]
---

Peu de développeurs, même très expérimentés, connaissent et utilisent le pattern *visitor*,
ou au moins l'intérêt qu'il peut avoir lorsqu'on travaille avec JPA.
C'est pourtant un pattern qui, particulièrement avec JPA (ou Hibernate), est extrêmement utile.

Voici un exemple d'utilisation. 

## Le problème

Supposons qu'on utilise les classes ou entités suivantes:

<p style="text-align:center;">
    <img src="/assets/images/visitor1.jpg" alt=""/>
</p>

Et supposons qu'un service doive transformer le channel d'un message en DTO, afin de l'envoyer à un web service externe.

Une solution pour implémenter le service serait de l'implémenter comme ceci&nbsp;:

    private ChannelDTO createChannelDTO(Message message) {
        return message.getChannel().toChannelDTO();
    }
    
Le problème est que ça oblige l'entité Channel à connaître la classe ChannelDTO, qui est vraisemblablement dans un autre module,
dont on ne veut pas rendre le modèle dépendant. En outre, ça pollue la classe Channel avec de la logique qui n'est
pas de sa responsabilité: une entité métier n'est pas censée s'occuper de la communication avec un web service.

Une alternative serait d'implémenter le service de la manière suivante&nbsp;:

    private ChannelDTO createChannelDTO(Message message) {
        Channel channel = message.getChannel();
        ChannelDTO dto = new ChannelDTO();
        dto.setBody(channel.getBody());
        if (channel instanceof EmailChannel) {
            EmailChannel emailChannel = (EmailChannel) channel;
            dto.setType(EMAIL);
            dto.setSubject(emailChannel.getSubject());
            dto.setEmailAddress(emailChannel.getEmailAddress());
        }
        else if (channel instanceof FaxChannel) {
            FaxChannel faxChannel = (FaxChannel) channel;
            dto.setType(FAX);
            dto.setPhoneNumber(faxChannel.getPhoneNumber());
        }
        else {
            throw new ShouldNeverHappenException("Unknown subclass of Channel: " + channel.getClass());
        }
        return dto;
    }
    
Mais, mais... `instanceof`, c'est beurk, puf, caca-boudin. Ce n'est pas orienté object. On est censé faire du polymorphisme.

Bon, admettons qu'on fasse une exception. Que se passe-t-il si Message, Channel et ses sous-classes sont des entités JPA ou Hibernate,
et que la relation entre Message et Channel est lazy&nbsp;? Testez, et vous pourriez être surpris. Ce qui ne devrait normalement pas arriver va arriver:
une exception ShouldNeverHappenException va être levée.

La raison est simple. Lorsque Hibernate charge l'entité Message de la base de données, il connaît la valeur de clé étrangère pointant
sur le Channel. Mais c'est tout ce qu'il sait. Impossible de savoir si le Channel référencé est un EmailChannel ou un FaxChannel. 
Alors que va faire Hibernate&nbsp;? Créer une instance d'un proxy Javassist ou CGLIB:

<p style="text-align:center;">
    <img src="/assets/images/visitor2.jpg" alt=""/>
</p>

Et donc, le channel référencé par le message ne sera ni une instance de EmailChannel, ni une instance de FaxChannel.

## La solution&nbsp;: le pattern *visitor*

Ce pattern permet, en quelque sorte, d'injecter une méthode appelée polymorphiquement dans les entités. Ce pattern n'est adéquat que si toutes
les sous-classes possibles de la classe mère (ici, Channel) sont connues à l'avance. C'est le cas dans notre exemple.

On crée d'abord l'interface du visiteur&nbsp;:

    public interface ChannelVisitor<T> {
        T visitEmailChannel(EmailChannel emailChannel);
        T visitFaxChannel(FaxChannel faxChannel);
    }
    
On crée ensuite une méthode abstraite dans la classe de base, qu'on implémente dans chacune des classes filles&nbsp;:

    // Channel.java
    public abstract <T> T accept(ChannelVisitor<T> visitor);
    
    // EmailChannel.java
    @Override
    public <T> T accept(ChannelVisitor<T> visitor) {
        return visitor.visitEmailChannel(this);
    }
    
    // FaxChannel.java
    @Override
    public <T> T accept(ChannelVisitor<T> visitor) {
        return visitor.visitFaxChannel(this);
    }
    
Et notre code à base d'instanceof se transforme de la manière suivante :

    private ChannelDTO createChannelDTO(Message message) {
        Channel channel = message.getChannel();
        return channel.accept(new ChannelToDTOVisitor());
    }
    
    protected static class ChannelToDTOVisitor implements ChannelVisitor<ChannelDTO> {
        @Override
        public ChannelDTO visitEmailChannel(EmailChannel emailChannel) {
            ChannelDTO dto = new ChannelDTO();
            dto.setBody(emailChannel.getBody());
            dto.setType(EMAIL);
            dto.setSubject(emailChannel.getSubject());
            dto.setEmailAddress(emailChannel.getEmailAddress());
            return dto;
        }
        
        @Override
        public ChannelDTO visitFaxChannel(FaxChannel faxChannel) {
            ChannelDTO dto = new ChannelDTO();
            dto.setBody(faxChannel.getBody());
            dto.setType(FAX);
            dto.setPhoneNumber(faxChannel.getPhoneNumber());
            return dto;
        }
    }
    
Non seulement le code est polymorphique, orienté objet, mais il est aussi mieux découpé: la responsabilité de la transformation en DTO
a été attribuée à une classe dédiée, qui contient une méthode par type de channel. Ce code est propre, lisible, et facile à tester.

Autre avantage: supposons que vous introduisiez un troisième channel: SMSChannel. Dans la solution utilisant instanceof, vous pourriez
oublier qu'il faut ajouter une branche pour gérer ce nouveau channel. C'est seulement à l'exécution que vous verriez apparaître l'exception
`Unknown subclass of Channel: com.ninja_squad.visitorsample.SMSChannel`. Dans le cas du visitor, aucun rique: le compilateur vous forcera à
implémenter la méthode abstraite accept(), ce qui vous forcera à ajouter une méthode à l'interface et à toutes les implémentations de
ChannelVisitor.

Et JPA/Hibernate&nbsp;? En quoi cette solution résout-elle le problème du proxy&nbsp;? 

Et bien c'est simple. Lorsque la méthode accept() sera appelée sur le proxy, le proxy va s'initialiser en chargeant le Channel de 
la base de données. A ce moment, le proxy aura une référence vers une instance de EmailChannel ou FaxChannel, en fonction du type trouvé 
dans la base de données. Et comme il s'agit d'un proxy, l'appel à la méthode accept() sera transféré à cette instance de EmailChannel ou FaxChannel,
qui va appeler la méthode adéquate du visiteur. Le proxy redevient transparent, grâce au polymorphisme.

<p style="text-align:center;">
    <img src="/assets/images/visitor3.jpg" alt=""/>
</p>