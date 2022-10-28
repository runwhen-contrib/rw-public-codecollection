# Coding Conventions

## Python vs Robot
Modules found in the RW package use either uppercase filenames for Robot Keyword modules and lowercase
filenames for python interface modules.

We recognize this looks like considerable duplicate/boilerplate code as there are a number of cases where
a Robot Keyword module will import a python module with a similar name, only to expose many of the same
function calls as class methods.  The rationale is below.

Robot Framework libraries here are built as class libraries, i.e. the Robot Framework runtime environment
controls their lifecycle.  While this is well documented (use the 'ROBOT_LIBRARY_SCOPE' attribute), few
of us read the docs that closely and thus we assume that many people will make mistakes and instantiate their
own instances of these library classes.  While in many cases this is harmless, think about the situation where
a library class is written as ROBOT_LIBRARY_SCOPE="GLOBAL" but a keyword author creates instances of it
in their class, which is scoped as "TASK".  You will now have n instances of this library floating around
where the authors explicitly expected only a singleton, an issue if that is making expensive set-up calls
(think DDoS'ing the back-end asking to authenticate once or more per Task).

As a result of this potential for harmful lifecycle errors, we decided that the boilerplate code effort
was worth the safety.

## Core vs Utils
Core is a set of keywords (and rw.core a set of python functions) intended to interface to the RunWhen platform
and the various features it provides for Robot Authors / keyword Authors.  Utils are general
utility functions, available in this repo.