---
layout: post
title: "What we learnt from Quizzie: Ops"
author: jbnizet
tags: ["ninja squad", "quizzie", "ansible", "docker"]
description: "We're pretty decent developers, but when it comes to operations, that's another story. Building and operating Quizzie
is a great way to slowly become devops, and not just devs."
---

{% include ninjasquad/quizzie-discontinued-en %}

We think we're pretty decent developers. Operations are another story. Most of the time, when working as
consultants, we leave that part to other, more qualified people. So we have a lot to learn in that area.

Building, deploying and operating Quizzie, one of our Friday side-projects, is a great
way to improve and learn.

In this post, I'll explain where and how we deploy Quizzie, and the lessons we learnt while doing so.

## DigitalOcean

When we decided to deploy Quizzie on the interweb, we didn't know where we would deploy it. We first thought about using
a PAAS. The application being built with Spring, [CloundFoundry](http://www.cloudfoundry.org/index.html) was a natural choice.
So we began using it, and the experience was pleasant, overall. I particularly liked the fact that uploading a big war file took only a few seconds because the uploader was smart enough to avoid uploading all the libraries inside the war that it already knew about.

But we felt like it was too limiting for what we wanted to do. Using a distant heroku-hosted PostgreSQL database,
accessible from anywhere, didn't please us, either. The price was a limiting factor, too: Quizzie is free except for private quizzes, and we haven't earned a cent yet.

So we decided to go with a more classical hosting offering, and chose to try using [DigitalOcean](https://www.digitalocean.com/). Their offering is pretty cheap, and given how using an SSD on our dev boxes changed our life, having an SSD on the production machine looked like a good idea.

We thought we would only use it during the development phase, but given how well things went, we finally decided to deploy Quizzie
there.

Things we like about DigitalOcean:

 - the price, cheap and predictible
 - it's SSD-based
 - we're in control of what we install and run
 - they have great guides, a clear control-panel, and a responsive support
 - they have datacenters in Europe

If you want to try DigitalOcean, leave us a note: we'll send you an invite and earn one month of Quizzie hosting thanks
to you :).

## VirtualBox

We're not really Linux-ninjas. Most of the clients we worked with provide us Windows workstations. And at home, we're all on MacOS.
So we had (and still have) a lot to learn. [VirtualBox](https://www.virtualbox.org/) is a great way to do that: start a VM, install a Linux distro without breaking
anything on your home, install whatever you want and make regular save points. Screw up, and start from the last save point.

## Docker

[Docker](https://www.docker.com) is the best invention since sliced bread, right? You're a loser if you don't use it.

So we tried. That seemed like a good idea. We would have an easy to install, reproducible container for Tomcat, and for PostgreSQL, and for NGINX, etc.

We almost succeeded. At a moment, we tried deploying an ElasticSearch and Kibana container to archive and search our log files. This sounded easy: just use a ready-made Docker container. Three days later, our DigitalOcean box was shut down because the Docker container was doing nothing except broadcasting (i.e. spamming) half of the DigitalOcean boxes on the data center. Using a ready-made container without knowing exactly what runs inside it and how it has been configured: bad, bad idea. Lesson learned.

So we looked back and asked ourselves a few questions:

 - does Docker really helps us having a stable and reproducible environment. The answer was no.
 - does Docker make it easier to deploy our application. The answer was no.
 - does Docker make the application easier to operate: consult logs, diagnose a failure, get back online quickly and safely? The answer was no.
 - are we confident enough to not screw everything up, be able to restart Quizzie or restore a backup. The answer was no.
 - is the Docker documentation helpful? The answer was no. In my opinion, unless you've been a kernel developer or a Linux sysadmin
 for a few years, you can't understand half of what is explained in the documentation.
 - should we use Docker in production? The answer was no.

We'll probably try using Docker again in a few months or years, but at the moment, I simply feel it's not mature enough to be usable by
developers like us. And even then, unless I need to deploy the same container on dozens of machines, I'm not sure the huge additional
complexity is worth it.

So we decided to forget about Docker, and rewrote our ansible provisioning scripts to simply install the JVM, Tomcat, PostgreSQL and NGINX directly on the DigitalOcean host. Three hours later, we had all we needed to
install everything on a fresh machine, deploy quizzie, backup and restore the database.

## Ansible

If you use Linux and don't know [Ansible](http://www.ansible.com), you're missing a really, really great tool.

Ansible has great guides and a clear, complete reference documentation. You can start using it in a few minutes, and learn the more
advanced concepts later.

It's easy to set up: all you need is Python and SSH, and those two both come pre-installed on Linux distros.

It has a huge amount of modules to deal with files, downloads and uploads, shell commands, database setup, web server
monitoring, etc.

And its basic design principle is brilliant: instead of executing an imperative script to install or configure everything you need on a remote host (or many of them), you **declare** how your system should be configured. Ansible is idempotent: if your ansible install fails in the middle, after having installed 5 apt packages and created 10 directories and symlinks, just fix the failing task in the middle of the playbook, restart the whole process, and it will automatically detect that the 5 apt packages are already installed, and that the 10 directories and symlinks already exist.

We use Ansible to install and configure all the software we need on the production box. Installing and configuring the JVM, Tomcat, NGINX, PostgreSQL, the firewall, is done by executing a single command.

We also use it every time we want to deploy a new version of Quizzie: in one command thanks to ansible, without entering any password, we backup the database, backup the current version of the app, switch the NGINX config to display the maintenance page, stop Tomcat, deploy Quizzie, migrate the database schema, restart Tomcat and go back to production mode.

Ansible is definitely a tool I'm happy to have in my toolbox.
