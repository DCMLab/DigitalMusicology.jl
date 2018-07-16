# DigitalMusicology

[![Project Status: Concept – Minimal or no implementation has been done yet, or the repository is only intended to be a limited example, demo, or proof-of-concept.](http://www.repostatus.org/badges/latest/concept.svg)](http://www.repostatus.org/#concept)
[![Build Status](https://travis-ci.org/DCMLab/DigitalMusicology.jl.svg?branch=master)](https://travis-ci.org/DCMLab/DigitalMusicology.jl)
[![Coverage Status](https://coveralls.io/repos/DCMLab/DigitalMusicology.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/DCMLab/DigitalMusicology.jl?branch=master)
[![codecov.io](http://codecov.io/github/DCMLab/DigitalMusicology.jl/coverage.svg?branch=master)](http://codecov.io/github/DCMLab/DigitalMusicology.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://dcmlab.github.io/DigitalMusicology.jl/latest)

This is the Julia toolbox of the Digital and Cognitive Musicology Lab (DCML) at the [École polytechnique fédérale de Lausanne (EPFL)](https://www.epfl.ch/index.en.html). 

Some ideas:
- a common interface for loading data organized in corpora
  - identifiers (+ ability to look up / search them)
  - `getpiece(id, :fmt)`
- no single data structure for representing everything
  - use representation appropriate to problem
  - allow lossless conversion where possible
  - allow lossy conversion or conversion with additional info where possible
  - implement algorithms generically to work on different representations
- separate plotting library (to be published)

What's there:
- basic representations (pitches, notes, some collections)
- grams and skipgrams
- MIDI import
- Various corpus formats (MIDI archive, kern corpora)

What's missing:
- good documentation with introduction
- more advanced represenations
- import / export formats
- score plotting in notebooks (output works, generation missing)
- all kinds of general functionality
