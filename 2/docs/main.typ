#set document(
  title: [Lab 2 \ Matvey Zenin 24214],
)
#set page(
  paper: "a4",
  numbering: "1",
)
#set text(
  font: "New Computer Modern",
  size: 8pt,
)

#set heading(numbering: "1.")

#align(center, title())

= Operations table

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    table.header(
      [*op*], [*op name*], [*y*], [*zero*], [*negative*], [*carry*], [*overflow*]
    ),
    [`0b000`], [ADD], [$(a + b)[W-1:0]$], [$y == 0$], [$y[W - 1]$], [$(a + b)[W]$], [$(a[W - 1] == b[W - 1]) and \ (a[W - 1] != y[W - 1])$],
    [`0b001`], [SUB], [$(a + (-b))[W-1:0]$], [$y == 0$], [$y[W - 1]$], [$not (a + (-b))[W]$], [$(a[W - 1] == (-b)[W - 1]) and \ (a[W - 1] != y[W - 1])$],
    [`0b010`], [AND], [$a \& b$], [$y == 0$], [$y[W - 1]$], [$0$], [$0$],
    [`0b011`], [OR], [$a | b$], [$y == 0$], [$y[W - 1]$], [$0$], [$0$],
    [`0b100`], [XOR], [$a \^ b$], [$y == 0$], [$y[W - 1]$], [$0$], [$0$],
    [`0b101`], [SLL], [$a << "shamt"$], [$y == 0$], [$y[W - 1]$], [$0$], [$0$],
    [`0b110`], [SLL], [$a >> "shamt"$], [$y == 0$], [$y[W - 1]$], [$0$], [$0$],
    [`0b111`], [SLT], [$"signed"(a) < "signed"(b)$], [$y == 0$], [$y[W - 1]$], [$0$], [$0$],
    [`default`], [], [$0$], [$1$], [$0$], [$0$], [$0$],
  ),
  caption: [ALU operations table],
)

There:

$ "shamt" = cases(
  W["SHW" - 1:0] quad &\, W " - power of 2",
  W["SHW" - 1:0] % W quad &\, "otherwise",
) $

$ "SHW" = ceil.l log_2 W ceil.r $
