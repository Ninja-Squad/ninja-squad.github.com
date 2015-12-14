---
layout: post
title: Where is your invoice API?
author: jbnizet
tags: ["API", "rant"]
description: "So, you made a cool API. Can we download our invoice?"
---

We're a tiny shop. We don't have any secretary, full-time accountant, or whatever. We're just developers.

But we thus have to do some secretary or accountant tasks. One of them is to carefully archive invoices coming from online service providers such as [Github](https://github.com/), [DigitalOcean](https://www.digitalocean.com/) or [Online](https://www.online.net/fr).

These three are all major online service providers, and they're kind enough to send us an email every month, to send us our invoice, or just let us know that it's available.

But to archive them, we have to 

 - go to their web site, 
 - fill in the authentication form, 
 - find the page where our invoices are listed, 
 - find the last one, 
 - download it, 
 - and select the appropriate Google Drive folder. 

## This is cumbersome. We're developers. Let's automate! 

Github has a big [RESTful API](https://developer.github.com/v3/). So does [DigitalOcean](https://developers.digitalocean.com/documentation/v2/#account). Not sure about Online. But anyway, none of those APIs, unfortunately, allows us to list and download our invoices. 

<p style="text-align: center;">
    <img src="/assets/images/2015-12-14/invoice-api-meme.jpg" alt="Why can't we download our invoices using your API?"/>
</p>

I didn't think I'd have to use that again, but [HtmlUnit](http://htmlunit.sourceforge.net/) is our savior here. For those too young to know, HtmlUnit is a headless browser. A browser without any user interface, but with a Java API. 

Here's thus how we download our invoices now: 

 - open a command prompt;
 - type `./archiveGithub.sh;`
 - enter our password.

The program does everything we did before, automatically. It goes to the invoice page, fills in the authentication form and submits it, finds the list of invoices on the page, checks if the last one has already been downloaded, downloads it if necessary, and saves the file in the appropriate directory.

This is surprisingly easy, but we're lucky that none of the browsed pages needs fancy JavaScript to work fine. And it's not an appropriate replacement for a real API. So here's my message to big online service providers: include invoices in your API!

For the curious, here's the code for Github:

    public class GithubInvoiceArchiver {
        public static void main(String[] args) throws IOException {
            if (args.length != 3) {
                System.err.println("Expected arguments: <destination directory> <login> <password>");
                System.exit(1);
            }

            String destinationDirectory = args[0];
            String login = args[1];
            String password = args[2];

            System.out.println("Starting web browser...");
            WebClient wc = new WebClient();
            wc.getOptions().setJavaScriptEnabled(false);
            wc.getOptions().setCssEnabled(false);

            String billListUrl = "https://github.com/organizations/Ninja-Squad/settings/billing";
            System.out.println("Going to " + billListUrl);
            HtmlPage loginPage = wc.getPage(billListUrl);

            System.out.println("Authenticating...");
            loginPage.getHtmlElementById("login_field").type(login);
            loginPage.getHtmlElementById("password").type(password);
            HtmlInput submit = loginPage.getFirstByXPath("//input[@type='submit']");
            HtmlPage billingPage = submit.click();

            HtmlTable firstTable = billingPage.getDocumentElement().<HtmlTable>getHtmlElementsByTagName("table").get(0);
            HtmlAnchor downloadLink = firstTable.<HtmlAnchor>getHtmlElementsByTagName("a").get(0);

            String pdfAddress = downloadLink.getAttribute("href");
            System.out.println("Getting the address of the latest invoice: " + pdfAddress);

            String invoiceDate = firstTable.getHtmlElementsByTagName("time").get(0).asText().trim();
            System.out.println("Invoice date: " + invoiceDate);

            File dest = new File(destinationDirectory, "github-Ninja-Squad-receipt-" + invoiceDate + ".pdf");
            System.out.println("Checking if file " + dest + " already exists");

            if (!dest.exists()) {
                System.out.println("Getting the file...");
                Page pdfPage = downloadLink.click();

                Files.copy(pdfPage.getWebResponse().getContentAsStream(), dest.toPath());
                System.out.println("File " + dest + " saved.");
            }
            else {
                System.out.println("File already exists.");
            }
        }
    }
