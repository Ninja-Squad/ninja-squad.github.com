---
layout: post
title: How to generate PDF documents in Java
author: jbnizet
tags: ["Java", "PDF"]
description: "How to generate PDF documents in Java (or any other language on the JVM)"
---

Wow. It had been a while since I hadn't blogged.

This post will be short, and maybe obvious to you if you have some Java experience already.

I do have some experience, and in several past projects, I have had to generate printable documents, i.e. PDF files. 

The first tool I used to do that was [Jasper Reports](https://www.jaspersoft.com/products/jasperreports-library). 
I didn't really liked it. 
The documentation is scarce, you have to learn a lot of concepts and use a special IDE to design the reports using drag n' drop. 
It also had a lot of dependencies, sometimes outdated. 
My feeling is that it certainly has its uses for large or complex documents that must have a good layout, but when you have to generate simple documents now and then, it's overkill.

On another project, I tried something else: [Eclipse BIRT](https://eclipse.github.io/birt-website/). 
The experience was similar, only a bit worse.

All this time, I knew about a lower-lever library, that, by the way, Jasper Reports and BIRT both seem to use under the scene to actually generate the PDF documents: [iText](https://itextpdf.com/en/products/itext-7). 
But for some reason (maybe it was true at the time), I always thought it was too low-level to be used directly. 

I recently revisited that assumption, and I was very wrong. 

iText actually has a very nice fluent DSL to generate documents in a very simple way. 
No need for any specific IDE. 
And the way to think about documents is very similar to the way you think about HTML pages:
you compose them using divs, paragraphs, images, tables, all having borders, font styles, margins, etc. 
It's really easy to get started with the API and discover what you can do with it.

Here's a small complete example (in Kotlin, but the code would be very similar in Java):

```kotlin
class DocumentGenerator {
    fun generate(out: OutputStream) {
        val pdfWriter = PdfWriter(out)
        val pdfDoc = PdfDocument(pdfWriter)
        Document(pdfDoc, PageSize.A5).use { doc ->
            doc
                .add(createHeader())
                .add(createTitle())
                .add(createQuestionSection())
                .add(createSignatureForm())
                .add(createFooter())
        }
    }

    private fun createHeader(): Div {
        return Div()
            .add(
                Image(ImageDataFactory.create(this.javaClass.getResource("/images/logo.png")))
                    .scaleToFit(90f, 90f)
            )
            .setMarginBottom(12f)
    }

    private fun createTitle(): Paragraph {
        return Paragraph("Membership form")
            .setTextAlignment(TextAlignment.CENTER)
            .setFontSize(24f)
    }

    private fun createQuestionSection(): Div {
        fun field() = Paragraph("\u00a0").setBorderBottom(DottedBorder(0.5f))
        return Div()
            .setMarginTop(30f)
            .add(Paragraph("How did you know about us?"))
            .add(field())
            .add(field())
    }

    private fun createSignatureForm(): Table {
        fun labelCell(text: String) = Cell(1, 1)
            .setBorder(Border.NO_BORDER)
            .setTextAlignment(TextAlignment.RIGHT)
            .add(Paragraph(text))

        fun fieldCell() =
            Cell(1, 1)
                .setBorder(Border.NO_BORDER)
                .setBorderBottom(DottedBorder(0.5f))

        return Table(
            arrayOf<UnitValue>(
                UnitValue.createPercentValue(20f),
                UnitValue.createPercentValue(30f),
                UnitValue.createPercentValue(20f),
                UnitValue.createPercentValue(30f)
            )
        )
            .useAllAvailableWidth()
            .setBorder(Border.NO_BORDER)
            .setMarginTop(30f)
            .addCell(labelCell("Date: "))
            .addCell(fieldCell())
            .addCell(labelCell("Signature: "))
            .addCell(fieldCell())
    }

    private fun createFooter(): Div {
        return Div()
            .setMarginTop(30f)
            .add(
                Paragraph()
                    .add("The collected information ")
                    .add(Text("will never be transmitted to anybody outside the association").setUnderline())
                    .add(". It's only used to improve our services.")
            ).setFontSize(9f).setTextAlignment(TextAlignment.JUSTIFIED)
    }
}
```

And here's a picture of the generated document:

<p style="text-align: center;">
  <img src="/assets/images/2022-01-06/document.png" alt="Generated document" />
</p>

What can be cumbersome, compared to editing HTML pages, is to view the result of the changes you're applying. 
I solve this with a unit test that generates a temporary file and opens it. 
Did you know that Java has a `Desktop` class allowing to open files with the default application associated to the file type (just like when you double click on a file in the file explorer)?

```kotlin
class DocumentGeneratorTest {
    @Test
    fun `should generate a document`(@TempDir tempDirectory: File) {
        val generator = DocumentGenerator()
        val file = tempDirectory.resolve("document.pdf")
        FileOutputStream(file).use {
            generator.generate(it)
        }
        assertThat(file).isNotEmpty()
        Desktop.getDesktop().open(file)
    }
}
```
