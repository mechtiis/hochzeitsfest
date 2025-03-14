#set page(columns: 3)

#let guests = toml("./gästeliste.toml").guests

#let guest-split-regex = regex("(,? und |,\\s?)")

#place(
  top,
  scope: "parent",
  float: true,
)[
  = Report

  #v(1em)

  #let num_guests = guests.fold(
    0,
    (acc, g) => acc + g.name.split(guest-split-regex).len(),
  );
  #let num_replies = guests.fold(
    0,
    (acc, g) => {
      let attending = g.at("attending", default: none)
      if attending == none {
        acc
      } else {
        acc + g.at("name").split(guest-split-regex).len()
      }
    },
  )

  #grid(
    columns: (auto, auto, auto),
    gutter: 1em,
    "replies:",
    box(
      width: 100%,
      stroke: 1pt,
      rect(
        width: (num_replies / num_guests * 100%),
        height: 0.8em,
        fill: black,
      ),
    ),
    [*#num_replies / #num_guests*],
  )

  #v(1em)
]

#let find = it => guests.fold(
  (),
  (acc, g) => {
    for name in g.at("name").split(guest-split-regex) {
      let attending = g.at("attending", default: none)
      if attending == none {
        continue
      }
      if type(attending) == dictionary {
        if attending.at(name).contains(it) {
          acc.push(name)
        }
      } else {
        if attending.contains(it) {
          acc.push(name)
        }
      }
    }
    acc
  },
)

#let found = find("afternoon")

== Afternoon (#found.len())

#for guest in found {
  guest
  "\n"
}

#colbreak()

#let found = find("dinner")

== Dinner (#found.len())

#for guest in found {
  guest
  "\n"
}

#colbreak()

#let found = find("hike")

== Hike (#found.len())

#for guest in found {
  guest
  "\n"
}

#place(
  bottom,
  scope: "parent",
  float: true,
)[
  #let undecided = (
    guests
      .map(guest => {
        let attending = guest.at("attending", default: none)
        if attending != none {
          return ()
        }
        guest.at("name").split(guest-split-regex)
      })
      .flatten()
  )

  #if undecided.len() != 0 {
    [
      == Undecided

      #undecided.join(", ")
    ]
  }
]
