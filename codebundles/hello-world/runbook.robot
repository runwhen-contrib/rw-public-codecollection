*** Settings ***
Documentation     Basic Hello-World TaskSet
Library           RW.Core

*** Tasks ***
Hello World
    Log    Hello World

Add One String To Report
    Add To Report    A String To Be Added To The Report
