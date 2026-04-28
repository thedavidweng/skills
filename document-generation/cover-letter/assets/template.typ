// Cover Letter Template
// Usage: Copy this file, fill in placeholders, then run: typst compile <filename>.typ
//
// DO NOT MODIFY: font, margins, or spacing values.
// These are calibrated to produce professional, consistent output.
// ONLY change paper: to "us-letter" or "a4" based on user preference.

#set page(paper: "us-letter", margin: (top: 1in, bottom: 0.75in, left: 1in, right: 1in))  // or "a4"
#set text(font: "Times New Roman", size: 11pt, hyphenate: false)
#set par(justify: true, leading: 0.75em, spacing: 1.18em)

// ── Sender address (right-aligned) ──
#align(right)[
  {{SENDER_NAME}} \
  {{SENDER_EMAIL}} \
  {{SENDER_CITY}}, {{SENDER_REGION}}, {{SENDER_COUNTRY}}
  #v(0.6em)
  {{DATE}}
]

#v(1.6em)

// ── Recipient ──
{{RECIPIENT_TITLE}} \
{{RECIPIENT_ORG}} \
{{RECIPIENT_DEPT}} \
{{RECIPIENT_DIVISION}}

#v(1.5em)

// ── Salutation ──
Dear {{SALUTATION}},

// ── Body ──
{{PARAGRAPH_1}}

{{PARAGRAPH_2}}

{{PARAGRAPH_3}}

{{PARAGRAPH_4}}

// ── Closing ──
#v(0.8em)
#align(right)[
  Sincerely,
  #v(0.55em)
  {{SENDER_NAME}}
]
