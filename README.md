# AMR Trinity

_Run the "Big Three" AMR detection tools with unified output_

### Background

This repository provides various ways to run the "Big Three" AMR detection tools
over a set of inputs and obtain collated unified output.

The project builds on [hAMRonization](https://github.com/pha4ge/hAMRonization),
which maintains a collection of converters to harmonise AMR tool output formats.

The hAMRonization project also had a
[proof of concept workflow](https://github.com/pha4ge/hAMRonization_workflow)
that ran all (18) supported tools, but this was cumbersome to maintain due to
the myriad requirements and installation methods of the tools.

In **AMR Trinity** we scale down the hAMRonization workflow to the "Big Three":

 * [AMRFinderPlus](https://github.com/ncbi/amr)
 * [ResFinder](https://bitbucket.org/genomicepidemiology/resfinder)
 * [RGI/CARD](https://github.com/arpcard/rgi)

These three were chosen because - apart from being widely used - each has their
own actively curated database and algorithms.

