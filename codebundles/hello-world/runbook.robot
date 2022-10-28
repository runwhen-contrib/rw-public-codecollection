*** Settings ***
Documentation       A simple-as-possible task set

Library             RW.Core

*** Tasks ***
Hello World
    Log    Hello World

Add One String To Report
    Add To Report    A String To Be Added To The Report
