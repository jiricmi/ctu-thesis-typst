#let translations = (
  "cs": (
    "thesis-bachelor": "Bakalářská práce",
    "thesis-master": "Diplomová práce",
    "supervisor": "Vedoucí práce",
    "study-programme": "Studijní program",
    "branch-of-study": "Obor studia",
    "acknowledgement": "Poděkování",
    "declaration": "Prohlášení",
    "declaration-text": "Prohlašuji, že jsem předloženou práci vypracoval/a samostatně a že jsem uvedl/a veškeré použité informační zdroje v souladu s Metodickým pokynem o dodržování etických principů při přípravě vysokoškolských závěrečných prací.",
    "prague": "v Praze",
    "abstract": "Abstrakt",
    "cvut": "České Vysoké Učení Technické v praze"
  ),
  "en": (
    "thesis-bachelor": "Bachelor's Thesis",
    "thesis-master": "Master's Thesis",
    "supervisor": "Supervisor",
    "study-programme": "Study programme",
    "branch-of-study": "Branch of study",
    "acknowledgement": "Acknowledgement",
    "declaration": "Declaration",
    "declaration-text": "I declare that the presented work was developed independently and that I have listed all sources of information used within it in accordance with the methodical instructions for observing the ethical principles in the preparation of university theses.",
    "prague": "In Prague",
    "abstract": "Abstract",
    "cvut": "Czech Technical University in Prague"
  )
)

#let localized(key, lang) = {
  let translation = translations.at(lang)
    translation.at(key)
  }
}

#let title-page(
  print,
  lang,
  title: "",
  author: (
    name: "",
    email: "",
    url: "",
  ),
  submission-date: datetime.today(),
  bachelor: false,
  supervisor: "",
  faculty: "",
  department: "",
  study-programme: "",
  branch-of-study: "",
) = {
  // render as a separate page
  // inner margin is 8mm due to binding loss, but without
  //  the bent page extra, which is not an issue for the title page
  let inside-margin = if print {8mm} else {0mm}
  show: page.with(margin: (top: 0mm, bottom: 0mm, inside: inside-margin, outside: 0mm))

  set align(center)
  set place(center)
  set text(font: "Technika", weight: "extralight", size: 10.3pt, fallback: false)

  // shorthand to vertically position elements
  let b(dy, content, size: none, weight: none) = {
    set text(size: size) if size != none
    set text(weight: weight) if weight != none
    place(dy: dy, text(content))
  }

  b(33mm)[
    #localized("cvut", lang)\
    #faculty \
    #department
  ]

  b(63.5mm)[
    #image("./res/symbol_cvut_konturova_verze_cb.svg", width: 142pt)
  ]

  b(131.5mm, size: 12.5pt)[
    #if bachelor [
      #localized("thesis-bachelor", lang)
    ] else [
      #localized("thesis-master", lang)
    ]
  ]

  b(140.7mm, size: 14.8pt, weight: "regular")[
    #title
  ]
  
  b(154.25mm, [
    #text(size: 12.5pt, style: "italic")[#author.name] \

    \
    #author.email \
    #link(author.url)
  ])

  b(210mm)[#localized("supervisor", lang): #supervisor]

  b(235.2mm)[#localized("study-programme", lang): #study-programme]
  b(241.2mm)[#localized("branch-of-study", lang): #branch-of-study]
  
  b(254.3mm)[#submission-date.display("[month repr:long] [year]")]
}


#let abstract-page(
  submission-date,
  lang,
  abstract-en: [],
  abstract-cz: [],
  acknowledgement: [],
) = {
  // render as a separate page; add room at the bottom for TODOs and notes
  set page(numbering: "i")
  counter(page).update(3)
  
  set heading(
    outlined: false,
    bookmarked: false,
  )
  show heading: it => [
    #set text(font: "Technika" ,fill: blue)
    #it.body
  ]

  // pretty hacky way to disable the implicit linebreak in my heading style
  show heading: it => {
    show pagebreak: it => {linebreak()}
    block(it, above: 2pt)
  }
  
  grid(
    columns: (10fr, 1fr, 10fr),
    gutter: 5pt,
    [
    #align(right)[
      = #localized("abstract", "en")
    ]
      #abstract-en
    ],
    align(center, 
[
        #rect(width: 50%, height: 100%, fill: blue)
      ]
    ),
      
    [
      = #localized("abstract", "cs")
      #abstract-cz
    ],
  )

  v(6.6pt)
  //v(-6pt)
    align(horizon)[
      = #localized("acknowledgement", lang)
      #set text(style: "italic")
      #acknowledgement
    ]

    pagebreak(weak: false)
  
    align(bottom)[
     #align(right)[
        = #localized("declaration", lang)
     ]
      #localized("declaration-text", lang) 
      
        #localized("prague", lang), #submission-date.display("[day]. [month]. [year]")
    ]

  context {
    set text(size: 15pt, weight: "bold")
    set align(center)

    v(1em)
    grid(columns: (47%, 47%), gutter: 6%,
      {
        let todo-count = counter("todo").final().at(0);
        if (todo-count > 0) {
          set text(fill: red)
          block(width: 100%, inset: 4pt)[#todo-count TODOs remaining]
        }
      },
      {
        let note-count = counter("note").final().at(0);
        if (note-count > 0) {
          block(fill: yellow, width: 100%, inset: 4pt)[#note-count notes]
        }
      }
    )
  }
}


#let introduction(print, submission-date, lang, ..args) = {
  // hide empty pages from web version
  if print {
    // assignment must be on a single sheet from both sides
    pagebreak(to: "odd")
  } else {
    // Typst cannot embed PDFs, add the assignment separately
    page[assignment page 1]
    page[assignment page 2]
  }

  if print {
    pagebreak(to: "odd", weak: true)
  }
  abstract-page(submission-date, lang, ..args)

  if print {
    // outline should be on the right, but the outline title has a pagebreak
    pagebreak(to: "even")
  }

  show heading: it => [
    #set text(font: "Technika" ,fill: blue)
    #it.body
  ]
  outline(depth: 3)

  pagebreak(weak: true)
}
