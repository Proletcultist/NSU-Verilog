#set document(
  title: [Lab 1.2 \ Matvey Zenin 24214],
)
#set page(
  paper: "a4",
  numbering: "1",
)
#set text(
  font: "New Computer Modern",
  size: 12pt,
)

#set heading(numbering: "1.")

#align(center, title())

= Multiplexer

#figure(
  image("images/mux.png"),
  caption: [Mux2 with width=4 circuit],
)

= Decoder 2 to 4

#figure(
  table(
    columns: (auto, auto, auto),
    table.header(
      [*code*], [*enable*], [*onehot*]
    ),
    [`0b00`], [`0b0`], [`0b0000`],
    [`0b01`], [`0b0`], [`0b0000`],
    [`0b10`], [`0b0`], [`0b0000`],
    [`0b11`], [`0b0`], [`0b0000`],
    [`0b00`], [`0b1`], [`0b0001`],
    [`0b01`], [`0b1`], [`0b0010`],
    [`0b10`], [`0b1`], [`0b0100`],
    [`0b11`], [`0b1`], [`0b1000`],
  ),
  caption: [Decoder 2 to 4 table],
)
